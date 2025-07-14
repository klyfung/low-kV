for (i = 0; i < 10; i++) {
	filepath=File.openDialog("Select an image file");
	imageDir=File.directory;
	fileList = getFileList(imageDir); 
	numberSlice=fileList.length;
	run("TIFF Virtual Stack...",
		"open=[&filepath]");
}

run("Concatenate...");

saveAs("Tiff");

close();