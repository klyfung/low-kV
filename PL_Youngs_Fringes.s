// Automated Youngs Fringes 
// BLW@NMRC, 23-02-24

number PL_x, PL_y
EMGetProjectorShift(PL_x,PL_y)

number shift = 1000
number PL_x2 = PL_x + shift


EMSetProjectorShift(PL_x2, PL_y)

sleep(1)

EMSetProjectorShift(PL_x, PL_y)