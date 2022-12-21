#!/usr/bin/env python

import sys
from collections import OrderedDict
import clr  # pip install pythonnet

# Preparation for connection to dll
# AGILENT_DLL_PATH = r'C:\Program Files\Agilent\MassHunter\Workstation\Qual\10.0\Bin'
# AGILENT_DLL_PATH = r'C:\Program Files\Agilent\MassHunter\Workstation\Qual\B.08.00\Bin'
AGILENT_DLL_PATH = r'C:\WinAppl\Agilent\MHDAC_MIDAC_Package_B.08.00_B8208.0\MHDAC_MIDAC_64bit\bin'
sys.path.append(AGILENT_DLL_PATH)  # Add dll folder to path
clr.AddReference('MassSpecDataReader')  # MassSpecDataReader.DLL

from Agilent.MassSpectrometry.DataAnalysis import MassSpecDataReader, IMsdrDataReader, \
    IBDAChromFilter, BDAChromFilter, IBDAChromData, IBDASpecData, MinMaxRange, ChromType

from Data_Struct.ArraysRange1 import ArraysRange_SortedNonRedu

class Agilent_dot_d:
    def __init__(self, idot_d_file):

        self.m_msdrDataReader = IMsdrDataReader(MassSpecDataReader())
        self.m_msdrDataReader.OpenDataFile(idot_d_file)

        tic = IBDAChromData(self.m_msdrDataReader.GetTIC())
        self.num_mts = tic.TotalDataPoints  # Number of MTs

        self.dot_d_file = idot_d_file

    def gen_chromat_objs(self, imz_mins, imz_maxs,
                         ichromtype=ChromType.ExtractedIon):
        # ChromType.BasePeak

        mz_range_filter = IBDAChromFilter(BDAChromFilter())
        mz_range_filter.set_ChromatogramType(ichromtype)

        mass_scan_range_list = []

        for i, (mz_min, mz_max) in enumerate(zip(imz_mins, imz_maxs)):
            mass_range = MinMaxRange()
            mass_range.Min = mz_min
            mass_range.Max = mz_max
            mass_scan_range_list.append(mass_range)

        mz_range_filter.set_IncludeMassRanges(mass_scan_range_list)
        chrom_obj_list = self.m_msdrDataReader.GetChromatogram(mz_range_filter)

        return [IBDAChromData(chrom_obj) for chrom_obj in chrom_obj_list]

    def gen_chromats(self, imz_mins, imz_maxs, odat_mode = "normal"):

        chrom_list = self.gen_chromat_objs(imz_mins, imz_maxs)

        mz_min_max_to_chromat = {}
        for chrom in chrom_list:
            cmz_min = chrom.get_MeasuredMassRange()[0].Min  # Only the first one considered
            cmz_max = chrom.get_MeasuredMassRange()[0].Max  # Only the first one considered

            if odat_mode == "rangeobj":
                chromat_dat = ArraysRange_SortedNonRedu(
                    [ list(chrom.XArray), list(chrom.YArray) ]
                )
            else:
                chromat_dat = {
                "MTs": list(chrom.XArray),
                "intensities": list(chrom.YArray)
            }

            mz_min_max_to_chromat[cmz_min, cmz_max] = chromat_dat

        return mz_min_max_to_chromat

    def gen_mspectra(self, odat_mode = "normal"):

        mt_to_mspectrum_h = OrderedDict()

        for mt_idx in range(0, self.num_mts):
            adck = IBDASpecData(self.m_msdrDataReader.GetSpectrum(mt_idx, None, None))
            mt = adck.get_AcquiredTimeRange().GetValue(0).Min  # or Max

            if odat_mode == "rangeobj":
                mspectrum_dat = ArraysRange_SortedNonRedu(
                    [ list(adck.XArray), list(adck.YArray) ]
                )
            else:
                mspectrum_dat = {
                "m/z's": list(adck.XArray),
                "intensities": list(adck.YArray)
                }

            mt_to_mspectrum_h[mt] = mspectrum_dat

            if mt_idx % 100 == 0:
                print("[ Progress ] Read spectrum at {mt} (File: {filnam})".format(
                    mt=mt, filnam=self.dot_d_file))
                # break

        # print(adck.get_AcquiredTimeRange().GetValue(0).Min,
        #       adck.get_AcquiredTimeRange().GetValue(0).Max)

        return mt_to_mspectrum_h

    def __del__(self):

        self.m_msdrDataReader.CloseDataFile()


if __name__ == "__main__":
    import matplotlib.pyplot as plt
    from FileDirPath.rsFilePath1 import RSFPath

    # Full path to .d file.
    # test_dot_d_file  = r'D:\Data\Metabolome\Test\2018STDE-P-C-1.d'
    test_dot_d_file = RSFPath("PROJ", "MasterHands", "Examples", "kiff_files1",
                              "101-QCE-P-C-5.d")

    tmp_adotd = Agilent_dot_d(test_dot_d_file)
    tmp_chromats = tmp_adotd.gen_chromats([181, 182], [182, 183])
    tmp_mspectra = tmp_adotd.gen_mspectra()
