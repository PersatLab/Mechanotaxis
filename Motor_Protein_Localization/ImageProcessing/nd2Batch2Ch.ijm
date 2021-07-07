timeA=getTime();
setBatchMode(true);
dir=getDirectory("Choose a Directory");
dirList=getFileList(dir);
d=0;
stopDir=true;
while (stopDir) {
	if (endsWith(dirList[d], "/")){
		d=d+1;
	} else {
		if(d>0||d<dirList.length-1){
			start=Array.slice(dirList,0,d);
			end=Array.slice(dirList,d+1,dirList.length);
			dirList=Array.concat(start,end);
		} else if(d==0){
			dirList=Array.slice(dirList,d+1,dirList.length);
		} else if(d==(dirList.length-1)){
			dirList=Array.slice(dirList,0,d);
		}
	}
	
	if(d==dirList.length){
		stopDir=false;
	}
}
print(dirList.length);
if (dirList.length==0) {
	Dir=dir;
	print("Welcome to the extraction of the PhaseContrast and YFP channel of nd2 files");
	splitDir=Dir+"Split";
	print("Images will be saved in the following folder:\n" + splitDir);
	print("Extraction in progress, please wait...");
	File.makeDirectory(splitDir);
	File.makeDirectory(splitDir+File.separator+"PhaseContrast");
	File.makeDirectory(splitDir+File.separator+"Fluorescence");
	list = getFileList(Dir);
	percent=0;
	progressBar="#";
	n=0;
	totImages=0;
	stopit=true;
	AVGBkg=0;
	AVGFrames=newArray(0);
	while (stopit) {
		if (endsWith(list[n], ".nd2")){
			if(indexOf(list[n], "Bkg")>-1){
				if(n>0||n<list.length-1){
					start=Array.slice(list,0,n);
					end=Array.slice(list,n+1,list.length);
					list=Array.concat(start,end);
				} else if(n=0){
					list=Array.slice(list,n+1,list.length);
				} else if(n=list.length-1){
					list=Array.slice(list,0,n);
				}
			} else {
				totImages=totImages+1;
			}
		}n=n+1;
		if(n>lengthOf(list)-1) stopit=false;
	}
	print("tot images = " + totImages+"\n");
	for (i=0; i<list.length; i++) {
	     if (endsWith(list[i], ".nd2")){
	               print("\\Update:"+percent+"% "+progressBar);
		
		run("Bio-Formats Importer", "open=["+Dir+File.separator+list[i]+"] autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
		selectWindow(list[i]+" - C=0");
		imgName=getTitle();
		idPC=getImageID();
		run("Subtract Background...", "rolling=50 light");
		saveAs("Tiff", splitDir+File.separator+"PhaseContrast"+File.separator+imgName+".tif");
	
		selectWindow(list[i]+" - C=1");
		imgName=getTitle();
		idFluo=getImageID();
		run("Subtract Background...", "rolling=50 sliding");
		saveAs("Tiff", splitDir+File.separator+"Fluorescence"+File.separator+imgName+".tif");
	    }
	     percent=floor((i+1)/list.length*100);
	     progressBar=progressBar+"#";
	}
	print("\\Update:"+percent+"%"+progressBar);
	run("Close All");
} else {
	print("Welcome to the extraction of the PhaseContrast and YFP channel of nd2 files");
	for (j=0; j<dirList.length; j++) {
		Dir=dir+dirList[j];
		splitDir=Dir+"Split";
		print("Images will be saved in the following folder:\n" + splitDir);
		print("Extraction in progress, please wait...");
		File.makeDirectory(splitDir);
		File.makeDirectory(splitDir+File.separator+"PhaseContrast");
		File.makeDirectory(splitDir+File.separator+"Fluorescence");
		list = getFileList(Dir);
		percent=0;
		progressBar="#";
		n=0;
		totImages=0;
		stopit=true;
		AVGBkg=0;
		AVGFrames=newArray(0);
		while (stopit) {
			if (endsWith(list[n], ".nd2")){
				if(indexOf(list[n], "Bkg")>-1){
					if(n>0||n<list.length-1){
						start=Array.slice(list,0,n);
						end=Array.slice(list,n+1,list.length);
						list=Array.concat(start,end);
					} else if(n=0){
						list=Array.slice(list,n+1,list.length);
					} else if(n=list.length-1){
						list=Array.slice(list,0,n);
					}
				} else {
					totImages=totImages+1;
				}
			}n=n+1;
			if(n>lengthOf(list)-1) stopit=false;
		}
		print("tot images = " + totImages+"\n");
		for (i=0; i<list.length; i++) {
		     if (endsWith(list[i], ".nd2")){
		               print("\\Update:"+percent+"% "+progressBar);
			
			run("Bio-Formats Importer", "open=["+Dir+File.separator+list[i]+"] autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
			selectWindow(list[i]+" - C=0");
			imgName=getTitle();
			idPC=getImageID();
			run("Subtract Background...", "rolling=50 light");
			saveAs("Tiff", splitDir+File.separator+"PhaseContrast"+File.separator+imgName+".tif");
		
			selectWindow(list[i]+" - C=1");
			imgName=getTitle();
			idFluo=getImageID();
			run("Subtract Background...", "rolling=50 sliding");
			saveAs("Tiff", splitDir+File.separator+"Fluorescence"+File.separator+imgName+".tif");
		    }
		     percent=floor((i+1)/list.length*100);
		     progressBar=progressBar+"#";
		}
		print("\\Update:"+percent+"%"+progressBar);
		run("Close All");
	}
}
setBatchMode(false);
timeB=getTime();
ExecTime=(timeB-timeA)/1000;
	
print("done in "+round(ExecTime)+" s");