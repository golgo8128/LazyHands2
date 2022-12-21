# conda install -c conda-forge pythonnet
# pip install pythonnet
import sys
import clr

# Preparation for connection to dll
AGILENT_DLL_PATH = r'C:\Users\golgo\Desktop\MHDAC_MIDAC_Package_B.08.00_B8208.0\MHDAC_MIDAC_64bit\bin'
sys.path.append(AGILENT_DLL_PATH)  # Add dll folder to path
clr.AddReference('MassSpecDataReader')  # MassSpecDataReader.DLL

from Agilent.MassSpectrometry.DataAnalysis import MassSpecDataReader, IMsdrDataReader, \
    IBDAChromData, IBDASpecData

# Full path to .d file.
test_dot_d_file = r'C:\Users\golgo\Desktop\2018STDE-P-C-1.d'

# Generate MassSpecDataReader instance and read specified .d file
m_msdrDataReader = IMsdrDataReader(MassSpecDataReader())
m_msdrDataReader.OpenDataFile(test_dot_d_file)
tic = IBDAChromData(m_msdrDataReader.GetTIC())
num_mt = tic.TotalDataPoints  # Number of MTs

# Get n'th MassSpectrum
nth = 100
adck = IBDASpecData(m_msdrDataReader.GetSpectrum(nth, None, None))
mz_list        = [ float(mz_) for mz_ in adck.XArray ]
intensity_list = [ int(intsty_) for intsty_ in adck.YArray ]
time_range = (adck.get_AcquiredTimeRange().GetValue(0).Min,
              adck.get_AcquiredTimeRange().GetValue(0).Max)

print(time_range)
print(mz_list[0:10] + ["..."] + mz_list[-11:-1])
print(intensity_list[0:10] + ["..."] + intensity_list[-11:-1])
