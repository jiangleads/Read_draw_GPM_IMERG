#!/usr/bin/env python
# -*- coding: utf-8 -*-
# 查找最小和最大的降水量precipitationCal
# @Time    : 2019/2/28 17:28
# @Author  : zengsk in HoHai
# @File    : Calc_AVG_IMERG.py

'''
Calculating the average precipitation over a given region
'''

# Import packages
import os
import h5py
import numpy as np
import pandas as pd
import warnings

warnings.simplefilter("ignore")

# header
header = '''ncols         3600
nrows         1800
xllcorner     -180
yllcorner     -90
cellsize      0.1
NODATA_value  -999.0'''

# dataset directory
sPath = r'/home/jlz/2018nov/gpm/hhr/'

## mask region
#mask = pd.read_table(r'.\assets\china_mask_gpm_01.txt', sep='\s+', header=None, skiprows=6).values

#rain = np.empty([1800, 3600], dtype=float)
#tag = np.empty(rain.shape, dtype=float)     # Record the effective precip times per grid

Files = os.listdir(sPath)
for file in Files:
   fpath = os.path.join(sPath, file)
   if os.path.splitext(fpath)[1] == '.HDF5':
       print(os.path.basename(fpath))
       outname='gpm.'+file[21:29]+"_"+file[31:35]+'.grd'
       f = h5py.File(fpath)      # Open the H5 file, return the File class
       Cal = f['/Grid/precipitationCal'].value
       Cal = np.transpose(Cal)   # size: 1800 x 3600
     # tag[Cal>=0] = tag[Cal>=0] + 1
     #  Cal[Cal<0] = 0  
       Cal.tofile(outname)
       print(Cal.max())
     #  print(Cal)
     #  input()
       
      # Cal = np.flipud(Cal)      # convert to  90N ~ 90S
      # Cal /= 2
      # rain += Cal

## output
#rainfall_avg = rain / tag * 2 * 24    # unit conversion
#rainfall_avg[np.isnan(rainfall_avg)] = -999.00 # NODATA_value
##rainfall_avg[mask<0] = -999.00
#
##ofname = r'.\output\IMERG_AVG_201508mon.txt'
##np.savetxt(ofname, rainfall_avg, fmt='%7.2f ', comments='', header=header)

print("\n***************** 数据处理完成!!! Nice Job!!! ****************")
