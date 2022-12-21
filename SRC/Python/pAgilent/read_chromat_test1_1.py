# pip install pythonnet
import sys
import clr

# Preparation for connection to dll
AGILENT_DLL_PATH = r'C:\Program Files\Agilent\MassHunter\Workstation\Qual\10.0\Bin'
sys.path.append(AGILENT_DLL_PATH) # Add dll folder to path
clr.AddReference('MassSpecDataReader') # MassSpecDataReader.DLL

from Agilent.MassSpectrometry.DataAnalysis import MassSpecDataReader, IMsdrDataReader, \
    IBDAChromFilter, BDAChromFilter, IBDAChromData, MinMaxRange, ChromType

# Full path to .d file.
test_dot_d_file  = r'D:\Data\Metabolome\Test\2018STDE-P-C-1.d'


m_msdrDataReader = IMsdrDataReader(MassSpecDataReader())
m_msdrDataReader.OpenDataFile(test_dot_d_file)

mz_range_filter = IBDAChromFilter(BDAChromFilter())
mz_range_filter.set_ChromatogramType(ChromType.BasePeak) # BasePeak
mass_range = MinMaxRange()
mass_range.Min = 182.4
mass_range.Max = 182.5
mass_scan_range_list = [mass_range, ]
mz_range_filter.set_IncludeMassRanges(mass_scan_range_list)
chrom_list = m_msdrDataReader.GetChromatogram(mz_range_filter)
chrom = IBDAChromData(chrom_list[0])

from pprint import pprint

pprint(list(zip(chrom.XArray, chrom.YArray)))
