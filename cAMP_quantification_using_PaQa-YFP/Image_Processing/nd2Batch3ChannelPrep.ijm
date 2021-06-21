// @File(label="Select the folder of images to process", style="directory") dir
// @String(label="1st channel name", value="PhaseContrast") channel1
// @String(label="2nd channel name", value="PaQa") channel2
// @String(label="3rd channel name", value="RFP") channel3

/* This macro allows to split all nd2 files (containing 3 channels only) included in the user defined directory "dir".
 * A background subtraction is done on 3 channels separately and save individual images into separate folders
 * named by the user ("channel1", "channel2" and "channel3").
 */

// Get start time to compute the macro duration
timeA=getTime();

// Do not display images to gain some computation speed
setBatchMode(true);

// Get user-defined root directory content
dirList=getFileList(dir);
Array.print(dirList);
print(dirList.length);
d=0;
 //Folder counter
stopDir=true;
 //condition to exit while loop
while (stopDir) {
 // Count how many subfolders there are in the user defined directory so to go through each of them
	if (dirList.length>0) {
		if (endsWith(dirList[d], "/")){
			d=d+1;
		} else { //Remove non folder items from dirList
			if(d>0||d<dirList.length-1){
				start=Array.slice(dirList,0,d);
				end=Array.slice(dirList,d+1,dirList.length);
				dirList=Array.concat(start,end);
			} else if(d==0){
				dirList=Array.slice(dirList,d+1,dirList.length);
				Array.print(dirList);
			} else if(d==(dirList.length-1)){
				dirList=Array.slice(dirList,0,d);
			}
		}
		
		if(d==dirList.length){
			stopDir=false;
		}
	} else {
		Dialog.create("Data error");
		Dialog.addMessage("Empty folder! \nMacro aborted, please try with another folder");
		Dialog.show();
		break;
	}
}

//Setting up the progress bar
progressBar_length = 50;
empty_character = "  ";


