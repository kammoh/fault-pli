#!/usr/bin/env python

from matplotlib import pylab
import matplotlib.colors as colors
import matplotlib.cm as cmx
import sys

infile = open('data_sub.csv', 'rU')

pylab.ylabel('% Erroneous Output')
# plt.xlabel('Iteration')
pylab.title("Per module fault")



last_module = -1
last_faults = -1
sums = 0
count = 0
x = 0
prev_x = 0

tick_locs = []
tick_labels = []

# pylab.subplot(1,0,1)
number_of_submodules = 7
rows = 2

cNorm  = colors.Normalize(vmin=0, vmax=number_of_submodules+1)
scalarMap = cmx.ScalarMappable(norm=cNorm, cmap=pylab.cm.prism)

colors=['palevioletred', 'mediumseagreen', 'tan',
         'rosybrown', 'lightcoral', 'slateblue', 'teal', 'mistyrose', 'lightsteelblue']

modules = ['AddressingUnit', 'ArithmeticUnit', 'RegisterFile', 
                                      'InstructionRegister', 'StatusRegister', 'WindowPointer', 'controller']
def plot_avg():
    
    pylab.bar( prev_x ,sums / count , x - prev_x, color = colorVal, alpha=0.6)
    tick_locs.append( ( float(x) + prev_x) / 2.0 )
    tick_labels.append( '%s' % last_faults) 

# pylab.ylabel('%Erroneous Output')
pylab.subplots_adjust(top=.93, bottom=0.05, left=0.05, right=.98, hspace = 0.3, wspace = 0.25)

fig = pylab.gcf()
# fig.set_size_inches(18.5,10.5)
pylab.figure(num=1, figsize=(12, 6), dpi=800, background='w', facecolor='w', edgecolor='k')

for line in infile.readlines():
    d = line.split();
    p = float(d[0])
    m = int(d[1])
    if d[1] != last_module or d[2] != last_faults:
        if sums:
            plot_avg()
            x += 4
            prev_x = x
        sums = p
        count = 1
    else:
        sums += p
        count += 1
    
    if d[1] != last_module:
        pylab.xticks(tick_locs, tick_labels)
        #### new plot
        pylab.subplot(rows, (number_of_submodules+rows-1)/rows, m+1 )
        colorVal = scalarMap.to_rgba(m)
        colorVal = colors[m]
        pylab.title(modules[m], color = colorVal,weight='medium')

#         pylab.xlabel('Faults')
        ticks_locs = []
        tick_labels = []
        x = prev_x = 0
#     print '---', count , i , p
#     print line
    colorVal = scalarMap.to_rgba(m)
    colorVal = colors[m]
    pylab.bar( x  ,p , 1, alpha=1, color = colorVal)
    x += 1
    last_module = d[1]
    last_faults = d[2]
    
if sums:
    plot_avg()
    pylab.xticks(tick_locs, tick_labels)
#     pylab.yticks(range(0, 101, 10))
#     pylab.title(modules[int(d[1])])
# pylab.gca().set_xticks(x + w / 2)
# pylab.gca().set_ylim( bottom=0, top=100)

fileName = 'result_sub.eps'
pylab.savefig( fileName, format="eps" )
pylab.show()