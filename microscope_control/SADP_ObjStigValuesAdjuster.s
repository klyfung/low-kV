number xstig
number ystig

emgetobjectivestigmation(xstig, ystig)

Result("\n xstig is "+xstig)
Result("\t ystig is "+ystig)


//Get the HT

number voltage = EMGetHighTension( ) 
number kV = voltage/1000

//Variables for temporary adjusted obj stig
number DiffObX
number DiffObY

//original K3 at 250mm camera length values June 2023
//xstig = 32711
//ystig = 33085

//Adjusted K3 at 250mm camera length values
//xstig = 30711	 
//ystig = 27085

//orig Plus 30kV
// x 30696  y 027488


//delay(10)
//emsetobjectivestigmation(xstig-1000, ystig)

//80kV as loaded
// xstig is 37760	 ystig is 27868
// ILstig 7870 7De8

//60kV
//obj xstig is 32856	 ystig is 24608
//ilstig 7e9c 8270



if (kV == 40){
	DiffObX = 6144
	DiffObY = 14576
//40kV 2023
//IL1 5240	
//illstig 7d80 83f0

//40Kv 2024
// IL1 hex 5240
// IL stig hex 7F30 816C
// Obj Stig hex 1800 3508
// Obj Stig 6144 14576s


//30kV
//il1 5165 or 5105 for no sa aperture focus
//ill stig 7fbo 81f0

//20kV
//il1 50c4
//ilstig 8400 8690
}
//Set DIFF obj values
emsetobjectivestigmation(DiffObX, DiffObY)

//Go back to original values
//20kV
//emsetobjectivestigmation(37816, 27976)

//emsetobjectivestigmation(xstig, ystig-1000)