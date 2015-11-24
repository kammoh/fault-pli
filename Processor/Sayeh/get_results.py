#!/usr/bin/python -tt
import sys
from subprocess import *

mem_dump = 'OutputRAM.hex'
golden_mem_dump = 'OutputRAM.hex.Golden'


def main_fault():
    iterations = 10
    num_faults = 5
    csv_file = open('data_main.csv', 'w')
    for i in range(iterations):
        process = Popen(['make', 'vsim_main_fault'], env={'NUM_FAULTS':str(num_faults) , "PATH": '/home/kamyar/.local/bin/:/usr/local/bin:/usr/bin'}, stdout=PIPE)
        
        if process.wait() != 0:
            sys.exit("There were some errors");
        
        results = []
        for outline in process.stdout:
            parts = outline.split()
            if len(parts) > 2 and parts[1] == 'FAULTVECTOR>>':
                results.extend(parts[2:])
                break
        
        dump = open(mem_dump)
        golden = open(golden_mem_dump)
        
        start = 85
        end = 134
        d = dump.readlines()[start:end]
        g = golden.readlines()[start:end]
        
        
        diffs = 0
        for l1, l2 in zip(d, g):
            if l1.strip() <> l2.strip():
                #print l1.strip() , l2.strip()
                diffs += 1;
        
        
        results.insert(0, '%.2f'% ( diffs * 100.0/(end - start) ))
        for r in results:
            print >>csv_file, r,
        print >>csv_file
        
        csv_file.flush()
        
def sub_fault():
    iterations = 5
    number_of_submodules = 7 # config
    csv_file = open('data_sub.csv', 'w')
    for sub_index in range(number_of_submodules):
        for num_faults in [1, 2, 3, 5]:
            for i in range(iterations):
                process = Popen(['make', 'vsim_sub_fault'], 
                                env={'NUM_FAULTS':str(num_faults) 
                                     ,'SUBMODULE':str(sub_index)
                                     , "PATH": '/home/kamyar/.local/bin/:/usr/local/bin:/usr/bin'}
                                , stdout=PIPE)
                
                if process.wait() != 0:
                    sys.exit("There were some errors");
                
                results = [sub_index, num_faults]
                for outline in process.stdout:
                    print outline,
                    parts = outline.split()
                    if len(parts) > 2 and parts[1] == 'FAULTVECTOR>>':
                        results.extend(parts[2:])
                        break
                
                dump = open(mem_dump)
                golden = open(golden_mem_dump)
                
                start = 85
                end = 134
                d = dump.readlines()[start:end]
                g = golden.readlines()[start:end]
                
                
                diffs = 0
                for l1, l2 in zip(d, g):
                    if l1.strip() <> l2.strip():
                        #print l1.strip() , l2.strip()
                        diffs += 1;
                
                
                results.insert(0, '%.2f'% ( diffs * 100.0/(end - start) ))
                for r in results:
                    print >>csv_file, r,
                print >>csv_file
                
                csv_file.flush()
                
def main(argv):         
    if len(argv) != 1:
        sys.exit("Usage:get_results main/subs \n")
    if argv[0] == 'subs':
        sub_fault()
    elif argv[0] == 'main':
        main_fault()
    else:
        sys.exit("argument should be either 'main' or 'subs' \n")

if __name__ == '__main__':
    main(sys.argv[1:])