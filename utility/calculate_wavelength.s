number CalcWavelength( number highTension )
{
	number lambda
	number EkV
	try
	{
		if( highTension = 200 )
		{
			lambda = 0.00251
		}
		else if( highTension = 80 )
		{
			lambda = 0.00418
		}
		else
		{
			EkV = highTension * 1000 * 1.60217662
			lambda = (6.626e-34) / (2*9.10938356e-31* EkV*(1/(2*9.10938356e-31*299792458^2)))^0.5
		}
	}
	catch
	{
		lambda = -1
	}
	return lambda
}

number kV = 
number wavelength = CalcWavelength( kV )
result(wavelength + "\n")