setBatchMode(true);

ids = newArray(nImages);

for (i=0;i<nImages;i++) {
	selectImage(i+1);
	ids[i] = getTitle();
	saveAs("PNG", "C:/Users/Kayleigh/Documents/GitHub/PhD/PCC/RH16/OneView/2018-07-13 RH16 PCC@SWNTs/1725-2132 aligned/"+ids[i]+".png");
}