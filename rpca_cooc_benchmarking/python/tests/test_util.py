#!/usr/bin/env python

import numpy as np
import pandas as pd

from rpca_cooc_benchmarking import util as rcb

def test_edge_equality():
    edge1 = rcb.Edge("A", "B")
    edge2 = rcb.Edge("A", "B")
    edge3 = rcb.Edge("B", "A")

    assert edge1 == edge2
    assert edge1 == edge3

def test_edge_inequality():
    edge1 = rcb.Edge("A", "B")
    edge2 = rcb.Edge("A", "C")
    edge3 = rcb.Edge("B", "C")

    assert edge1 != edge2
    assert edge1 != edge3

def test_adj_loading():
    F1 = ["A", "B", "C", "D"]
    F2 = ["B", "C", "A", "A"]
    df = pd.DataFrame([F1, F2]).T
    df.columns = ["F1", "F2"]

    loaded_edges = rcb.load_adj_list(df)

    truth_edges = [
        rcb.Edge("A", "B"),
        rcb.Edge("B", "C"),
        rcb.Edge("C", "A"),
        rcb.Edge("D", "A"),
    ]
    assert loaded_edges == truth_edges
