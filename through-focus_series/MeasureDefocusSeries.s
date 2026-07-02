/*Through focus series

Varies the focus by script defined amounts either side of the focus
set when running the script
Press shift to terminate the acquisition loop early

 Script history
 v0.1 April 2023 MWF for University of Nottingham
 v0.2 Oct 2023 MWF for UoN
		Note calibration values of focus step for UoN 2100+ and Tecnai TEMs
 v0.2a Jan 2024 MWF for UoN
		revision of comments
 v0.3 July 2024 MWF for UoN
		add calibrations to final stack
		Note GMS nm/dac calibrations for 200, 80, 60kV on 2100Plus
 v 0.3.1 22nd July - tidy up and fix bug (DAC to nm should be 1 in raw only)
 
Parameters to be checked/ changed before running depending on voltage and instrument:
	stepnm: nm per step
	stepraw: conversion value from raw units to nm
	n: number of slices in final stack

Camera parameters should be set before running, script will read current paramaters

nyquist frequency calculation - single pixel size in nm (r), Nyquist (in nm-1) = 0.5/r

Produce and display defocus dependences of rotationally-averaged 2D Fourier transforms
*/

//1.37 nm step for 160 slices at 200 used by Kimoto et al 
// step is based on 1/lambda|g|2  to observed defocus dependence of a linear term contrast up to spatial frequency |g|


// Optimal choice of this for 3d structures depends on resolution and size of structure
// Plus time and file size 
// 
// For resolution appraisal at voltages, change step according to voltage

// kV and lambda (in pm) table is
//	200	2.5079
//	100	3.7014
//	80	4.1757
//	60	4.8661
//	40	6.0155
//	20	8.5885
//
//	Rough values for 0.1nm resolution, need steps at most of 
//	200	4 nm
//	100	2.7nm
//	80	2.4nm
//	60	2.1nm
//	40	1.7nm
//	30	1.4nm
//	20	1.2nm

//Raw to nm factor - UoN measurements are 
//Plus was 0.55 at 80kV - based on raw focus of 576 reported as 1037nm on JEOL TemControl at 80kV
//2100F is 0.78 at 200kV - based on raw focus of 70 reported by JEOL TemControl as 90nm
//Tecnai is 4.79

// Gatan calibrations:
// UoN Plus 200kV 1nm/dac
// UoN Plus 120kV 0.94 nm/dac from Gatan calibration
// UoN Plus 120kV 1.15 nm/DAC from through focus and ThonRings fitting
// THIS IS RATHER A DIFFERENCE ISN'T IT?

//
// UoN Plus 80kV 0.49403 nm/dac from Gatan calibration
// UoN Plus 60kV 0.322 nm/dac from Gatan calibration

// UoN 2100F 200kV 0.194279

// Note, on the 2100F and K3 system best run this at 1/2 frame 
// with a camera setting such as 0.05 s, 1 frame.


*/

// Global variables

// Number of slices in stack
number n = 100

// Calibrated nm - 0, uncalibrated DAC - 1
number DACONLY = 1 

//How much per step
number stepsVal = 600/20

number DAC_to_nm = 1.15	


