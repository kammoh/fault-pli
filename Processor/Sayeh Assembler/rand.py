import sys
import random

def main(argv):
    insts = ['and', 'orr', 'not']
    for i in range(0, 25):
        print "\t" + insts[random.randint(0,len(insts)-1)] + "\t" + "r0, r1"

if __name__ == '__main__':
        main(sys.argv[1:])

