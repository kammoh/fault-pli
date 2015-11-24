#!/usr/bin/python -tt

import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

data = pd.read_csv('data.csv', header=None, sep='[ ]')

# print data.values
       
percent = [ (float(x[0])*np.array(x[1:]))/sum(x[1:])  for x in data.values ]

df2 = pd.DataFrame(percent, columns=['Sayeh', 'DataPath', 'AddressingUnit', 'ProgramCounter',
                                      'AddressLogic', 'ArithmeticUnit', 'RegisterFile', 
                                      'InstructionRegister', 'StatusRegister', 'WindowPointer', 'controller'])

# df2 = pd.DataFrame(percent, columns=['ArithmeticUnit'])


plt.rc('legend',**{'fontsize':10})
df2.plot(kind='bar', stacked=True, colormap=plt.cm.bone, legend=False )

plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
       ncol=4, mode="expand", borderaxespad=0., shadow=True)
plt.ylim([0, 100.4])
fileName = 'results.eps'

plt.subplots_adjust(top=.8, bottom=0.09, left=.1, right=.95)
plt.ylabel('% Erroneous Output')
plt.xlabel('Iteration')
plt.savefig( fileName, format="eps" )

plt.show()