// Function to collect TFS.
void DataCollection( number n, number DACONLY, number DAC_to_nm  )
{
number HT = EMGetHighTension( )
HT=HT/1000

number stepraw
number stepnm


// Calibrated - stepraw is in DAC, stepnm is in nm.
if (DACONLY ==0){
	stepraw = stepsVal/DAC_to_nm
	stepnm = stepsVal
	}

// Uncalibrated - stepraw is in DAC.
if (DACONLY ==1){
	stepraw = stepsVal
	stepnm = stepsVal
	DAC_to_nm = 1
	}


// Acquisition

Result("\n Stepraw is "+stepraw)
if (DACONLY ==0){
	Result("\n nm step is "+stepnm)
	}

//number of slices. Probably need 160 for good data

Result("\n Doing  "+n+" slices")

string help = "Starting Through Focus Series\n"
help += "Camera parameters should be set already\n"
help += "Sample should be at zero defocus\n"
help += "and objective wobble should have been optimised\n"
help += "Multiple acquisition info should update in bottom right\n"
help += "Please be patient. Or press shift to end if you are not.\n"

if ( !OKCancelDialog( help ) )
 exit( 0 )

//pixel size
number res

/*
//Can put res in with
image front
if ( !GetFrontImage( front ) )
	Throw( "No image displayed." )
//front.ImageGetDimensionScale( 0, res ) 
res = ImageGetDimensionScale(front, 0)
*/

//Get image dimensions
number top, bottom, left, right
number bin = 1
top = 0
left = 0
//right = ImageGetDimensionSize(front,0) 
//bottom = ImageGetDimensionSize(front,1)
number camID = CameraGetActiveCameraID( )

number exposure
number xBin, yBin
number processing
number areaT, areaL, areaB, areaR
CameraGetDefaultParameters( camID, exposure, xBin, yBin, processing, areaT, areaL, areaB, areaR )
//areaB is default bottom
//areaR is default right
top = areaT
left = areaL
right = areaR
bottom = areaB
Result("\n area is "+areaR+"\n ")
Result("\n exposure is "+exposure)
//Exposure reported on the K3 appears to be the Capture exposure, not the view. 

//Calculate nyquist
//number ny = 0.5/res

//Get current focus value - this is assuming the focus is set as close to zero defocus as possible
number rawfocus
rawfocus = EMGetFocus()// will always be in DAC units
number startfocus = rawfocus-(n/2)*stepraw//will always be in DAC units
number endfocus = rawfocus +(n/2)*stepraw//will always be in DAC units
result("\n startfocus is "+startfocus+" DAC")
if (DACONLY ==0){
	Result("\t nm start is "+((startfocus*DAC_to_nm)-(rawfocus*DAC_to_nm)))
	}
result("\n midfocus is "+rawfocus+" DAC")
if (DACONLY ==0){
	Result("\t nm midfocus is 0")
	}
result("\n endfocus is "+endfocus+" DAC")
if (DACONLY ==0){
	Result("\t nm end focus is  "+((endfocus*DAC_to_nm)-(rawfocus*DAC_to_nm)))
	}


//Define Images
string CubeName
if (DACONLY ==0){
	CubeName = "ThroughFocusSeries_"+HT+"kV_"+n+"steps_"+stepnm+"nm"
	}
if (DACONLY == 1){
	CubeName = "ThroughFocusSeries_"+HT+"kV_"+n+"steps_"+stepraw+"DAC"
}
image Layer:=IntegerImage("Temporary",2,1,(right-left)/bin,(bottom-top)/bin)
image Cube:= IntegerImage(CubeName,2,1,(right-left)/bin,(bottom-top)/bin,n)

number VAL

//This iteration is much slower than the frame time would suggest. It is unclear why. 

//Iterate
number i //counter
for(i = 0; i < n; i ++)
{
//Acquire image
EMSetBeamBlanked(0)
number nowfocus = startfocus+i*stepraw
EMSetFocus(nowfocus)
result("\n "+i+"\t"+nowfocus+" DAC")
if (DACONLY ==0){
result("\t "+((nowfocus*DAC_to_nm)-(rawfocus*DAC_to_nm))+" nm")
}
// Delay here if required for lens settling
delay(0)
OpenAndSetProgressWindow("MultipleAcquisitions", (i + 1) + "of " + n,"")
//SSCGainNormalizedBinnedAcquireIn-Place(Layer,exp,bin,top,left,bottom,right)
//SSCGainNormalizedBinnedAcquireIn-Place(Layer,0.01,1,0,0,1024,1024)
CameraPrepareForAcquire( camID )
Layer:= CameraAcquire( camID, exposure, bin, bin, processing )
VAL = ImageGetDimensionScale(Layer, 0) 
Cube[icol,irow,i] = Layer

// Exit from loop if shift is held down
number SD = ShiftDown()
if (SD == 1){
	Result("Shift pressed, ending loop early")
	break
	}

}

CloseProgressWindow()
//TO DO update calibrations

Cube.ImageSetDimensionOrigin( 0, 0 ) 
Cube.ImageSetDimensionScale( 0, VAL ) 
Cube.ImageSetDimensionUnitString(0, "nm" ) 

Cube.ImageSetDimensionOrigin(1, 0 ) 
Cube.ImageSetDimensionScale( 1, VAL ) 
Cube.ImageSetDimensionUnitString(1, "nm" ) 

if (DACONLY ==0){
	Cube.ImageSetDimensionOrigin(2, 0 ) 
	Cube.ImageSetDimensionScale( 2, stepnm ) 
	Cube.ImageSetDimensionUnitString(2, "nm" ) 
	}

if (DACONLY ==1){
	Cube.ImageSetDimensionOrigin(2, 0 ) 
	Cube.ImageSetDimensionScale( 2, stepraw ) 
	Cube.ImageSetDimensionUnitString(2, "DAC" ) 
	}



//Display
ShowImage(Cube)

//Blank beam
EMSetBeamBlanked(1)

//Reset focus
EMSetFocus(rawfocus)

string endnote = "Script completed\n"
endnote += "Beam has been blanked\n"
endnote += "Note to check calibrations of stack\n"

if ( !OKCancelDialog( endnote ) )
 exit( 0 )
}

// Run on background thread.
void Invoke( )
{
	alloc( data_collection_thread ).StartThread( )
}

// declare threads
Class data_collection_thread : thread //controls data collection
{
	data_collection_thread( object self )//constructor
	{
		result( self.ScriptObjectGetID() + " collector created.\n" )
	}
	~data_collection_thread( object self )//destructor
	{
		result( self.ScriptObjectGetID() + " collector destroyed.\n" )
	}
	void RunThread( object self )
	{
		DataCollection( n, DACONLY, DAC_to_nm )
	}
}

// Script starts here
Invoke( )
//end