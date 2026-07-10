image stackima:=GetFrontImage()
image curimage, refimage, corimage, wrkref

number stackx,stacky,nproj
number i,j,xpos,ypos,width,height

stackx=stackima.ImageGetDimensionSize(0)
stacky=stackima.ImageGetDimensionSize(1)
nproj=stackima.ImageGetDimensionSize(2)


image shiftx, shifty, corr
shiftx:=realimage("Shiftx",4,nproj,1)
shifty:=realimage("Shifty",4,nproj,1)
corr:=realimage("Correlation coefficient",4,nproj,1)

number x,y, xsh,ysh, inix2,iniy2, scx,scy

if(stackima.GetSelection(y, x, ysh, xsh))
{
inix2=xsh-x
iniy2=ysh-y
scx=x+inix2/2
scy=y+iniy2/2
}
else
{
inix2=128
iniy2=128
scx=256
scy=256
}
 
result("\nTrack region center ("+scx+", "+scy+"), size ("+inix2+", "+iniy2+")")



for(x=1;X<inix2;x*=2)
	{}
if(x!=inix2)
{
result("\nSelection size must be an integer power of 2")
exit(0)
}

for(y=1;y<iniy2;y*=2)
	{}
if(y!=iniy2)
{
result("\nSelection size must be an integer power of 2")
exit(0)
}

shiftx=0
shifty=0


image hannX,hannY,hann
number percent=floor(75*0.005*min(inix2,iniy2))

		hannX := CreateFloatImage("", inix2,iniy2);
		hannX = 1;
		hannX[0,0,1,percent] = 0.5 - 0.5*cos( Pi() * icol / percent);
		
		i = 1;
		while( i < iniy2 )
		{	
			hannX[i, 0, 2*i, inix2] = hannX[0, 0, i, inix2];
			i = i * 2;
		}
		hannY := CreateFloatImage("", inix2,iniy2);
		hannY = 1;
		hannY[0,0,percent,1] = 0.5 - 0.5*cos( Pi() * irow / percent);
		
		i = 1;
		while( i < inix2 )
		{	
			hannY[ 0, i, iniy2, 2*i] = hannY[0, 0, iniy2, i];
			i = i * 2;
		}

		hann = hannX;
		FlipHorizontal(hann)
		hannX+=hann-1
		hann = hannY;
		FlipVertical(hann)
		hannY+=hann-1
		hann = hannX * hannY;

refimage:=realimage("",4,inix2,iniy2)
wrkref:=realimage("",4,inix2,iniy2)
curimage:=realimage("",4,inix2,iniy2)

corimage:=realimage("",4,inix2,iniy2)
corimage.Displayat(180+300,30)
shiftx.displayat(130,30)
shifty.displayat(130,70+200)
corr.displayat(130,110+400)
shiftx.SetWindowSize(350, 200 ) 
shifty.SetWindowSize(350, 200 ) 
corr.SetWindowSize(350, 200 ) 

refimage.displayat(180+300,70+iniy2)
curimage.displayat(180+300,140+iniy2*2)


number avenumber=5
number a,b, ceps=0, eps=0.001, ave, tail=1-1/avenumber
j=0

if(!GetNumber( "Number of images to average (1 - "+nproj+")", avenumber, avenumber ))
{ exit(0); }

avenumber=max(1,min(avenumber,nproj))

if(!GetNumber( "Accuracy (pixels)", eps, eps ))
{ exit(0); }

avenumber=max(1,min(avenumber,nproj))


number middleframe=floor(nproj/2)

while(1)
{


refimage=0


for( i = avenumber-1; i >=0 ; i-- )
{
		xsh=shiftx.getpixel(i,0)
		ysh=shifty.getpixel(i,0)
	wrkref=warp(stackima.slice(NewImageDataSlice(3,2,0,0,i,0,stackx,1,1,stacky,1)),icol+scx-inix2/2-xsh,irow+scy-iniy2/2-ysh)
	ave=average(wrkref)
	refimage=refimage*tail + ((wrkref-ave) * hann+ave)*(1-tail);

}

refimage/=avenumber



for( i = 0; i < nproj; ++i )
{
	if(i>0)
	{	
		xsh=shiftx.getpixel(i-1,0)
		ysh=shifty.getpixel(i-1,0)
		wrkref=warp(stackima.slice(NewImageDataSlice(3,2,0,0,i-1,0,stackx,1,1,stacky,1)),icol+scx-inix2/2-xsh,irow+scy-iniy2/2-ysh)
		ave=average(wrkref)
		refimage=refimage*tail + ((wrkref-ave) * hann+ave)*(1-tail);
     }

	xsh=shiftx.getpixel(i,0)
	ysh=shifty.getpixel(i,0)
	curimage=warp(stackima.slice(NewImageDataSlice(3,2,0,0,i,0,stackx,1,1,stacky,1)),icol+scx-inix2/2-xsh,irow+scy-iniy2/2-ysh)
	ave=average(curimage)
	curimage = (curimage-ave) * hann+ave;

	corimage=CrossCorrelation(refimage,curimage)
	corr[i,0]=corimage.max(x,y)
	
		a=(corimage.getpixel(x+1,y)+corimage.getpixel(x-1,y))*0.5-corimage.getpixel(x,y)
		b=(corimage.getpixel(x+1,y)-corimage.getpixel(x-1,y))*0.5-a*2*x

	shiftx[i,0]+=-b/a*0.5-inix2/2

		a=(corimage.getpixel(x,y+1)+corimage.getpixel(x,y-1))*0.5-corimage.getpixel(x,y)
		b=(corimage.getpixel(x,y+1)-corimage.getpixel(x,y-1))*0.5-a*2*y

	shifty[i,0]+=-b/a*0.5-iniy2/2
if(getkey()==32) exit(0)	
doevents()				
}


shiftx-=shiftx.average()
shifty-=shifty.average()

j++
result("\n"+j+" round, eps="+(sum(abs(shiftx))+sum(abs(shifty))-ceps)+"  corr="+corr.average())

if(getkey()==32) exit(0)	

if(abs(sum(abs(shiftx))+sum(abs(shifty))-ceps)<eps) break
ceps=sum(abs(shiftx))+sum(abs(shifty))

}  // end while

