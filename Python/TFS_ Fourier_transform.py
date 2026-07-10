'''
Data processing for low-kV data using PyCTF.

Notes
-----
kV, defocus step / nm, pixel size / nm px-1, recip px, recip defocus
80, 6.92, 0.056888, 0.017168, 0.001445
60, 10.0, 0.05466, 0.017866, 0.001
40, 6.80, 0.056204, 0.017375, 0.00147
'''

import pyCTF
from pyCTF.fourier import Fourier
from pyCTF.utils import normalise_data_range

import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from PIL import image


def _TFS( filepath, filename ):
	# Function to process the through-focus series into a stack of 2D
	# Fourier transforms.
	print('Processing TFS.')

	# Define radii for background subtraction.
	r1 = 4
	r2 = 4

	print('Importing through-focus series.')
	stack =  Fourier.import_stack( filepath )
	print('Performing FFT.')
	FFT = Fourier.fft_stack( stack )
	FFT = Fourier.log_mod( FFT )
	print('Removing background.')
	FFT = Fourier.remove_bckg_stack( FFT, r1, r2 )
	print('Radial profile...')
	prof = Fourier.profile_fft_stack( FFT )

	print('Saving...')
	np.save(filename, prof)
	return


def _FT3D( filepath, filename ):
	# Fuction to perform the 3D FFT on a through-focus series.
	from pyCTF.fourier import Fourier
	from pyCTF.utils import show_image

	stack =  Fourier.import_stack( filepath )

	print('3D Fourier transform...')
	FFT3D = Fourier.fft3d( stack )
	FFT3D = np.log(np.abs(FFT3D))
	np.save(filename, FFT3D)
	return


def _plot2d( filepath, fig, ax, xscale, yscale, filename ):
	# Function to plot the 2D FT through-focus series.
	arr = np.load( filepath,  )

	xscale = 0.017375
	yscale = 6.80
	
	arrstart = int(3)
	arr = np.fliplr(arr)
	arr = np.flip(np.rot90(arr[arrstart:179,:]),0)

	ax[0].imshow( arr,
				origin='lower')
	ax[0].set_ylabel('Defocus / nm')
	ax[0].set_xlabel('Frequency / nm$^{-1}$')
	#cbar = fig.colorbar( mappable=cax, label='Normalsied intensity' )

	# Set x and y axis scale.
	ax[0].set_xticks(np.array([3, 90, 178])-arrstart)
	xtickslabels = np.array(ax[0].get_xticks())
	xtickslabels[0] = 3
	ax[0].set_xticks(ax[0].get_xticks(),np.round(xtickslabels*xscale,2))

	ax[0].set_yticks([0, 49, 99])
	ytickslabels=np.round(np.array([-50, 0, 50])*yscale, 2)
	ax[0].set_yticks(ax[0].get_yticks(), ytickslabels)

	# Save as .tif
	img = Image.fromarray(arr)
	img.save( filename)
	return


def _plot3d(filepath, fig, ax, xscale, yscale, filename):
	# Function to plot the output of the 3D FFT.
	arr = np.load( filepath )

	max_freq = int(4.0 / xscale) + 1
	right = 512
	left = right-max_freq
	start = 26
	end = 99-27
	arr = arr[start:end,left:right]
	arr = np.fliplr(arr)

	# Create the figure
	#fig, ax = plt.subplots(1, figsize=(10,10))
	#cax = ax[1].imshow(arr)
	ax[1].imshow( normalise_data_range(arr),
					#aspect='auto',
					origin='lower')

	ax[1].set_xlabel('v / nm$^{-1}$')
	ax[1].set_ylabel('w / nm$^{-1}$')

	ytickslabels = np.round(np.array([-left, 0, left]) * yscale, 2)
	ax[1].set_yticks([0, 23, 45], ytickslabels)

	ax[1].set_xticks(np.array([0, (1/xscale), (2/xscale), (3/xscale), (4/xscale)]))
	xtickslabels = np.round(np.array(ax[1].get_xticks()) * xscale, 2)
	ax[1].set_xticks(ax[1].get_xticks(), xtickslabels)

	img = Image.fromarray(arr)
	img.save( filename )
	return


# Script starts here.
filepath = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\data\\TFS_80.tif'
filename = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\80kV_profile.npy'
_TFS( filepath, filename )

filepath = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\data\\TFS_80.tif'
filename = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\80kV_3dft.npy'
_FT3D( filepath, filename )

fig, ax = plt.subplots(1, 2, figsize=(8,8))

filepath = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\80kV_profile.npy'
xscale = 0.017168
yscale = 6.92
filename = '40kv_2d_img.tif'
_plot2d(filepath, fig, ax, xscale, yscale, filename)

filepath = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\80kV_3dft.npy'
filename = '40kv_3d_img.tif' 
xscale = 0.017168
yscale = 0.001445
_plot3d( filepath, fig, ax, xscale, yscale )

plt.show()
# End.