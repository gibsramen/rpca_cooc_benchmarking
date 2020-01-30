#!/usr/bin/env python

import numpy as np

class Edge:

    def __init__(self, node1: str, node2: str):
        if node1 == node2:
            raise(ValueError("Cannot instantiate self-edge!"))
        self.node1 = node1
        self.node2 = node2

    def __eq__(self, other):
        sort_edge1 = sorted([self.node1, self.node2])
        sort_edge2 = sorted([other.node1, other.node2])

        return sort_edge1 == sort_edge2

    def __str__(self):
        return f"{self.node1}--{self.node2}"

    def __repr__(self):
        return(self.__str__())

def load_adj_list(adj_df):
    edge_list = [Edge(row.F1, row.F2) for i, row in adj_df.iterrows()]
    return edge_list

def reshape_mat(mat):
    """Collapse symmetric matrix into upper triangular vector."""

    # check for symmetry
    if not np.allclose(mat, mat.T, rtol=1e-05, atol=1e-08):
        raise(ValueError("Matrix is not symmetric!"))

    n = mat.shape[0]

    values = list()
    for i in range(0, n - 1):
        for j in range(i + 1, n):
            values.append(mat.iloc[i][j])

    return values

def adj_list_to_class(adj_df, n):
    """Convert list of edges to binary list for roc."""
    values = list()
    edge_list = load_adj_list(adj_df)

    for i in range(1, n):
        for j in range(i + 1, n + 1):
            test_edge = Edge(f"V{i}", f"V{j}")
            values.append(int(test_edge in edge_list))

    return values
