/* Set Focus
Script to set to a standard focus for non-JEOL engineer set up voltages
*/
number voltage = EMGetHighTension( ) 
number kV = voltage/1000
number stdFocus = 0

//Check imaging mode

string Edna = EMGetImagingOpticsMode()
if (Edna !="MAG1"){
	OKDialog( "Change to Mag 1" )
}

/*
Using the following raw focus values for eucentric focus 2100Plus UoN
200kV 1503650
80kV 1221210
60kV 1.16417e+006
40kV 1.16116e+006 
30kV 1159640
20kV 1.14558e+006

Using the following raw focus values for eucentric focus 2100F UoN
200	1.54252e+06
100	1.28171e+06
*/

number est_focus(number kV){
	// fitting values calculated external from script
	number pA = 4.58
	number pB = 1075.64
	number pC = 1110686
	number stdFocus = pA*kV*kV+pB*kV+pC
	return (stdFocus)
	}

if (kV == 60){
	stdFocus = 1.16417e+006
	}
if (kV == 40){
	stdFocus = 1.16116e+006 
	}
if (kV == 30){
	stdFocus = 1.159e+006
	}
if (kV == 20){
	stdFocus = 1.14558e+006
 	}
// If not a set value, estimating
 if (stdFocus == 0){
	stdFocus = est_focus(kV)
 	result("\n estimating focus at "+kV+" to be "+stdFocus)
}

EMSetFocus(stdFocus)

