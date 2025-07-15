# Simplified CTF model to run within GMS
# Don't trust this until you have verified I haven't mistyped somewhere
# Units may be flaky
# MWF June 18th 2024; additions by BLW 15-07-25
# Note: does not have a damping function

import math
import scipy.constants

##Variables here       ##
# Voltage in kV
kV = 20
# Defocus in nm
Deltznm = 0
#spherical abberation in mm
Csmm = 1.4
# verbosity
verbose = 0
# CTF or CTF squared
squared = 0

# define functions
# calculate relativistic wavelength from kV 
def kVToLamb(E):
    #lamb = 1.23e3/(math.sqrt(E*(1+9.78e-7*E)))
    E = E*1000
    PT = scipy.constants.h * scipy.constants.c
    PBA = (scipy.constants.e *E)*(scipy.constants.e *E)
    PBB = 2*scipy.constants.e*E*scipy.constants.m_e*(scipy.constants.c)*(scipy.constants.c)
    lamb = PT/math.sqrt(PBA+PBB)#lambda in metres
    return(lamb)


pi =  (math.pi)

lamb = kVToLamb(kV)
if (verbose == 1):
    print(str(lamb*1e9)+" nm")
    print(str(lamb*1e12)+" pm")

Deltz = Deltznm/1e9#deltaZ in metres
if (verbose == 1):
    print(str(Deltznm) +" nm defocus")

#spherical abberation
Cs = Csmm/1000#conversion or it's wrong
#phase shift factor
phi = 0

flim = 5*1e9 #is this in m-1?

#how many datapoints in plot
fno = int(2000)
n = range(0,fno)

if (verbose == 1):
    print("/n")
    print("using in metres")
    print("Cs = "+str(Cs))
    print("Defocus = "+str(Deltz))
    print("wavelength = "+str(lamb))

CTF = [0 for _ in range(fno)]

for i in n:
    f = float(flim*(i/fno))
    CTF[i] = math.sin((pi*Deltz*lamb*f**2)+(0.5*pi*Cs*lamb**3*f**4))#Carter and Williams
    #CTF[i] = -math.cos(pi*Deltz*lamb*f*f-(pi/2)*Cs*(lamb**3)*(f**4)+phi)#cryoSPARC equation
    #CTF[i] = math.sin((pi*Cs*(lamb**3)*(f**4)*0.5)-(pi*lamb*Deltz*f**2))#myscope equation
    #CTF[i] = math.sin((pi*Deltz*lamb*f**2))#Carter and Williams first part
    #CTF[i] = math.sin((0.5*pi*Cs*lamb**3*f**4))#Carter and Williams second part
    #CTF[i] = math.sin(i)
    if (squared == 1):
        CTF[i] = CTF[i]**2

if (verbose == 1):
    print(CTF)

import numpy
npCTF = numpy.array(CTF)

DMimg = DM.CreateImage( npCTF.copy() )

fscale = flim/(fno*(1e9))
DMimg.SetDimensionCalibration(0,0,fscale,"nm-1",0)
DMimg.SetName(str(kV)+"kV__"+str(Deltznm)+"_nm_defocus__"+str(Cs*1000)+"_Cs")
DMimg.ShowImage()
del npCTF