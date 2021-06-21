/* AIM of this macro:
 *  - create folder in correct position to run the Matlab analysis directely after
 *  - open the .nd2 file and save as tiff the two channel separately (C0-Phase contract & C1- fluorescent channel)
 *  - C0 channel save each time fram indipendently (for backstalk)
 *  - save a csv file in the folder with all the info on the video ((original name, pixel size, time interval) that will be use for the analysis
*/

// TO MODIFY:

// modify the position of the interval and the time point!
index_int=2; // filename of original image sequence (format: strain number_variable text_sample time (e.g. 2h37)_image interval (e.g. 2s)_movie number) will be split at every "_"
index_time=3;
number=newArray("strain number"); 
Pil_type=newArray("strain name"); 
folder_name=newArray("directory of original image sequences");
date=newArray("dates");
match=".*text.*" // what to look for in file name
directory_main="directory/"; // has to be the directory from which the BacStalk analysis will be run!
only_PC=0 // if only phase contrast images without fluorescence -> 1, for phase contrast and fluorescence -> 0
correct_drift=0 // 1 if YES, 0 if NO -> runs StackReg_translation plugin !!! does NOT work well with fluo and PC images together!!!

// STEP 1: chose folder nd2 douments are
main_dir=getDirectory("Choose a Directory")

setBatchMode(true)

for(s=0; s<lengthOf(number);s++){

dir=main_dir+folder_name[s]+"/"; 
list=getFileList(dir);

// STEP 2: create folder
directory=directory_main+number[s]+" "+Pil_type[s]+"/";
File.makeDirectory(directory);

//name_folder=0; // variable define to increse folder number at each loop

for(i=0; i<list.length;i++){
	if (startsWith(list[i],number[s])){
	if (matches(list[i], match)){ // change if all or only some of the files should be processed
	print("Working on:");
	print(dir); // check point
	print(list[i]); // check point
	// STEP a): split name of video to get all info necessary 2h37
	split_name=split(list[i],"_");
	interval=split_name[split_name.length-index_int]+" interval"; //split_name.length-?: for the interval time between frames
	interval=interval+"-"+split_name[split_name.length-index_time]; //split_name.length-?: to know after how long on on plate video had been recorded

	// STEP b): create folders
	File.makeDirectory(directory+date[s]);
	File.makeDirectory(directory+date[s]+"/"+interval)

	nbr_folder=getFileList(directory+date[s]+"/"+interval); // to know how many folders are aleady present 
	name_folder=nbr_folder.length+1;
	new_directory=directory+date[s]+"/"+interval+"/"+name_folder;
	
	File.makeDirectory(new_directory)
	File.makeDirectory(new_directory+"/Movie") // MATLAB will save each image separately there. Video_maker.ijm will make a video with images from there


// STEP 3 : open video and extract info
	open(dir+list[i]);
	saveAs("Tiff", new_directory+"/data");
	getPixelSize(unit, pw, ph);

	if(!only_PC){
		
	
// STEP 4: split the channels
	run("Split Channels");
	
// STEP 5 : save fluorescent channel al C1-data
	selectWindow("C2-data"+".tif");
	run("Subtract Background...", "rolling=50 stack");
	if(correct_drift){
		run("StackReg ", "transformation=Translation");
	}
	C1_data=new_directory+"/C1-data.tif";
	saveAs("Tiff", C1_data);
	close();

// STEP 6 : save phase contract channel al C0-data + save each time frae separately (for BackStalk)
	selectWindow("C1-data"+".tif");
	if(correct_drift){
		run("StackReg ", "transformation=Translation");
	}
	C0_data=new_directory+"/C0-data.tif";
	saveAs("Tiff", C0_data);
	run("Image Sequence... ", "format=TIFF name=C0-data_t digits=3 save=["+new_directory+"/C0-data_t000.tif]");
	close();
	}
	
	if(only_PC) {	
// STEP 6 : save phase contract channel al C0-data + save each time frae separately (for BackStalk)
	if(correct_drift){
		run("StackReg ", "transformation=Translation");
	}
	C0_data=new_directory+"/C0-data.tif";
	saveAs("Tiff", C0_data);
	run("Image Sequence... ", "format=TIFF name=C0-data_t digits=3 save=["+new_directory+"/C0-data_t000.tif]");
	close();
		
	}
// STEP 7: save csv file containing all the info needed for analysis (original name, pixel size, time interval)
	// save csv file
	print("\\Clear"); // clear 'LOG' page
	print(dir);
	print(list[i]);
	print(pw);
	print(ph);
	frame_interval=split(interval,"s");
	print(frame_interval[0]);
	selectWindow("Log");
	saveAs("Text",new_directory+"/parameters.csv");
	
	print("\\Clear"); // clear 'LOG' page
	ok = File.delete(new_directory+"/data.tif"); 
	}}
	
}
}

setBatchMode(false)

print("Done with:");
print(dir);
