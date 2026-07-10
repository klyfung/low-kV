'''
Plot radially averaged 3D Fourier transforms.
'''

import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

def radial_profile_3d( data ):
	'''
	Perform n radial profiles for each x-y plane in the z direction.
	'''
	# Rotate array so we extract the x-y planes along the z-axis.
	print(data.shape)
	data = np.rot90(data, axes=(0,2))
	# Precalcuate arrays for radial profile.
	plane = data[0, :, :]
	x, y = np.indices( plane.shape )
	r = np.sqrt( np.square(x - plane.shape[0]/2) + np.square(y - plane.shape[1]/2) )
	r = r.astype(np.int64)
	nr = np.bincount( r.ravel() )
	output = np.zeros((data.shape[0], nr.shape[0]))
	#print('no bins = ', np.size( nr ))
	for n, plane in enumerate( data ):
		tbin = np.bincount( r.ravel(), plane.ravel() )
		radialprofile = tbin / nr
		output[n, :] = radialprofile
	print(output.shape)
	return output

def plot_figure(output, xscale, yscale, filename):
	'''
	Plot the figure.
	'''
	fig, ax = plt.subplots()

	ax.imshow( output )

	ax.set_xlabel('$(u^{2}+v^{2})^{1/2}$ / nm$^{-1}')
	ax.set_xlabel('w / nm$^{-1}$')

	ytickslabels = np.round(np.array([-top, 0, top]) * yscale, 2)
	ax.set_yticks([0, 23, 45], ytickslabels)

	ax.set_xticks(np.array([0, (1/xscale), (2/xscale), (3/xscale), (4/xscale)]))
	xtickslabels = np.round(np.array(ax.get_xticks()) * xscale, 2)
	ax.set_xticks(ax.get_xticks(), xtickslabels)
	ax.set_title(filename[:15])

	img = Image.fromarray( output )
	img.save( filename )
	return

# 80 kV
filepath = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\80kV_3dft.npy'
filename = '80kV_3d_averaged.tif'
xscale = 0.017168
yscale = 0.001445

top = 26
bottom = 99-26

data = np.load( filepath )
output = radial_profile_3d( data )
max_freq = int(4.0 / xscale) +2
output = output[top:bottom,:max_freq]
plot_figure( output, xscale, yscale, filename )

# 60 kV
filepath = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\60kV_3dft.npy'
filename = '60kV_3d_averaged.tif'
xscale = 0.017866
yscale = 0.001

data = np.load( filepath )
output = radial_profile_3d( data )
max_freq = int(4.0 / xscale) +2
output = output[top:bottom,:max_freq]
plot_figure( output, xscale, yscale, filename )

# 40 kV
filepath = 'C:\\Users\\pczbw2\\Desktop\\TEMP\\lowkv\\40kV_3dft.npy'
filename = '40kV_3d_averaged.tif'
xscale = 0.017375
yscale = 0.00147

data = np.load( filepath )
output = radial_profile_3d( data )
max_freq = int(4.0 / xscale) +2
output = output[top:bottom,:max_freq]
plot_figure( output, xscale, yscale, filename )

plt.show()