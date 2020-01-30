#!/usr/bin/env python

import pandas as pd

import rpca_cooc_benchmarking as rcb

def test_roc_curve():
    """
    Adjacency List:

     ---------
    | F1 | F2 |
    |----|----|       V1 V2 V3 V4 V5
    | V1 | V2 |    V1  0  1  1  1  0
    | V2 | V3 | -> V2  1  0  1  0  0
    | V1 | V4 |    V3  1  1  0  0  1
    | V1 | V3 |    V4  1  0  0  0  1
    | V5 | V4 |    V5  0  0  1  1  0
    | V3 | V5 |
     ---------

    Feature matrix:

         V1   V2   V3   V4   V5
    V1 0.00 1.23 2.43 1.15 0.06
    V2 1.23 0.00 3.46 0.75 0.89
    V3 2.43 3.46 0.00 2.25 1.44
    V4 1.15 0.75 2.25 0.00 3.55
    V5 0.06 0.89 1.44 3.55 0.00
    """
    feat_mat = pd.DataFrame([
        [0.00, 1.23, 2.43, 1.15, 0.06],
        [1.23, 0.00, 3.46, 0.75, 0.89],
        [2.43, 3.46, 0.00, 2.25, 1.44],
        [1.15, 0.75, 2.25, 0.00, 3.55],
        [0.06, 0.89, 1.44, 3.55, 0.00],
    ])

    f1 = [f"V{x}" for x in [1, 2, 1, 1, 5, 3]]
    f2 = [f"V{x}" for x in [2, 3, 4, 3, 4, 5]]
    df = pd.DataFrame([f1, f2]).T
    df.columns = ["F1", "F2"]
    fpr, tpr, thresholds = rcb.get_roc_curve(df, feat_mat, 5)
    print(fpr, tpr, thresholds)
    assert 0
