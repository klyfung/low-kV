import numpy as np
from numpy.lib.stride_tricks import as_strided
import scipy
from scipy import fftpack
from scipy import ndimage
#from scipy.ndimage.interpolation import geometric_transform    #deprecated
from scipy.ndimage import geometric_transform

## Show radial profile of front image in GMS  - first slice if a stack##
## Needs to have scipy installed on top of standard python installation
## Note Gatan recommendations are to use pip install scikit-learn to install

## MWF March 2024, largely from script by Ben Miller, Gatan
## v1.1 MWF July 2024 - update deprecated import, make size of data window variable rather than fixed at 1024


### User modifiable parameters
FFT_bin = 2 #####
do_median = 1#####
mask_center_lines = True#####
length_ratio = 2#####
profile_ang_res = 256######

######
#DEFS#
######

# Function from Ben Miller script
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
# From Ben Miller script
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

#

# DEF to get front image and produce radial profile from FFT
# MWF modifications and additions to original Ben Miller script

def RadialProfile():
    img1 = DM.GetFrontImage()
    
    #Get number of dimensions
    ndims = img1.GetNumDimensions()
    
    #Get shape
    height = img1.GetImgHeight() 
    width = img1.GetImgWidth() 
    
    #Declare size of ROI to get profile from
    RSz = 1024
    #Check if the image is big enough for this window size, and reduce if not
    while(RSz>height):
        RSz = int(RSz/2)
    
    xst = int((width/2)-int(RSz/2))
    xed = int((width/2)+int(RSz/2))
    yst = int((height/2)-int(RSz/2))
    yed = int((height/2)+int(RSz/2))
    
    
    # Get image
    #TO DO - look for ROI, otherwise grab the defined square region
    if (ndims ==2):
        image_o = img1.GetNumArray()[xst:xed, yst:yed]
    else:
        image_o = img1.GetNumArray()[0, xst:xed, yst:yed]
    
    #Get the absolute version of the FFT of image
    #Note this is not the complex as we are using np.absolute
    image_o = np.absolute(scipy.fftpack.fftshift(np.fft.fft2(image_o)))
    
    #Any additional process (log)
    ProcName = ""
    if (DoLog ==1):
        print("Producing log of absolute")
        ProcName = " log "
        image_o = np.log(image_o)
    
    # determine image size
    sx, sy = image_o.shape
    
    #mask_center_lines: 
    image_o[:,sy//2-1:sy//2-1+1] = 0
    image_o[sx//2-1:sx//2-1+1,:] = 0
    
    
    image_o = strided_binning2D(image_o,binning=(FFT_bin,FFT_bin))
    sx, sy = image_o.shape
    #Median-Filter FFT to remove single-pixel outliers
    
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
    print(radial_profile.shape)
    #print(radial_profile)
    
    # Show numpy array as DM image
    dmRP = DM.CreateImage(radial_profile.copy(order='C'))
    
    # Get calibrations from original image and apply to radial profile
    origin, scale, scale_unit = img1.GetDimensionCalibration(1, 0)
    
    if scale_unit == b'\xb5m': scale_unit = 'um' #scale unit of microns causes problems for python in DM
    sf = 2#Set to some integer 2^N, N=>0
    #sx defined above
    diff_scale = sf/scale/2/sx
    unit_str = scale_unit+"-1"
    
    #dmRP.SetDimensionCalibration(1,0,diff_scale,unit_str,0)
    dmRP.SetDimensionCalibration(0,0,diff_scale,unit_str,0)
    dmRP.SetName(img1.GetName() + ProcName + " Radial Profile")
    
    dmRP.ShowImage()
    return(dmRP)
#

DoLog = 1
RadProf = RadialProfile()