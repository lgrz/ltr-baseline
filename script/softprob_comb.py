
import sys
import ast
import numpy as np

if len(sys.argv) != 3:
    print("usage: {} <predictions> <num classes>".format(sys.argv[0]))
    exit(1)

fname = sys.argv[1]
num_class = ast.literal_eval(sys.argv[2])
pred = np.loadtxt(sys.argv[1])
pred = pred.reshape(int(pred.shape[0] / num_class), num_class)
comb = np.dot(pred, np.arange(num_class))
fname = fname + ".softprob"
np.savetxt(fname, comb)
