/*  lkV metadata
	Script to collect metadata during low-kV testing.
	Data is printed to the console and saved to a text file.
	Make sure to set file name and save path
	BLW @ NMRC; 23-02-24
*/ 
string UniqueSaveName( string save_dir, string &saveName, string fileName, string sample_name, string log_ext, number &exp_num, number fileCheck )
{
	try
	{
		while ( fileCheck == 1 )
		{
			filename = sample_name + "_" + exp_num + log_ext
			saveName = PathConcatenate( save_dir, filename )
			fileCheck = DoesFileExist( saveName )

			if ( fileCheck == 1 )
				exp_num = exp_num + 1
			else 
				break
		}
	}
	catch
	{
		result( "Something went wrong." )
	}
	return saveName
}

void CreateLogFile( string fileName, string saveName, number camid )
{
	// get experiment parameters 
	number end_angle = EMGetStageAlpha( )
	number spot_size = EMGetSpotSize( )
	string timestamp = FormatTimeString( GetCurrentTime(), 33 )
	// get camera and tem name
	string camera_name = CameraGetName( camid )
	string tem_name = "2100Plus"
	string tem_location = "Trent MTIF"
	number high_tension = EMGetHighTension( ) / 1000 //accelerating voltage in kV
	number focus = EMGetFocus( )
	
	image img := GetFrontImage()
	
	number phys_pixelsize_x, phys_pixelsize_y, scale_x, scale_y
	CameraGetPixelSize(camid, phys_pixelsize_x, phys_pixelsize_y)
	GetScale( img, scale_x, scale_y )
	
	string log_message = "---Low Votlage Alignment Metadata---" + "\n"
	log_message += "Save Location: " + saveName + "\n"
	log_message += "Microscope: " + tem_location + "\n"
	log_message += "Microscope: " + tem_name + "\n" 
	log_message += "Camera: " + camera_name + "\n" 
	log_message += "Accelerating Voltage (kV): " + high_tension + "\n"
	log_message += "Spot Size: " + spot_size + "\n" //Gatan spot size is 1 smaller than JEOL spot size
	log_message += "Standard Focus: " + focus + "\n"
	log_message += "Camera pixel size x/y (um): (" + phys_pixelsize_x + ", " + phys_pixelsize_y + ")\n" 
	log_message += "Scale (nm-1 px-1): " + scale_x + ", " + scale_y + "\n" 
	log_message += "Image size x/y (px): (" + ImageGetDimensionSize(img, 0) + ", " + ImageGetDimensionSize(img, 1) + ")\n" 
	log_message += "Data Collection Time: " + timestamp + "\n"
	result( "\n ===== \n" )
	result( log_message )
	// write log message to file
	number fileNum = CreateFileForWriting( saveName )
	WriteFile( fileNum, log_message )
	CloseFile( fileNum )
	result( "Wrote file: " + fileName )
	result( "Saved data to: " + saveName + "\n" )
}

string filename, saveName
number fileCheck = 1
number start_angle, end_angle
number camid = CameraGetActiveCameraID()

// directory to save file, no trailing slash
string save_dir = "X:\\" // directory to save log file
// name of file
string sample_name = "low_voltage"
string log_ext = ".txt"

UniqueSaveName( save_dir, saveName, fileName, sample_name, log_ext, exp_num, fileCheck )
CreateLogFile( fileName, saveName, camid, time_1, time_2, end_angle, start_angle, notes, fiddle, cam_sleep ) 