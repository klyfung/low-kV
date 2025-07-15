/*
Script to measure spherical aberrtation

Benjamin Weare @ nmRC, 02-Apr-25
Contains modified code from Ming Pan/Paul Thomas/Robin Harmon, and David Mitchell.

This script takes a real image, calculates the CTF and takes it's radial profile, then takes
the first derivative and displays it as a line plot. A savitsky-golay filter is applied to the CTF before
the radial average is performed. 
The spherical aberration of the microscope can be measured from the CTF via the method outlined in the
attached publication.

*/
// Calculate the scale of the Fourier transform
number CalculateFTScale( image input )
{
	//i.e. Nyquist frequency
	number imscale = 1/(input.ImageGetDimensionScale(0) * input.ImageGetDimensionSize(0)) 
	return imscale
}
// Perform the Fourier transform and set scale
image Fourier_Transform( image input, number imscale )
{
	//FFT = modulus( log( realFFT( input ) ) )
	FFT = log( modulus( realFFT( input ) ) )
	FFT.ImageSetDimensionScale(0, imscale)//x
	FFT.ImageSetDimensionScale(1, imscale)//y
	FFT.ImageSetDimensionUnitString( 0 , "1/nm" )
	FFT.ImageSetDimensionUnitString( 1 , "1/nm" )
	return FFT
}
// Line plot drawing style
void FormatLinePlot( ImageDisplay &imageDisp, number slicenum )
{
	number DispLimit = 500
	imageDisp.LinePlotImageDisplaySetDisplayedChannels(0, DispLimit)
	
	if ( slicenum == 0 )
	{
		imageDisp.LinePlotImageDisplaySetContrastLimits(0.5, 1)//low limit, high limit
		return
	}
	else
	{
		imageDisp.LinePlotImageDisplaySetSliceDrawingStyle(slicenum, 1)
		imageDisp.LinePlotImageDisplaySetSliceLineThickness( 1, 2 )
	}
	return
}

// Calculate radial intensity distrubution of the CTF, from a script by Ming Pan/Paul Thomas/Robin Harmon
image RadialIntensityDistribution(image CTF, number scale,  number samples)
{
	// Define neccessary parameters and constants
	number pi = 3.1415926
	number xscale, yscale, xsize, ysize
	number centerx, centery, halfMinor
	string unit = "1/nm"

	// Likewise, declare intermediate images
	image rotational_average, dst, line_projection
	
	// Get the dimension sizes, and determine half the smallest dimension 
	CTF.Get2dSize( xsize, ysize )
	halfMinor = min( xsize, ysize )/2

	// Find the centre of the image
	centerx = xsize / 2
	centery = ysize / 2
	
	//SetROI( img, centerx, centery )

	// Convert the image to polar co-ordinates...
	dst := RealImage( "dst", 4, halfMinor, samples )
	dst = warp( CTF, icol*sin(irow*2*pi/samples) + \
			centerx, icol*cos(irow*2*pi/samples) + centery )

	// and create a line projection using the icol intrinsic variable, 
	// normalising with the sampling density
	line_projection := RealImage( "line projection", 4, halfMinor, 1 )
	line_projection.ImageSetDimensionScale( 0, scale )
	line_projection.ImageSetDimensionUnitString( 0, unit )
	line_projection = 0
	line_projection[icol,0] += dst
	line_projection /= samples

	setname(line_projection, "FT Radial Average")
	return line_projection
}

// Savitsky-Golay smooth CTF, , from a script by David Mitchell
image ComputeSavitzkyGolayCoefficients(number points, number polynomialorder)
	{
		polynomialorder=round(polynomialorder)
		if(polynomialorder<2) polynomialorder=2
		if(polynomialorder>3) polynomialorder=3

		points=round(points)
		if(mod(points,2)==0) points=points+1
		if(points<3) points=3
		if(points>99) points=99

		// Create the design matrix
		image designmatrix=realimage("",4,polynomialorder+1,points)
				
		// The first column is set to 1
		designmatrix[0,0,points,1]=1

		// The second column varies between -m at the top - through zero
		// down to +m, where m=(points-1)/2
		number halfsize=((points-1)/2)*-1
		number i
		
		for(i=0; i<points; i++)
			{
				designmatrix[i,1,i+1,2]=halfsize
				halfsize=halfsize+1
			}
		
		// The following column are m**2, m**3 up to m**n - where n is the polynomial order
		designmatrix[0,2,points,3]=designmatrix[0,1,points,2]**2 // polynomial order 2
		if(polynomialorder==3)designmatrix[0,3,points,4]=designmatrix[0,2,points,3]**2 // polynomial order 3

		// Compute the SG coefficients using matrix maths
		image matrixtranspose=matrixtranspose(designmatrix)
		image matproduct=matrixmultiply(matrixtranspose, designmatrix)

		image inversematrix=matrixinverse(matproduct)
		image coeffmatrix=matrixmultiply(inversematrix, matrixtranspose)

		return coeffmatrix
	}
