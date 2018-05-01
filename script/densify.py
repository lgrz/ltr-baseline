
import sys
import numpy as np

from sklearn.datasets import load_svmlight_file

if len(sys.argv) != 2:
    print("usage: {} <svmfile>".format(sys.argv[0]))
    exit(1)

X, y, qid = load_svmlight_file(sys.argv[1], query_id=True)
XX = X.todense()
with open(sys.argv[1] + ".dense", 'w') as f:
    for i, row in enumerate(XX):
        line = "{} qid:{} ".format(int(y[i]), qid[i])
        # features start from 1 for RankLib
        svm_row = ["{}:{}".format(j + 1, val) for j, val in enumerate(map(str, row.tolist()[0]))]
        line = line + " ".join(svm_row)
        f.write(line + "\n")
