#!/usr/bin/env python
"""This module contains the code to extract relevant parameters from PCL
files produced by sparseDOSSA.
"""

from abc import abstractmethod
import re
from typing import Dict, List, Set

import pandas as pd


class PCLFile():
    """Base class for PCL files"""

    def __init__(self, filelocation: str, filetype: None):
        self.filelocation = filelocation
        with open(self.filelocation, "r") as this_file:
            self._contents = this_file.read().splitlines()
        self.filetype = filetype

    def __str__(self):
        return f"{type(self).__name__}: {self.filelocation}"


class PCLParamFile(PCLFile):
    """sparseDOSSA parameter file"""

    def __init__(self, filelocation: str):
        super().__init__(filelocation, "Parameter")
        self.correlated_bugs, self.corr_coefs = self.get_bug_bug_info()

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

    def __init__(self, filelocation: str, filetype: str):
        super().__init__(filelocation, filetype)
        self.samples = self.get_samples()
        self.datatypes = self.get_data_types()
        self._matrix_dict = self.get_matrices()
        print(f"Data types: {self.datatypes}")

    def get_data(self, datatype: str) -> pd.DataFrame:
        """Return data from PCL file"""
        return self._matrix_dict[datatype]

    def get_matrices(self) -> Dict[str, pd.DataFrame]:
        """Extract data for each data type"""
        matrix_dict = dict()
        for datatype in self.datatypes:
            data = [x for x in self._contents if x.startswith(datatype)]
            data = [x.split("\t") for x in data]
            data = pd.DataFrame(data)
            data.set_index(0, drop=True, inplace=True)
            data.index.name = datatype
            data.columns = self.samples

            matrix_dict[datatype] = data
        return matrix_dict

    def get_samples(self) -> List[str]:
        """Get sample names from simulated data"""
        samples = self._contents[0].split("\t")[1:]
        return samples

    def get_data_types(self) -> Set[str]:
        """Get types of data from simulated data"""
        first_col = [x.split("\t")[0] for x in self._contents[1:]]
        first_col = [x for x in first_col if not x.startswith("Metadata")]
        datatypes = set()
        for value in first_col:
            underscore_index = value.rfind("_")
            if underscore_index == "-1":
                datatype = value
            else:
                datatype = value[:underscore_index]
            datatypes.add(datatype)
        return datatypes
