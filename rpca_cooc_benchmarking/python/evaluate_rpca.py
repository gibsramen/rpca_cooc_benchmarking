#!/usr/bin/env python

import numpy as np
import pandas as pd

from sklearn.metrics import roc_curve, auc

__all__ = ["rpca_thresholds"]


def rpca_thresholds(rpca_feat_mat, n=10):
    """Return n thresholds of rpca_feat_mat classifier."""
    min_val = rpca_feat_mat.min().min()
    max_val = rpca_feat_mat.max().max()
    return np.linspace(min_val, max_val, num=n)
