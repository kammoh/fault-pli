#!/usr/bin/python -tt

import os
import sys
import re

gp_registers = ['r0', 'r1', 'r2', 'r3']

cat0_ops = ['nop', 'hlt', 'szf', 'czf', 'scf', 'ccf', 'cwp' ]

cat1_ops = [None, 'mvr', 'lda', 'sta', 'inp', 'oup' , 'and', 
            'orr', 'not', 'shl', 'shr', 'add', 'sub', 'mul', 'cmp']

cat2_ops = ['mil', 'mih', 'spc', 'jpa']

cat3_ops = ['jpr' , 'brz', 'brc', 'awp']



data_segs = {}
data_section = []
all_vars = {}

def do_fill(output, filler = 0x0F):
    if output and len(output[-1]) == 1: # last instruction was single byte
        output[-1].append(filler)

def resolve_label(values):
#     print "values: ", values
    for index, val in enumerate(values):
        values[index] = eval(val, all_vars ) if isinstance(val, str) else val
    return values

def assemble(fi):
    labels = {}
    line_num = 0
    output = []
    next_data_offset = 0
    

    while True:

        line_read = fi.readline()
        line_num += 1
        if not line_read: # End of File
            break
        line_read = line_read[0:line_read.find(';')].strip()
        if not line_read:
            continue

        line = ''
        while line_read and line_read[-1] == '\\':
            line += line_read[:-1]
            line_read = fi.readline()
            line_num += 1
            # TODO? what if EOF?
            line_read = line_read[0:line_read.find(';')].strip()

        line += line_read

        #print "line read is: ", line,
        #print '<<<<'
        
        parts = filter(bool, re.split('[ \t,]', line) )
        
        if not parts:
            continue

        if parts[0] == '.data':
            print "parts:", parts
            if len(parts) < 3:
                sys.exit('line %d: format:  .data <var-name> <values> ') % (line_num)
            data_name = parts[1]
            
            if data_name in data_segs.keys(): # dublicate
                sys.exit('line %d: Duplicate data section: %s') % (line_num, data_name)
            
            data =  [eval("0x" + d,{}) for d in parts[2:]]

            data_segs[data_name] = next_data_offset
            next_data_offset += len (data)
            #print "data: ", data

            data_section.extend(data)
            #print "data_secion now: ", data_section
            continue
            
        elif parts[0][-1] == ':' and parts[0][0].isalpha():
            # A label was found
            label = parts[0][:-1]
            if label in labels.keys(): # dublicate
                sys.exit('line %d: Duplicate label: %s') % (line_num, label)
            do_fill(output)
            labels[label] = len(output)
            parts = parts[1:]                          
            if not parts:
                continue
        
        opcode = parts[0]
        machine_code = 0
        operands = parts[1:]
        byteValues = []
        
        try: # cat0
            machine_code = cat0_ops.index(opcode)
            if operands:
                sys.exit('line %d: opcode %s does not expect any operands' % (line_num, opcode))
        except ValueError:
            try: # cat1 (or up)
                tmp_code = cat1_ops.index(opcode)
                # print opcode, tmp_code 
                # print  operands, operands[0], operands[1]
                if len(operands) == 2 and operands[0] in gp_registers and operands[1] in gp_registers:
                    dst, src = gp_registers.index(operands[0]), gp_registers.index(operands[1])
                    #print ">>> %X %X %X" % (tmp_code , dst , src)
                    machine_code =  (tmp_code << 4) + (dst << 2) + src
                else:
                    sys.exit("opcode '%s' at line %d expects Destination and Source registers" % (opcode, line_num))
            except IndexError:
                sys.exit("<index-error> opcode '%s' at line %d expects Destination and Source registers" % (opcode, line_num))
            except ValueError: # cat2
                try: # cat2
                    tmp_code = cat2_ops.index(opcode)
                    if len(operands) == 2 and operands[0] in gp_registers:
                        dst, imm = gp_registers.index(operands[0]), operands[1]
                        machine_code = 0xf0 + (dst << 2) + tmp_code
                        byteValues.append(imm)
                    else:
                        sys.exit("opcode '%s' at line %d expects Destination register and Immediate value" % (opcode, line_num))
                except ValueError:
                    try: # cat3
                        tmp_code = cat3_ops.index(opcode)
                        imm = operands[0] # TODO
                        machine_code = 7 + tmp_code
                        byteValues.append(imm)
                    except ValueError:
                        sys.exit("Invalid opcode '%s' at line %d" % (opcode, line_num))
        byteValues.insert(0, machine_code)
        
        # commit to output
        if output and len(output[-1]) == 1: # previous instruction was single byte
            if len(byteValues) == 1: # new instruction is single byte too
                output[-1].append(byteValues[0])
            else:
                output[-1].append(0x0F)
                output.append(byteValues)
        else:
            output.append(byteValues)
        ####### while True
    do_fill(output)
     
    for d_name in data_segs.keys():
        all_vars[d_name] = (data_segs[d_name] +  len(output))
    all_vars.update(all_vars, **labels)
    
#     print all_vars

    return map(resolve_label, output)

def main(argv):
    line_width = 40
    print '\n\n'
    print '  +' + '-' * (line_width-2) + '+'
    print '  |' + ' '*(line_width - 2) + "|"
    print '  |' + "S A Y E H   Assembler".center(line_width - 2) + "|"
    print '  |' + ' '*(line_width - 2) + "|"
    print '  |' + "[kamyar@ieee.org]".center(line_width - 2) + "|"
    print '  |' + ' '*(line_width - 2) + "|"
    print '  +' +  "-" * (line_width-2) + '+'
    print '\n\n'
    
    asmfile = argv[0]
    
    if len(argv) == 1:
        hexfile = os.path.splitext(os.path.basename(asmfile))[0] + '.hex'
    elif len(argv) == 2:
        hexfile = argv[1]
    else:
        sys.exit("Usage:\tsasm.py <input.asm> [<output.hex>] \n")

    
    if not os.path.exists(asmfile):
        sys.exit("File not found: %s" % asmfile)

    try:
        fi = open(asmfile, 'rU')
    except IOError, e:
        sys.exit(e)

    output = assemble(fi)
    fi.close()

    try:
        fo = open(hexfile, 'w')
    except IOError, e:
        sys.exit(e)

    for instruction in output:
        #print instruction
        print >>fo, "%.2x%.2x" % (instruction[0],instruction[1])
    
    for dd in data_section:
        print >>fo, "%.4x" % dd

    print "Assembler completed successfully. Output written to '%s'" % hexfile
    fo.close()

if __name__ == '__main__':
    main(sys.argv[1:])
