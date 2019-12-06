#!/usr/bin/env python
"""This module contains the code to extract relevant parameters from PCL
files produced by sparseDOSSA.
"""

from abc import abstractmethod
import re
from typing import Set

import numpy as np
import pandas as pd


class PCLFile():
    """Base class for PCL files"""

    def __init__(self, filelocation: str, filetype: None):
        self.filelocation = filelocation
        with open(self.filelocation, "r") as this_file:
            self._contents = this_file.read().splitlines()
        self.filetype = filetype

    def __str__(self):
        print(f"PCLFile: {self.filelocation}")

    @abstractmethod
    def process(self):
        """Process PCLFile"""
        return


class PCLParamFile(PCLFile):
    """sparseDOSSA parameter file"""

    def __init__(self, filelocation: str):
        super().__init__(filelocation, "Parameter")
        self.correlated_bugs, self.corr_coefs = self.get_bug_bug_info()

    def process(self):
        return

    def get_bug_bug_info(self):
        """Get correlations and coefficients"""
        bug_bug_start_str = "SyntheticMicrobiomeBugToBugAssociations"
        bug_bug_info = self._contents[self._contents.index(bug_bug_start_str):]
        bug_corr_str = [x for x in bug_bug_info if x.startswith("Indices")]
        bug_corr_indices = [re.findall(r"\d+", x) for x in bug_corr_str]
        correlated_bugs = dict(zip(*bug_corr_indices))

        bug_corr_val_start_str = "Specified correlation"
        bug_corr_val_str = next(
            x for x in bug_bug_info if x.startswith(bug_corr_val_start_str)
        )
        corr_coefs = re.findall(r"[\d\.]+", bug_corr_val_str)

        return correlated_bugs, corr_coefs


class PCLAbundanceFile(PCLFile):
    """Base class for PCL abundance files"""

    def __init__(self, filelocation: str):
        super().__init__(filelocation, "Abundance")
        self.samples = self.get_samples()
        self.datatypes = self.get_data_types()
        print(f"Data types: {self.datatypes}")

    def process(self):
        return

    def get_samples(self) -> Set[str]:
        """Get sample names from simulated data"""
        samples = self._contents[0].split("\t")[1:]
        return set(samples)

    def get_data_types(self) -> Set[str]:
        """Get types of data from simulated data"""
        first_col = [x.split("\t")[0] for x in self._contents]
        datatypes = set()
        for value in first_col:
            underscore_index = value.rfind("_")
            if underscore_index == "-1":
                datatype = value
            else:
                datatype = value[:underscore_index]
            datatypes.add(datatype)
        return datatypes
