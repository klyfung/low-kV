image stackima:=GetFrontImage()

number stackx,stacky,nproj
number i,j,xpos,ypos,width,height
  
stackx=stackima.ImageGetDimensionSize(0)
stacky=stackima.ImageGetDimensionSize(1)
nproj=stackima.ImageGetDimensionSize(2)

image shiftx, shifty
number xsh,ysh
gettwoimages("Shift images",shiftx, shifty)

image dst:=stackima
ImageDisplay Bdisi
Bdisi = ImageGetImageDisplay(dst,0)


image dstslice:=RealImage("",4,stackx,stacky)
dstslice=0



for(i=0;i<nproj;i++)
{

xsh=shiftx.getpixel(i,0)
ysh=shifty.getpixel(i,0)

dstslice=warp(stackima.slice(NewImageDataSlice(3,2,0,0,i,0,stackx,1,1,stacky,1)),icol-xsh,irow-ysh)
dstslice.UpdateImage()
dst[icol,irow,i]=dstslice
Bdisi.ImageDisplaySetDisplayedLayers(i,i)
if(getkey()==32) exit(0)
DoEvents()
}




dst.showimage() 