#!/usr/bin/env python

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd

from sklearn.metrics import roc_curve, roc_auc_score

from . import util

def get_roc_curve(adj_df, feat_mat, n):
    n = feat_mat.shape[0]
    m = feat_mat.max().max()
    feat_mat = feat_mat - m
    feat_mat = feat_mat.abs()
    truth_class = util.adj_list_to_class(adj_df, n)
    test_class = util.reshape_mat(feat_mat)

    print(len(truth_class), len(test_class))

    fpr, tpr, thresholds = roc_curve(
        y_true=truth_class,
        y_score=test_class,
    )

    auc_score = roc_auc_score(
        y_true=truth_class,
        y_score=test_class,
    )
    return fpr, tpr, thresholds, auc_score

def plot_roc(fpr, tpr, thresholds, auc_score, **kwargs):
    plt.rcParams["font.family"] = "sans-serif"
    plt.rcParams["font.sans-serif"] = "DejaVu Sans"
    fig, ax = plt.subplots(1, 1, figsize=(10, 10))

    ax.plot(fpr, tpr, color="darkorange")
    ax.plot([0, 1], [0, 1], linestyle="--", color="black")
    ax.set_title(f"AUC: {round(auc_score, 2)}")

    plt.savefig("test.png", dpi=300)
