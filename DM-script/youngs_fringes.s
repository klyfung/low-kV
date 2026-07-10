// Automated Youngs Fringes 
// BLW@NMRC, 23-02-24
// script to move the image by a repeatable amount during image acquition,
// in order to create Youngs fringes
//
// Usage: start camera acquisiton, then execute script

number PL_x, PL_y
EMGetProjectorShift(PL_x,PL_y)

number shift = 1000
number PL_x2 = PL_x + shift


EMSetProjectorShift(PL_x2, PL_y)

sleep(1)// this should be shorter than the camera aquisition

EMSetProjectorShift(PL_x, PL_y)