// Find derivative of CTF, from a script by David Mitchell
void ComputeFirstDerivative( image front, number scale )
{
	number points=15
	number polyorder=3

	polyorder=round(polyorder)
	if(polyorder<2) polyorder=2
	if(polyorder>3) polyorder=3

	// The number of points (window width for fitting) must be an odd number between 3 and 99 inclusive
	points=round(points)
	if(mod(points,2)==0) points=points+1
	if(points<3) points=3
	if(points>99) points=99

	// Compute the SG coefficients
	image sgcoeffs=ComputeSavitzkyGolayCoefficients(points, polyorder)

	number xsize, ysize, i
	getsize(front, xsize, ysize)
	string imgname=getname(front)
	// Create some images to store the data
	image smooth=imageclone(front)*0
	image secondderiv=imageclone(front)*0
	image firstderiv=imageclone(front)*0

	// Copy the tag groups from the original image
	taggroup fronttags=front.imagegettaggroup()
	taggroup smoothtags=smooth.imagegettaggroup()
	taggroup firsttags=firstderiv.imagegettaggroup()
	taggroup secondtags=secondderiv.imagegettaggroup()

	taggroupcopytagsfrom(smoothtags, fronttags)
	taggroupcopytagsfrom(firsttags, fronttags)
	taggroupcopytagsfrom(secondtags, fronttags)

	//Set scale
	smooth.ImageSetDimensionScale(0, scale)
	smooth.ImageSetDimensionUnitString( 0 , "1/nm" )
	imagecopycalibrationfrom(firstderiv, smooth)	
	imagecopycalibrationfrom(secondderiv, smooth)
	
	image paddedimg=realimage("", 4, xsize+(points-1), ysize)
	number half=(points-1)/2

	image windowimg=front[0,0,1,half]
	image reversewindowimg=imageclone(windowimg)*0
	reversewindowimg=windowimg[half-icol, irow]
	paddedimg[0,0,1,half]=reversewindowimg
	
	paddedimg[0,half, 1, xsize+half]=front

	windowimg=front[0,xsize-half, 1, xsize]
	reversewindowimg=windowimg[half-icol, irow]
	paddedimg[0,xsize+half, 1, xsize+(half*2)]=reversewindowimg
	number padxsize, padysize
	getsize(paddedimg, padxsize, padysize)

	image window
	number halfsize=(points-1)/2

	for(i=0; i<padxsize-(half*2); i++)
		{
			// Extract the window in the front image to process

			window=paddedimg[0,i, 1, i+points] 
			
			number smoothvalue=sum(window*sgcoeffs[0,0,1,points]) // top row contains smoothing coefficients
			setpixel(smooth, i, 0, smoothvalue)
			
			number firstderivvalue=sum(window*sgcoeffs[1,0,2,points]) // second row contains first derivative coefficients
			setpixel(firstderiv, i, 0, firstderivvalue)
			
			number secondderivvalue=sum(window*sgcoeffs[2,0,3,points]) // third row contains second derivative coefficients
			setpixel(secondderiv, i, 0, secondderivvalue)
		}

	// Normalise images
	smooth = ( smooth/max(smooth) )
	firstderiv = ((firstderiv/max(firstderiv)) *0.1 ) + median(smooth) //normalise and scale

	// Display the images
	showimage(smooth)
	setname(smooth, imgname+" (Smooth Sav-Golay w "+points+" po "+polyorder+")")
	
	ImageDisplay OutputData = smooth.ImageGetImageDisplay(0)
	FormatLinePlot( OutputData, 0 )// image display and slice

	setname(firstderiv, imgname+" (1st Deriv Sav-Golay w "+points+" po "+polyorder+")")
	OutputData.ImageDisplayAddImage(firstderiv, "Deriv")
	FormatLinePlot( OutputData, 1 )
	OutputData.lineplotimagedisplaysetlegendshown(1)

}

// Main Script
image input := GetFrontImage()
number scale = CalculateFTScale( input )
image CTF = Fourier_Transform( input, scale )
result(CTF.ImageGetDimensionScale(0))
image output = RadialIntensityDistribution( CTF, scale, 3000 )
ComputeFirstDerivative( output, scale )
// end