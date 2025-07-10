/* Define custom look-up table
   BLW, 10-07-25
   This script creates a custom look-up table for applying colours to greyscale images.
   Custom colours are defined as an image, where each row of three pixels corresponds to a unique RBG colour.
   The look-up table can be applied to an image, or saved and used as a custom look-up table.
   Allows setting custom LUTs via script, can be integrated into more complex scripts as a function.
*/ 
// Tag group to create LUT
TagGroup CreateColEntry( number index, number r, number g, number b)
{ 
 TagGroup entryTg = NewTagGroup()
 entryTg.TagGroupSetTagAsLong( "Index", index )
 entryTg.TagGroupSetTagAsRGBUInt16( "RGB", r,g,b )
 return entryTg 
}
// definitions for custom LUTs
image viridis := [3,10] : {
	{68, 1, 84},
	{72, 40, 120},
	{62, 73, 137},
	{49, 104, 142},
	{38, 130, 142},
	{31, 158, 137},
	{53, 183, 121},
	{110, 206, 88},
	{181, 222, 43},
	{253, 231, 37}
} 
image rbg := [3,3] : {
	{255, 0, 0},
	{0, 255, 0},
	{0, 0, 255}
}
// function to apply LUT to an image
void apply_LUT( imagedisplay &disp, image colour_matrix, number showLUT )
{

	number r, g, b, interval
	number array_length = ImageGetDimensionSize(colour_matrix, 1)
	number diff = (255 - 0)/(array_length - 1)
	TagGroup colTG = NewTagList()
	for (number i = 0; i < array_length ; i++ )//less than length of array
	{
		if ( i == 0 )
		{
			interval = 0
		}
		else if ( i == array_length )
		{
			interval = 256
		}
		else
		{
			interval = 0 + ( i  )*diff//arithmetic progression, where i = i -1
		}
		r = GetPixel(colour_matrix, 0, i )
		g = GetPixel(colour_matrix, 1, i )
		b = GetPixel(colour_matrix, 2, i )
		colTG.TagGroupInsertTagAsTagGroup( Infinity(), CreateColEntry(interval, r, g, b) )
	}

	image LUT = COLUGradientColorCLUT(colTG)

	disp.ImageDisplaySetInputColorTable( LUT )
	
	if ( showLUT == 1 )
	{
		ShowImage( LUT )
	}
	else
	{ 
	CloseImage( LUT ) 
	}
	
	return
}
// start
number showLUT = 1
image img = GetFrontImage()
ShowImage(img)
imageDisplay disp = img.ImageGetImageDisplay( 0 )
apply_LUT( disp, viridis, showLUT )
// end