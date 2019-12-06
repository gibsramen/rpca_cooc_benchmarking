#!/usr/bin/env python
"""Test PCL processing"""

import pytest

from rpca_cooc_benchmarking import pcl

REL_AB_FILE = "data/SyntheticMicrobiome.pcl"
COUNT_FILE = "data/SyntheticMicrobiome-Counts.pcl"
PARAM_FILE = "data/SyntheticMicrobiomeParameterFile.txt"


class TestPCLClass():

    @pytest.mark.parametrize("pclfile", [COUNT_FILE, REL_AB_FILE])
    def test_abundance_file_instantiation(self, pclfile):
        """Make sure instantiation works"""
        pcl.PCLAbundanceFile(pclfile)

    def test_param_file_instantiation(self):
        """Make sure instantiation works"""
        pcl.PCLParamFile(PARAM_FILE)
