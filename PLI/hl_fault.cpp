#include <fstream>
#include <iostream>
#include <vector>
#include <string>
#include <cstring>
#include <ctime>
#include <algorithm>
#include <functional>
#include <limits>

extern "C" {
#pragma GCC diagnostic ignored "-Wwrite-strings"
#include <modelsim/vpi_user.h>
}

using namespace std;
using namespace std::placeholders;

void print_net(vpiHandle vh, int depth)
{
	for(int i = 0; i < depth; ++i)
		vpi_printf("  ");
	vpi_printf("name is %s ", vpi_get_str(vpiFullName, vh));
	vpi_printf("type: %s\n", vpi_get_str(vpiDefName, vh));
}

void add_nets_to_vector(vector<vpiHandle> * list, vpiHandle vh_module, int depth)
{
	vpiHandle vh_nets_it, vh_netbits_it;
	vpiHandle vh_net, vh_netbit;

	for(int i = 0; i < depth; ++i)
		vpi_printf(" ");
	vpi_printf("Submodule %-30s ", vpi_get_str(vpiFullName, vh_module));
	vpi_printf("\t(%s)\n", vpi_get_str(vpiDefName, vh_module));

	vh_nets_it = vpi_iterate(vpiNet, vh_module);
	/* iterate through the nets of module "mod" */
	while (vh_nets_it && (vh_net = vpi_scan(vh_nets_it)) != NULL) {
		if( (vh_netbits_it = vpi_iterate(vpiBit, vh_net)) ) {
			while ((vh_netbit = vpi_scan(vh_netbits_it)) != NULL) {
				list->push_back(vh_netbit);
//				vpi_printf("Net: %s\n", vpi_get_str(vpiFullName, vh_netbit));
			}
		}
		else {
			list->push_back(vh_net);
//			vpi_printf("Net: %s\n", vpi_get_str(vpiFullName, vh_net));
		}
	}
}

void traverse_vpi(vpiHandle vh, PLI_INT32 type, std::function<void(vpiHandle,int)> func,
		bool leaves_only = false, int maxdepth = numeric_limits<int>::max())
{
	vpiHandle vh_sub, vh_iter;
	static int depth = 0;

	if(depth > maxdepth)
		return;

	if(leaves_only){
		if(!vpi_iterate(type, vh) || depth == maxdepth)
			func(vh, depth);
	}
	else
		func(vh, depth);

	vh_iter = vpi_iterate(type, vh);
	if(vh_iter) {
		while ((vh_sub = vpi_scan(vh_iter)) != NULL) {
			++depth;
			traverse_vpi(vh_sub, type, func, leaves_only, maxdepth);
			--depth;
		}
	}
}

void inject_faults(vpiHandle vh_module, int num_faults, int max_depth = numeric_limits<int>::max())
{
	vpi_printf("Injecting %d faults on %s\n\n", num_faults, vpi_get_str(vpiFullName, vh_module));
	vector <std::string> modules;
	traverse_vpi(vh_module, vpiModule,
			bind([](vector<std::string> *l, vpiHandle vh) { l->push_back( std::string(vpi_get_str(vpiFullName,vh))  ); }, &modules, _1 ));
//	for(auto m: modules){
//		vpi_printf("%s \n", m.c_str());
//	}
	vector <int> faults_in_mod(modules.size(), 0);


	vector <vpiHandle> nets;

	static s_vpi_value value_s;

	traverse_vpi(vh_module, vpiModule, bind(add_nets_to_vector , &nets, _1, _2), false, max_depth);


	//	vpiHandle vh_submodules_it, vh_submodule;

	num_faults = min(num_faults, (int)nets.size());
	random_shuffle(nets.begin(), nets.end());
	vpi_printf("=== Choosing %d nets out of %d total nets\n", num_faults, nets.size());
	//

	vpiHandle vh_net;

	value_s.format = vpiScalarVal;
	for(int i = 0; i < num_faults; ++i) {
		vh_net = nets[i];

		vpi_printf("\tNet: %s\n", vpi_get_str(vpiFullName, vh_net));

		vpiHandle vh_parmod = vpi_handle (vpiModule, vh_net);
		std::string parmod_name(vpi_get_str(vpiFullName,vh_parmod));
		for(unsigned i = 0; i < modules.size(); ++i){
//			vpi_printf("vh_parmod is %s, module[i] is %s\n", parmod_name.c_str(), modules[i].c_str());
			if (modules[i] == parmod_name) {
				++faults_in_mod[i];
				break;
			}
		}

		vpi_printf("\tParent module: %s\n", vpi_get_str(vpiFullName, vh_parmod) );
		vpi_get_value(vh_net, &value_s);
		vpi_printf("\tValue: %d\n", value_s.value.scalar);

		value_s.value.scalar = !value_s.value.scalar; // 0->1 (1,z,x)->0

		vpi_put_value(vh_net, &value_s, 0, vpiForceFlag);
		vpi_get_value(vh_net, &value_s);
		vpi_printf("\tNew Value: %d\n\n", value_s.value.scalar);
	}

	vpi_printf("\nFAULTVECTOR>> ");
	for(unsigned i = 0; i < faults_in_mod.size(); ++i){
		vpi_printf("%d ", faults_in_mod[i]);
	}

	vpi_printf("\n");
}

