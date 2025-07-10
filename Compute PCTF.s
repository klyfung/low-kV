/*-------------------------------------------------------------------------------------

Hit ctrl-enter to execute.

Description:

	This script calculates and displays PCTF as a line plot.
	April, 1995
	by Ming Pan, Chris Meyer
	© 1995 Gatan Inc. All rights reserved.
	Modified and annotated by Paul Thomas, March 2001

--------------------------------------------------------------------------------------*/


/*	This method computes and returns a 1D PCTF given the neccesary parameters */
	
Image CalculatePCTF( number size, number voltage, number Cs, number rLimit, number defocus )
{
	// Establish neccessary physical constants
	number h = 6.6256E-34											
	number c = 2.9979E8
	number eV = 1.602E-19
	number E0 = 511000 * eV
	number pi = 3.1416
	
	// Calulate the step size per pixel (nm-1).  Convert cs to nm, voltage to V, 
	// calculate the electron energy in J and the electron wavelength (in nm)
	number u1 = 1.0 / ( rLimit * size )								
	cs = cs * 10**6													
	voltage *= 1000													
	number E = voltage * eV											
	number lambda = ( h * c / sqrt( 2 * E * E0 + E * E ) ) * 1E9	
	
	// Create an image for the PCTF...
	// and compute the PCTF using Scherzer's formula
	Image PCTF := RealImage( "PCTF" + defocus + " nm", 4, size, 1 ) 
	PCTF = sin( pi * ( lambda * defocus * ( icol * u1 )**2 + 0.5*cs*lambda** 3 * ( icol * u1 )**4 ) )			
	
	// Set the x and y axis units 
	PCTF.ImageSetDimensionCalibration(0, 0, 1.0 / ( rLimit * size ), " u (1/nm)", 0)			
	PCTF.ImageSetDimensionUnitString( 1, "sin(phase-contrast)" )

	// And return the array
	return PCTF														
}

// Rlimit is the resolution to be used for the calculation per channel (in nm) 
// Co-eff of spherical aberration (mm), microscope voltage in kV, defocus in mm
number rLimit = 0.15  												
number Cs = 1														
number voltage = 100												
number defocus = -40	

// Size of the plot in channels.  Range covered is size*(1/rlimit)											 
number size = 256													

// Ask the user for the necessary parameters	
if(!GetNumber("Enter Cs (mm)", Cs, Cs)) exit(0)									
if(!GetNumber("Enter voltage (kV)", voltage, voltage)) exit(0)	
if(!GetNumber("Enter defocus (nm)", defocus, defocus)) exit(0)
if(!GetNumber("Enter resolution limit (nm)", rlimit, rLimit)) exit(0)
if(!GetNumber("Enter number of channels", size, size)) exit(0)

// Calculate the PCTF...and plot it
image PCTF := CalculatePCTF( size, voltage, Cs, rLimit, defocus ) 	
ShowImage( PCTF )												
