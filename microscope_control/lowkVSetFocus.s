/* Set Focus
Set the standard focus for non-JEOL engineer set up voltages

Using the following raw focus values for eucentric focus 2100Plus UoN
60kV 1.16417e+006
40kV 1.16116e+006 
30kV
20kV 1.14558e+006

Using the following raw focus values for eucentric focus 2100F UoN
200	1.54252e+06
100	1.28171e+06
*/

number voltage = EMGetHighTension( ) 
number kV = voltage/1000

number stdFocus

if (kV = 60)
	stdFocus = 1.16417e+006
	
if (kV = 40)
	stdFocus = 1.16116e+006 

if (kV = 30)
	stdFocus = 1.15e+006

if (kV = 20)
	stdFocus = 1.14558e+006

EMSetFocus(stdFocus)