// actual task function:
extern "C" PLI_INT32 calltf_inject_hlf(PLI_BYTE8 *)
{

	vpiHandle vh_systf, vh_arg_iter;
	s_vpi_value val;

	std::srand(std::time(0));

	vh_systf = vpi_handle(vpiSysTfCall, NULL);
	if (!vh_systf) {
		vpi_printf("ERROR: Failed to obtain systf handle\n");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}
	vh_arg_iter = vpi_iterate(vpiArgument, vh_systf);
	if (!vh_arg_iter) {
		vpi_printf("ERROR getting args");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}

	vpiHandle vh_topmodule = vpi_scan(vh_arg_iter);
	if (!vh_topmodule) {
		vpi_printf("ERROR getting topmodule");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}

	vpiHandle vh_const = vpi_scan(vh_arg_iter);
	if (!vh_const) {
		vpi_printf("ERROR getting topmodule");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}
	if(vpi_get(vpiConstType,vh_const) != vpiDecConst) {
		vpi_printf("ERROR expecting a decimal constant");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}

	val.format = vpiIntVal;
	vpi_get_value(vh_const,&val);

	int num_faults = val.value.integer;

	vpi_printf("Top module is %s", vpi_get_str(vpiFullName, vh_topmodule));
	vpi_printf("\t(%s)\n", vpi_get_str(vpiDefName, vh_topmodule));

	vector <vpiHandle> modules;
	bool lo = true; // sub-modules only!
	int maxdepth = 2;

	traverse_vpi(vh_topmodule, vpiModule,
			bind([](vector<vpiHandle> *l, vpiHandle vh) { l->push_back(vh); }, &modules, _1 ), lo, maxdepth);

	vpi_printf("\n==Sub-modules:================\t==Instance of:==========\n");
	for(unsigned i = 0; i < modules.size(); ++i) {
		vpiHandle vh_submodule = modules[i];
		vpi_printf("[%d] %-28s", i,  vpi_get_str(vpiFullName, vh_submodule));
		vpi_printf("\t%s\n", vpi_get_str(vpiDefName, vh_submodule));
	}
	vpi_printf("======================================================\n\n");

	inject_faults(vh_topmodule, num_faults);

	vpi_free_object(vh_arg_iter);
	return 0;
}


extern "C" PLI_INT32 calltf_inject_hlf_sub(PLI_BYTE8 *)
{
	s_vpi_value val;
	vpiHandle vh_systf, vh_arg_iter;

	std::srand(std::time(0));

	vh_systf = vpi_handle(vpiSysTfCall, NULL);
	if (!vh_systf) {
		vpi_printf("ERROR: Failed to obtain systf handle\n");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}
	vh_arg_iter = vpi_iterate(vpiArgument, vh_systf);
	if (!vh_arg_iter) {
		vpi_printf("ERROR");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}

	vpiHandle vh_topmodule = vpi_scan(vh_arg_iter);
	if (!vh_topmodule) {
		vpi_printf("ERROR");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}

	vpiHandle vh_const = vpi_scan(vh_arg_iter);
	if (!vh_const) {
		vpi_printf("ERROR getting topmodule");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}
	if(vpi_get(vpiConstType,vh_const) != vpiDecConst) {
		vpi_printf("ERROR expecting a decimal constant");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}
	val.format = vpiIntVal;
	vpi_get_value(vh_const,&val);

	int num_faults = val.value.integer;

	vh_const = vpi_scan(vh_arg_iter);
	if (!vh_const) {
		vpi_printf("ERROR getting topmodule");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}
	if(vpi_get(vpiConstType,vh_const) != vpiDecConst) {
		vpi_printf("ERROR expecting a decimal constant");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}
	val.format = vpiIntVal;
	vpi_get_value(vh_const,&val);

	int submodule_index = val.value.integer;

	vpi_printf("Top module: %s (%s)\nSub-module Index: %d", vpi_get_str(vpiFullName, vh_topmodule),
			vpi_get_str(vpiDefName, vh_topmodule), submodule_index);

	vector <vpiHandle> modules;
	bool lo = true; // leaves (submodules) only!
	int maxdepth = 2;

	traverse_vpi(vh_topmodule, vpiModule,
			bind([](vector<vpiHandle> *l, vpiHandle vh) { l->push_back(vh); }, &modules, _1 ), lo, maxdepth);

	vpi_printf("\n==Sub-modules:================\t==Instance of:==========\n");
	for(unsigned i = 0; i < modules.size(); ++i) {
		vpiHandle vh_submodule = modules[i];
		vpi_printf("[%d] %-28s", i,  vpi_get_str(vpiFullName, vh_submodule));
		vpi_printf("\t%s\n", vpi_get_str(vpiDefName, vh_submodule));
	}
	vpi_printf("======================================================\n\n");

	inject_faults(modules[submodule_index], num_faults, maxdepth);

//	for(auto mod : modules){
//	}

	vpi_free_object(vh_arg_iter);
	return 0;
}

