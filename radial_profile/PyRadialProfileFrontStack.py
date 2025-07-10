import numpy as np
from numpy.lib.stride_tricks import as_strided
import scipy
from scipy import fftpack
from scipy import ndimage
from scipy.ndimage.interpolation import geometric_transform

## Show 2D radial profile image plot of front image stack in GMS  - ##
## Needs to have scipy installed on top of standard python installation
## Note Gatan recommendations are to use pip install scikit-learn to install

## MWF March 2024, many sections are from scripts by Ben Miller, Gatan
## Alternative way of making 2D FFT radial profiles from stack, requires less memory than 3DFFTStack.py script
## Possibly faster than Stack_2_FFTstack



def strided_binning2D(array,binning=(1,1)):
    """
    Function to Bin 2D Data 
    Accepts:
        array        2D numpy array to be binned
        binning        2 element tuple of integer binning amounts (bin_x, bin_y)
    Returns: A binned 2D array
    """
    bin=np.flip(binning)
    nh = (array.shape[0]-bin[0])//bin[0]+1
    nw = (array.shape[1]-bin[1])//bin[1]+1
    strides = (array.strides[0],array.strides[1],array.strides[0]*bin[0],array.strides[1]*bin[1])
    strides = (array.strides[0],array.strides[1],array.strides[0]*bin[0],array.strides[1]*bin[1])
    shape = (bin[0],bin[1],nh,nw)
    virtual_datacube = as_strided(array,shape=shape,strides=strides)
    result = np.sum(virtual_datacube,axis=(0,1))
    return result

#Funtion to convert cartesian-coordinate image to polar-coordinate image
def topolar(img,  r_size, theta_size, order=1):
    sx, sy = img.shape
    max_radius = int(sx/2)
    #define transform
    def transform(coords):
        theta = 2.0*np.pi*coords[1] / (theta_size - 1.)
        radius = max_radius * coords[0] / r_size
        i = int(sx/2) - radius*np.sin(theta)
        j = radius*np.cos(theta) + int(sx/2)
        return i,j
    #perform transform
    polar = geometric_transform(img, transform, output_shape=(r_size,theta_size), order=order,mode='constant',cval=1.0,prefilter=False)    
    return polar


### User modifiable parameters
FFT_bin = 2 #####
do_median = 1#####
mask_center_lines = True#####
length_ratio = 2#####
profile_ang_res = 256######
sx = 1024#must be even

###########################################################
## Start doing things
###########################################################
#Set up timing
from datetime import datetime
startTime = datetime.now()

img1 = DM.GetFrontImage()# Get front image

#Get number of dimensions
ndims = img1.GetNumDimensions()
#Note if it isn't a stack
if (ndims <3):
    print("non-stack image detected, exiting")
    exit()

#Get shape
height = img1.GetImgHeight() 
width = img1.GetImgWidth() 

nSlices = img1.GetDimensionSize(2)

# def to get image slice and calculate fft of slice
def slice_fft(array, width, height, slice, do_median, ssz):
    xst = int((width/2)-(ssz/2))
    xed = int((width/2)+(ssz/2))
    yst = int((height/2)-(ssz/2))
    yed = int((height/2)+(ssz/2))
    image_o = img1.GetNumArray()[slice, xst:xed, yst:yed]
    image_o = np.absolute(scipy.fftpack.fftshift(np.fft.fft2(image_o)))
    
    # determine image size
    sx, sy = image_o.shape

    #mask_center_lines: 
    image_o[:,sy//2-1:sy//2-1+1] = 0
    image_o[sx//2-1:sx//2-1+1,:] = 0
    
    image_o = strided_binning2D(image_o,binning=(FFT_bin,FFT_bin))
    sx, sy = image_o.shape
    
    if do_median: image_o_median = scipy.ndimage.median_filter(image_o, size=3)
    else: image_o_median = image_o
    if mask_center_lines: 
        image_o_median[:,sx//2] = 0
        image_o_median[sx//2,:] = 0
    profile_size = int(sx/length_ratio)
    #convert FFT image to polar coordinates
    polar_im = topolar(image_o_median, profile_size, profile_ang_res, order=1)
    #compute radial mean and maximum profiles
    radial_max=np.amax(polar_im,1)
    radial_mean=np.mean(polar_im,1)
    #median-filter the radial mean profile to smooth this further
    radial_mean_median = scipy.signal.medfilt(radial_mean)
    #radial profile is radial-max minus radial-mean
    radial_profile = np.atleast_2d(radial_max-radial_mean_median)
    #print("radial profile shape is ")
    #print(radial_profile.shape)
    #print(radial_profile)    
        
    return radial_profile


# Do we need to create the radial profile image? Or initialise it and append to with each loop? 
# create radial profile image from first raidal profile
i = 1
radial_profile = slice_fft(img1, width, height, i, do_median, sx)
rpimg = np.zeros((nSlices, radial_profile.shape[1]))
rpimg[i,:] = radial_profile

#rpimg = np.zeros((nSlices, profile_ang_res))
# size is ndims by profile_ang_res? 
# No it isn't. It's something else. ndims by ???
# Its 256 if original is 1024
# and 64 ir original is 512 or 256
print(sx)

#Loop the rest of the slices

for i in range(2, nSlices, 1):
    radial_profile = slice_fft(img1, width, height, i, do_median, sx)
    #print(radial_profile.shape)
    rpimg[i,:] = radial_profile
    print(i)

DMrpimg = DM.CreateImage(rpimg.copy(order='C'))

# Get calibrations from original image and apply to radial profile
origin, scale, scale_unit = img1.GetDimensionCalibration(1, 0)
if scale_unit == b'\xb5m': scale_unit = 'um' #scale unit of microns causes problems for python in DM

sf = 2# I think? Check this. I may have got confused. 
# NOTE- THIS IS PROBABLY WRONG!
diff_scale = sf/scale/2/sx

unit_str = scale_unit+"-1"
DMrpimg.SetDimensionCalibration(0,0,diff_scale,unit_str,0)
DMrpimg.SetName(img1.GetName() + " Radial Profiles")

# Need to adjust display to show structure - make log10? but -inf issue?
#rpimgLog = np.log10(rpimg)
#DMrpimglg = DM.CreateImage(rpimgLog.copy(order='C'))
#DMrpimglg.SetDimensionCalibration(0,0,diff_scale,unit_str,0)
#DMrpimglg.SetName(img1.GetName() + " log10 Radial Profile")
#DMrpimglg.ShowImage()
# Maybe colour it viridis? Will need to check that that file exists
# would be at C:\Users\_USERNAME_\AppData\Local\Gatan\ColorTables\viridis.dm3

DMrpimg.ShowImage()


print("\n Time taken is: "+str(datetime.now() - startTime))

del img1
del radial_profile
del rpimg