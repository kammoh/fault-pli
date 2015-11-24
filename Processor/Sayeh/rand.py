#!/usr/bin/python -tt

from random import randint

def main():
    fo = open('outputs.hex', 'w')
    count = 0
    l = []
    print '.data data\t',
    for i in [randint(0,0xffff) for x in range(50) ]:
        l.append(i)
        print '0x%.4x' % i ,
        if (count % 8) == 7:
            print ' \\\n\t\t\t',
        count += 1
    print '\n\n----------\n\n'
    for i in range(len(l) - 1):
        print >>fo, '%.4x' % ((l[i] + l[i+1]) & 0xFFFF )
        
if __name__ == '__main__':
    main()