int pli_check_args(const PLI_INT32 tf_args[], const size_t n)
{
	vpiHandle vh_systf, vh_arg_iter, vh_arg;
	PLI_INT32 arg_type;

	vh_systf = vpi_handle(vpiSysTfCall, NULL);
	if (!vh_systf) {
		vpi_printf("ERROR: Failed to obtain systf handle\n");
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}

	int arg;
	const int tf_args_size = n / sizeof(tf_args[0]);

	vh_arg_iter = vpi_iterate(vpiArgument, vh_systf);
	if (!vh_arg_iter) {
		if (tf_args_size) {
			vpi_printf("ERROR: task requires %d argument(s) but none provided\n", tf_args_size);
			vpi_control(vpiFinish, 0); /* abort simulation */
			return 0;
		} else
			return 0;
	}
	for(arg = 0; arg < tf_args_size; ++arg) {
		vh_arg = vpi_scan(vh_arg_iter);
		if (!vh_arg) {
			vpi_printf("ERROR: task requires %d argument(s) but %d provided\n", tf_args_size, arg);
//			vpi_free_object(vh_arg_iter); /* free iterator memory */
			vpi_control(vpiFinish, 0); /* abort simulation */
			return 0;
		}
		arg_type = vpi_get(vpiType, vh_arg);
		if (arg_type != tf_args[arg]) {
			vpi_printf("ERROR: argument %d must be of type %d but is %s\n", arg, tf_args[arg], vpi_get_str(vpiType, vh_arg));
//			vpi_free_object(vh_arg_iter); /* free iterator memory */
			vpi_control(vpiFinish, 0); /* abort simulation */
			return 0;
		}
	}

	vh_arg = vpi_scan(vh_arg_iter); // anything else left?
	if (vh_arg || (arg != tf_args_size)) {
		vpi_printf("ERROR: Extra argument! task requires only %d argument(s)\n", tf_args_size);
//		vpi_free_object(vh_arg_iter); /* free iterator memory */
		vpi_control(vpiFinish, 0); /* abort simulation */
		return 0;
	}

//	vpi_free_object(vh_arg_iter); /* free iterator memory */

	return 0;
}



extern "C" PLI_INT32 compiletf_inject_hlf(PLI_BYTE8 *)
{
	static const PLI_INT32 tf_args[] = {vpiModule, vpiConstant};
	return pli_check_args(tf_args,  sizeof(tf_args));
}

extern "C" PLI_INT32 compiletf_inject_hlf_sub(PLI_BYTE8 *)
{
	static const PLI_INT32 tf_args[] = {vpiModule, vpiConstant, vpiConstant};
	vpi_printf("SUB\n");
	return pli_check_args(tf_args,  sizeof(tf_args));
}


extern "C" PLI_INT32 sizetf_pli(PLI_BYTE8 *)
{
	return 0;
}


extern "C" void register_inject_hlf()
{
	// callbacks
	//        s_cb_data cb_data_s;
	//        vpiHandle callback_handle;
	//        cb_data_s.reason = cbStartOfSimulation;
	//        cb_data_s.cb_rtn = PLIbook_PowStartOfSim;
	//        cb_data_s.obj = NULL;
	//        cb_data_s.time = NULL;
	//        cb_data_s.value = NULL;
	//        cb_data_s.user_data = NULL;
	//        callback_handle = vpi_register_cb(&cb_data_s);
	//        vpi_free_object(callback_handle); /* don’t need callback handle */

	// task/functions
	s_vpi_systf_data tf_data;
	tf_data.type = vpiSysTask;
	tf_data.sysfunctype = 0;
	tf_data.tfname = "$inject_hlf";
	tf_data.calltf = calltf_inject_hlf;
	tf_data.compiletf = compiletf_inject_hlf;
	tf_data.sizetf = sizetf_pli;
	tf_data.user_data = nullptr;
	vpi_register_systf(&tf_data);

	return;
}

extern "C" void register_inject_hlf_sub()
{
	s_vpi_systf_data tf_data;
	tf_data.type = vpiSysTask;
	tf_data.sysfunctype = 0;
	tf_data.tfname = "$inject_hlf_sub";
	tf_data.calltf = calltf_inject_hlf_sub;
	tf_data.compiletf = compiletf_inject_hlf_sub;
	tf_data.sizetf = sizetf_pli;
	tf_data.user_data = nullptr;
	vpi_register_systf(&tf_data);

	return;
}

void (*vlog_startup_routines[])() = {
		register_inject_hlf,
		register_inject_hlf_sub,
		nullptr
};
