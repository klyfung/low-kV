# 3d fourier transform
# uses numpy fft.fftn(a, s=None, axes=None, norm=None)[source]
# a is array
# s is shape 
# axes is axes over which to compute the FFT
# returns complex ndarray

# for an array a 
# a = np.mgrid[:3, :3, :3][0]
# np.fft.fftn(a, axes=(1, 2))

# version history
# v 0.1 27 Feb 2024
# v 0.2, 12 March 2024
# v 0.21, 14 March 2024 - add scale units fix at end

import DigitalMicrograph as DM
import numpy as np

####################
#User set variable - do 2D or 3D?
nD = 3#Do 2D or 3D if 2 or 3




def Tag_Copy(image_source, image_dest, subPath = None ):
 '''
 Copy all tags between source and destination.
 If no destination subPath is provided, the destination tags will be replaced.
 '''
 #Copy Tags
 tg_source = image_source.GetTagGroup()
 tg_dest = image_dest.GetTagGroup()
 if ( subPath != None ):
         tg_dest.SetTagAsTagGroup(subPath,tg_source.Clone())
 else:
         tg_dest.DeleteAllTags()
         tg_dest.CopyTagsFrom(tg_source.Clone())
#

def Calibration_Copy(image_source, image_dest):
 '''
 Copy dimension and intensity calibration between source and destination.
 Assumes that destination is an FFT of the source
 On mismatch of number of dimension, prompt user and return.
 '''
 #Count and check that number of dimensions match
 num_dim_s = image_source.GetNumDimensions()
 num_dim_d = image_dest.GetNumDimensions()
 if num_dim_d != num_dim_s:
         DM.OkDialog('Images do not have same number of dimensions!')
         return 
         
 #Get image dimension y size for use
 stacky=image_source.GetDimensionSize(0)
 print(stacky)
 #Copy Dimension Calibrations
 origin = [0 for _ in range(num_dim_s)]
 print("\n \n Number of dimensions is ")
 print(num_dim_s)
 scale = origin
 power = origin
 unit = ["" for _ in range(num_dim_s)]
 unit2 = unit
 for i in range(num_dim_s-1):
         origin[i], scale[i], unit[i] =  image_source.GetDimensionCalibration(i, 0)
         image_dest.SetDimensionCalibration(i,origin[i],(1/(scale[i]*stacky)),'nm-1',0)
         unit2[i], power[i] = image_source.GetDimensionUnitInfo(i)
         image_dest.SetDimensionUnitInfo(i,unit2[i],power[i])
 origin[2], scale[2], unit[2] =  image_source.GetDimensionCalibration(2, 0)
 image_dest.SetDimensionCalibration(2,origin[2],scale[2],"nm",0)
   
 
 #Copy Intensity Calibrations
 i_scale = image_source.GetIntensityScale()
 i_unit = image_source.GetIntensityUnitString()
 i_origin = image_source.GetIntensityOrigin()
 image_dest.SetIntensityScale(i_scale)
 image_dest.SetIntensityUnitString(i_unit)
 image_dest.SetIntensityOrigin(i_origin)

#
def DoThreeD(nD):
   #Assume the stack is the front image
    image_0 = DM.GetFrontImage()
    im_name = image_0.GetName()
    nDim = image_0.GetNumDimensions()
    x = image_0.GetDimensionSize(0)
    y = image_0.GetDimensionSize(1)
    z = image_0.GetDimensionSize(2)

    #print(im_name)
    #print(nDim)

    #print(x)
    #print(y)
    #print(z)


    # Data to numpy array
    dmImgData = image_0.GetNumArray() # Get NumpyArray to image data

    # Try and 3d FFT it
    #3DFFTDat = np.fft.fftn(dmImgData)
    a = np.mgrid[:3, :3, :3][0]
    np.fft.fftn(a, axes=(1, 2))
    if (nD == 2):
        Dat3d = np.fft.fftn(dmImgData, axes=(1, 2))
    else:
        Dat3d = np.fft.fftn(dmImgData, axes=(0,1, 2))
   
    #Shift zero frequency component to center
    Dat3d = np.fft.fftshift(Dat3d,  axes=(1,2))
    #Show Dat3d
    DM.CreateImage(Dat3d.copy()).ShowImage()
    # NEED TO CHECK CALIBRATIONS - unit string still wrong?
    #.ImageSetDimensionUnitString(0, "nm-1" ) 
#



#Set up timing
from datetime import datetime
startTime = datetime.now()

image_S = DM.GetFrontImage()
DoThreeD(nD)
image_F = DM.GetFrontImage()

Tag_Copy(image_S, image_F)#copied over
Calibration_Copy(image_S, image_F)

# bodge to fix scale units here
unit = image_S.GetDimensionUnitString(0)
image_F.SetDimensionUnitString(0, unit+'-1') 
image_F.SetDimensionUnitString(1, unit+'-1')

if (nD == 2):
    image_F.SetName("2DFFT_"+image_S.GetName())
else:
    image_F.SetName("3DFFT_"+image_S.GetName())

# Delete python data
print("\n ===== \n end of the script \n \n \n")
print("\n Time taken is: "+str(datetime.now() - startTime))

print("\n \n Run RadialProfileFromFFTSeries DM script to make radial profile")
