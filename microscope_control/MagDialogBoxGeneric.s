
//////////////////////////////////////////////
// 80kV and 200kV operation
//
// Settings based on alignment files:
//	80kV:	80kV2022-02-02_16-51.jal
//  200kV: 200kV_2022-02-02_15-57
// 


void CheckHT()
	{
	number HT
	HT = EMGetHighTension()

	if (HT != 200000){
		if (HT != 80000){
			string help = "This plugin for HTs:\n"
			help += " 80kV and 200kV\n"
			help += "Press SHIFT to abort."
			if ( !OKCancelDialog( help ) )
			exit( 0 )
			}
		}	
	}


//set mage to 25K
void Set25K()
	{
	//Check voltage of microscope
	CheckHT()
	//Check imaging mode
	string Edna = EMGetImagingOpticsMode()
	if (Edna !="MAG1"){
		string help = "Changing mode to MAG1:\n"
		help += "Press SHIFT to abort."

		if ( !OKCancelDialog( help ) )

		exit( 0 )
		EMSetImagingOpticsMode("MAG1")
	}
	//Set up parameters, with default values
	number Bval = 51123 
	number NMag = 25000
	number Focus = 1.50365e+006
		//Apply correct parameters for voltage
	number HT
	HT = EMGetHighTension()	
	if (HT == 200000){
		Bval = 51123 
		Focus = 1.50365e+006
		}

	if (HT == 80000){
		Bval = 54473
		Focus = 1.22185e+006
		}	

	string help = "SetMag25k:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )

	//Set Brightness
	EMSetBrightness(Bval)
	//Set Mag
	EMSetMagnification(NMag)
	//Set standard focus
	EMSetFocus(Focus)
		
	}

///////////////////////////////////////////

//set mage to 100K
void Set100K()
	{
	//Check voltage of microscope
	CheckHT()

	//Check imaging mode
	string Edna = EMGetImagingOpticsMode()
	if (Edna !="MAG1"){
		string help = "Changing mode to MAG1:\n"
		help += "Press SHIFT to abort."

		if ( !OKCancelDialog( help ) )

		exit( 0 )
		EMSetImagingOpticsMode("MAG1")
	}
	//Set up parameters, with default values
	number Bval = 46131
	number NMag = 100000
	number Focus = 1.50365e+006
	number HT
	HT = EMGetHighTension()

		//Apply correct parameters for voltage
	if (HT == 200000){
		Bval = 46131 
		Focus = 1.50365e+006
		}

	if (HT == 80000){
		Bval = 44873
		Focus = 1.22185e+006
		}	


	string help = "SetMag100k:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )

	//Set Brightness
	EMSetBrightness(Bval)
	//Set Mag
	EMSetMagnification(NMag)
	//Set standard focus
	EMSetFocus(Focus)
		
	}
//////////////////////////////////////////	


//set mage to 500K
void Set500K()
	{
	//Check voltage of microscope
	CheckHT()

	//Check imaging mode
	string Edna = EMGetImagingOpticsMode()
	if (Edna !="MAG1"){
		string help = "Changing mode to MAG1:\n"
		help += "Press SHIFT to abort."

		if ( !OKCancelDialog( help ) )

		exit( 0 )
		EMSetImagingOpticsMode("MAG1")
	}
	//Set up parameters, with default values
	number Bval = 44595
	number NMag = 500000
	number Focus = 1.50365e+006

		//Apply correct parameters for voltage
	number HT
	HT = EMGetHighTension()		
	if (HT == 200000){
		Bval = 44595 
		Focus = 1.50365e+006
		}

	if (HT == 80000){
		Bval = 42153
		Focus = 1.22185e+006
		}	


	string help = "SetMag500k:\n"
	help += "Press SHIFT to abort."

	if ( !OKCancelDialog( help ) )
	exit( 0 )

	//Set Brightness
	EMSetBrightness(Bval)
	//Set Mag
	EMSetMagnification(NMag)
	//Set standard focus
	EMSetFocus(Focus)
		
	}
//////////////////////////////////////////	




    class myDlg:UIframe{
          void OnButtonDo10K(object self) { 
			Set25K()
			result("\n 25K"); 
			}
          void OnButtonDo50K(object self) {
			Set100K()
			result("\n 100K"); }
          void OnButtonDo250K(object self) { 
			Set500K()
			result("\n 500K"); }
          myDlg(object self)
          {
               taggroup dlg = DLGCreateDialog("Mag select Dialog ")
               dlg.DLGAddElement(DLGCreateLabel("Select Magnification "))
               dlg.DLGAddElement(DLGCreatePushButton("25K", "OnButtonDo10K"))
               dlg.DLGAddElement(DLGCreatePushButton("100k", "OnButtonDo50k"))
               dlg.DLGAddElement(DLGCreatePushButton("500k", "OnButtonDo250k"))
               self.Init( dlg )
          }
    }
    
    clearResults()
    Alloc(myDlg).display("Imaging Condition ")