if (dirList.length==0) { // Do if all images are located in the user defined directory
	print("Number of directories found = "+dirList.length);
	print("Entering single folder extraction of the "+channel1+", "+channel2+" and "+channel3+" fluorescence channels of nd2 files");

	//Creating floders for split channels individual images
	Dir=dir;
	splitDir=Dir + File.separator+"Split";
	print("Images will be saved in the following folder:\n" + splitDir);
	print("Extraction in progress, please wait. \n");
	File.makeDirectory(splitDir);
	File.makeDirectory(splitDir+File.separator+channel1);
	File.makeDirectory(splitDir+File.separator+channel2);
	File.makeDirectory(splitDir+File.separator+channel3);
	list = getFileList(Dir);
	percent=0;
	
	n=0;
	totImages=0;
	stopit=true;
	while (stopit) {
		if((endsWith(list[n], ".nd2"))){
			totImages=totImages+1;
		} n=n+1;
		if(n>lengthOf(list)-1) stopit=false;
	}
	print("tot images = " + totImages+"\n");
	progress_steps=floor(progressBar_length/totImages);
	progressBar=genStr(empty_character, progressBar_length);
	im=0;
	for (i=0; i<list.length; i++) {
	     if (endsWith(list[i], ".nd2")){
	     	print("\\Update:"+"Progress:"+progressBar+" : "+percent+"%");		
			run("Bio-Formats Importer", "open=["+Dir+File.separator+list[i]+"] autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
			
			selectWindow(list[i]+" - C=0");
			imgName=getTitle();
			idPC=getImageID();
			saveAs("Tiff", splitDir+File.separator+channel1+File.separator+imgName+".tif");
		
			selectWindow(list[i]+" - C=2");
			imgName=getTitle();
			idRFP=getImageID();
			run("Duplicate...", "use");
			idRFP_first=getImageID;
			run("Subtract Background...", "rolling=50 sliding");
			temp=getValue("Median");
			AVGFramesRFP=Array.concat(AVGFrames,temp);
			saveAs("Tiff", splitDir+File.separator+channel2+File.separator+imgName+".tif");
		
			selectWindow(list[i]+" - C=1");
			imgName=getTitle();
			idFITC=getImageID();
			run("Duplicate...", "use");
			idFITC_first=getImageID;
			run("Subtract Background...", "rolling=50 sliding");
			temp=getValue("Median");
			AVGFramesFITC=Array.concat(AVGFrames,temp);
			saveAs("Tiff", splitDir+File.separator+channel3+File.separator+imgName+".tif");
			
			run("Close All");
			percent=floor((im)/totImages*100);
			progress=genStr("#", (im)*progress_steps);
			empty_spaces=genStr(empty_character, progressBar_length-(im)*progress_steps);
			progressBar=progress+empty_spaces;
			im=im+1;
	    }
	     
	}
	progressBar=genStr("#", progressBar_length);
	percent=100;
	print("\\Update:"+"Progress:"+progressBar+" : "+percent+"%");
	run("Close All");
	
} else{ // Do if you want to process all subfolder. As for example if you want to process different strains made in one day.
	print("Number of directories found = "+dirList.length);
	print("Entering batch extraction mode of the "+channel1+", "+channel2+" and "+channel3+" fluorescence channels of nd2 files");
	for (j=0; j<dirList.length; j++) {
		Dir=dir+File.separator+dirList[j];
		splitDir=Dir+"Split";
		print("Images will be saved in the following folder:\n" + splitDir);
		print("Extraction in progress, please wait. \n");
		File.makeDirectory(splitDir);
		File.makeDirectory(splitDir+File.separator+channel1);
		File.makeDirectory(splitDir+File.separator+channel2);
		File.makeDirectory(splitDir+File.separator+channel3);
		list = getFileList(Dir);
		Array.print(list);
		percent=0;
		progressBar="#";
		n=0;
		totImages=0;
		stopit=true;
		while (stopit) {
			if(endsWith(list[n], ".nd2")){
				totImages=totImages+1;
			} n=n+1;
			if(n>lengthOf(list)-1) stopit=false;
		}
		print("tot images = " + totImages+"\n");
		progress_steps=floor(progressBar_length/totImages);
		progressBar=genStr(empty_character, progressBar_length);
		im=0;
		for (i=0; i<list.length; i++) {
		     if (endsWith(list[i], ".nd2")){
		     	print("\\Update:"+"Progress:"+progressBar+" : "+percent+"%");		
				run("Bio-Formats Importer", "open=["+Dir+File.separator+list[i]+"] autoscale color_mode=Default split_channels view=Hyperstack stack_order=XYCZT");
				imgName=getTitle();
				selectWindow(list[i]+" - C=0");
				imgName=getTitle();
				idPC=getImageID();
				saveAs("Tiff", splitDir+File.separator+channel1+File.separator+imgName+".tif");
			
				selectWindow(list[i]+" - C=1");
				imgName=getTitle();
				idRFP=getImageID();
				run("Duplicate...", "use");
				idRFP_first=getImageID;
				run("Subtract Background...", "rolling=50 sliding");
				saveAs("Tiff", splitDir+File.separator+channel2+File.separator+imgName+".tif");
			
				selectWindow(list[i]+" - C=2");
				imgName=getTitle();
				idFITC=getImageID();
				run("Duplicate...", "use");
				idFITC_first=getImageID;
				run("Subtract Background...", "rolling=50 sliding");
				saveAs("Tiff", splitDir+File.separator+channel3+File.separator+imgName+".tif");
				
				run("Close All");
				percent=floor((im)/totImages*100);
				progress=genStr("#", (im)*progress_steps);
				empty_spaces=genStr(empty_character, progressBar_length-(im)*progress_steps);
				progressBar=progress+empty_spaces;
				im=im+1;
		    }
		}
	progressBar=genStr("#", progressBar_length);
	percent=100;
	print("\\Update:"+"Progress:"+progressBar+" : "+percent+"%");
	run("Close All");
	}
}	
setBatchMode(false);

timeB=getTime();
ExecTime=(timeB-timeA)/1000;

print("done in "+ExecTime+" s\n");

//------------------------------------------------------------------functions-------------------------------------------------------------------

/* genStr(Char, Reps) is a function that returns a my_string with "Reps" number of "Char" repetitions.
 * Example: Char=$, Reps= 4, my_string=$$$$.
 */
function genStr(Char, Reps){
	my_string = "";
	for (i = 0; i < Reps; i++) {
		my_string=my_string+Char;
	}
	return my_string;
}
