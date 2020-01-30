#!/usr/bin/env python

import numpy as np
import pandas as pd
import pytest

from rpca_cooc_benchmarking import util as rcb

@pytest.fixture(scope="module")
def example_adj_df():
    F1 = ["V1", "V2", "V3", "V4"]
    F2 = ["V2", "V3", "V1", "V1"]
    df = pd.DataFrame([F1, F2]).T
    df.columns = ["F1", "F2"]

    return df

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

def test_adj_loading(example_adj_df):
    loaded_edges = rcb.load_adj_list(example_adj_df)
    truth_edges = [
        rcb.Edge("V1", "V2"),
        rcb.Edge("V2", "V3"),
        rcb.Edge("V3", "V1"),
        rcb.Edge("V4", "V1"),
    ]
    assert loaded_edges == truth_edges

def test_reshape_mat():
    mat = [
        [0, 0, 1, 0],
        [0, 0, 0, 1],
        [1, 0, 0, 0],
        [0, 1, 0, 0],
    ]

    df = pd.DataFrame(mat)
    reshaped_vector = rcb.reshape_mat(df)
    target_vector = [0, 1, 0, 0, 1, 0]

    assert reshaped_vector == target_vector

def test_reshape_mat_non_symm():
    mat = [
        [0, 0, 1, 0],
        [1, 0, 0, 1],
        [1, 0, 0, 0],
        [0, 1, 0, 0],
    ]

    df = pd.DataFrame(mat)
    with pytest.raises(ValueError):
        rcb.reshape_mat(df)

def test_adj_list_to_class(example_adj_df):
    """
    F1 = ["A", "B", "C", "D"]
    F2 = ["B", "C", "A", "A"]

     ---------
    | F1 | F2 |
    |----|----|      A B C D
    | A  | B  |    A 0 1 1 1
    | B  | C  | -> B 1 0 1 0
    | C  | A  |    C 1 0 0 0
    | D  | A  |    D 1 0 0 0
     ---------

    Target: [1, 1, 1, 0, 0, 0]
    """
    test_values = rcb.adj_list_to_class(example_adj_df, 4)
    target_values = [1, 1, 1, 1, 0, 0]
    assert test_values == target_values
