#!/usr/bin/env python
"""Test PCL processing"""

import pytest

from rpca_cooc_benchmarking import pcl

REL_AB_FILE = "data/SyntheticMicrobiome.pcl"
COUNT_FILE = "data/SyntheticMicrobiome-Counts.pcl"
PARAM_FILE = "data/SyntheticMicrobiomeParameterFile.txt"


class TestPCLClass():

    def test_rel_ab_file_instantiation(self):
        """Make sure instantiation works"""
        pcl.PCLAbundanceFile(REL_AB_FILE, "Relative Abundance")

    def test_count_file_instantiation(self):
        """Make sure instantiation works"""
        pcl.PCLAbundanceFile(COUNT_FILE, "Count")

    def test_param_file_instantiation(self):
        """Make sure instantiation works"""
        pcl.PCLParamFile(PARAM_FILE)


class TestPCLData():

    def test_get_data(self):
        """Make sure data can be extracted"""
        p = pcl.PCLAbundanceFile(COUNT_FILE, "Count")
        log_normal = p.get_data("Feature_BugToBugAssociations_a_5_d_1")
        assert log_normal.shape == (300, 50)
