setBatchMode(true);

ids = newArray(nImages);

for (i=0;i<nImages;i++) {
	selectImage(i+1);
	ids[i] = getTitle();
	run("FFT");
	saveAs("TIF", "F:/Processed data/NTU Plus/80 kV/4. Through-focus series/"+ids[i]+".tif");
}