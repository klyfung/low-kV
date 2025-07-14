//Z height
number Zht
Zht = EMGetStageZ() 
result("\n Z Height is "+Zht)

//DAC focus

number rawfocus
rawfocus = EMGetFocus()
result("\n Focus is "+rawfocus)
result( "\n   %8d \t\t-> " + Format( rawfocus, "%8d" ) )
