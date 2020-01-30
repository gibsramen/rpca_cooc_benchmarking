#!/usr/bin/env python

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

def load_adj_list(adj_df):
    edge_list = [Edge(row.F1, row.F2) for i, row in adj_df.iterrows()]
    return edge_list
