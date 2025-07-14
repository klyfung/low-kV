// 2D-FFT stack of image stack
// MWF@NMRC + KLYF@NTU Sep 2024

/////////////////////////////////////////////////////////////////

void main(){

// Find out what size the original images are
// Take front image and check that this is a stack
image stackin:=GetFrontImage()
if (3 != stackin.ImageGetNumDimensions() ) Throw( "Invalid input. Not 3D stack." )
imageDisplay dispin = stackin.ImageGetImageDisplay(0)

// Get the name
string name = stackin.GetName()

number stackx, stacky, stackz, scalex, scaley, scalez

stackx=stackin.ImageGetDimensionSize(0)
stacky=stackin.ImageGetDimensionSize(1)
stackz=stackin.ImageGetDimensionSize(2)

scalex=stackin.ImageGetDimensionScale(0)
scaley=stackin.ImageGetDimensionScale(1)
scalez=stackin.ImageGetDimensionScale(2)

// Make a new stack ready for this data
// Image out2 := ComplexImage( Name+"_FFTstack", 8, stackx, stacky, stackz )
image out2 := ComplexImage( Name+"_FFTstack", 8, stackx, stacky, stackz )
out2.ShowImage()
imageDisplay dispout2 = out2.ImageGetImageDisplay(0)

// Iterate through

number i = 5
for(i=0;i<stackz;i++)
{
// Get one slice
Result("\n Slice "+i)
// image img = slice2(stackin, 0,0,i,0,stackx, 1,1,stacky,1)
// Assume stacky is the shorter axis
number xydiff = stackx-stacky
// image img = slice2(stackin, xydiff/2,0,i,0,stacky-xydiff/2, 1,1,stacky,1)
image img = slice2(stackin, (xydiff/2),0,i,0,stacky, 1,1,stacky,1)
// This should be the central 

// Transform
compleximage img_FFT := RealFFT(img)
img_FFT.UpdateImage()

// Put the FFT slice in the output stack
out2.slice2(0,0,i, 0,stacky,1, 1,stacky,1) = img_FFT	//
if(i==0){
number VAL = 1
VAL = ImageGetDimensionScale( img_FFT, 0 )

// Set calibrations
out2.ImageSetDimensionOrigin( 0, 0 ) 
out2.ImageSetDimensionScale( 0, (1/(stackx*scalex)) ) 
out2.ImageSetDimensionUnitString(0, "1/nm" ) 

out2.ImageSetDimensionOrigin( 1, 0 ) 
out2.ImageSetDimensionScale( 1, 1/(stacky*scaley) ) 
out2.ImageSetDimensionUnitString( 1, "1/nm" ) 

out2.ImageSetDimensionOrigin( 2, 0 ) 
out2.ImageSetDimensionScale( 2, scalez ) 
out2.ImageSetDimensionUnitString( 2, "nm" ) 
}
}

}

// Set up timing
number Alice = GetOSTickCount()

main()

number Bob = GetOSTickCount()
number Charlie = CalcOSSecondsBetween(Alice, Bob)
Result("\n Time taken is approximately "+Charlie)

Result("\n Note, stack will need to be converted to Real type, Modulus or log of modulus to run Radial Profile script")