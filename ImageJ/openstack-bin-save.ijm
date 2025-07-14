filepath=File.openDialog("Select an image file");
imageDir=File.directory;
fileList = getFileList(imageDir); 
numberSlice=fileList.length;
run("Image Sequence...", 
  "open=[&filepath]"+
  " number="+numberSlice+
  " starting=1"+
  " increment=1"+
  " scale=100 "+
  "file=[.dm3] "+
  "sort use");

run("Bin...",
	"x=1 y=1 z=5 bin=Sum");

saveAs("Tiff");

close();
