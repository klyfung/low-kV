importClass(Packages.ij.IJ);
var imp = IJ.getImage();
var n = imp.getStackSize();

for( var i = 0; i < n; ++i) {
	imp.setSlice(i+1);
    IJ.run("Add Image...", "image=[116857 overlay.tif] x=0 y=0 opacity=50");
}