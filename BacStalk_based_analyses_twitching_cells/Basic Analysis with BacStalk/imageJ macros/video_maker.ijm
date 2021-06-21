/* AIM of this macro:
 *  - create video from single images previously saved by Matlab
 *  - 4 differet videos will be created: 
 *  	- Non Moving cells:
 *  		- Phase contract image with contours and trajectory 
 *  		- Fluorescent image with poles position
 *  	- Moving cells:
 *  		- The same
*/

// TO MODIFY:

number=newArray("strain number"); 
Pil_type=newArray("strain name"); 

//folder_name="313 fliC- PilT_mNG"
dates=newArray("dates");
interval=newArray("intervals"); // format must match folder architecture in mian directory, e.g. "2s interval-2h37"
dir2="directory/";  // folder where everything is (i.e. folder with split_imageJ files for each strain)

do_fluocircles = 0; // must match the files that actually exist in the Movie folders after using the basic BacStalk analysis
do_nonmoving = 0;

setBatchMode(true)

for (f = 0; f < lengthOf(number); f++) {

	folder_name=number[f]+" "+Pil_type[f];

	for(d = 0; d < lengthOf(dates); d++) {

		date = dates[d];

		for(g = 0; g < lengthOf(interval); g++) {
	
			// STEP 1: open correct folder and get number of files for the loop:
			dir=dir2+folder_name+"/"+date+"/"+interval[g];
			print(dir);
			file=getFileList(dir);
			print("\\Clear"); // clear 'LOG' page
			//print(file.length) // check point
			//print(file[0])	// check point
			//file.length
			
			for(j=0; j<file.length; j++) { // file.length
					directory=dir+"/"+file[j]+"/Movie";
					print("Working on:"); // check point
					print(directory); // check point
				
				if (do_nonmoving) {
				// -----------STEP 2: NON MOVING CELLS-----------------------------------------------------
					if (do_fluocircles) {
					 // STEP a): Fluorescent with poles
						run("Image Sequence...", "open=["+directory+"/Non_Moving_Fluo_with_poles_1.tif] file=Non_Moving_Fluo_with_poles_ sort");
						saveAs("Tiff", directory+"/Non_Moving_Fluo_with_poles.tif");
						close();
						
						list=getFileList(directory);
						for (i=0; i<list.length ; i++){
							if (startsWith(list[i],"Non_Moving_Fluo_with_poles_")) {
								//print(directory+"/"+list[i]);
								ok=File.delete(directory+"/"+list[i]);
								}
						}
					}
					
				  // STEP b): phase contract with contours and trajectories
					run("Image Sequence...", "open=["+directory+"/Non_Moving_PC_with_trajectory_1.tif] file=Non_Moving_PC_with_trajectory_ sort");
					saveAs("Tiff", directory+"/Non_Moving_PC_with_trajectory.tif");
					close();
					
					list=getFileList(directory);
					for (i=0; i<list.length ; i++){
						if (startsWith(list[i],"Non_Moving_PC_with_trajectory_")) {
							ok=File.delete(directory+"/"+list[i]);
							}
					}
				}
					
				// -----------STEP 3: MOVING CELLS-----------------------------------------------------
				if (do_fluocircles) {
				 // STEP a): Fluorescent with poles
					run("Image Sequence...", "open=["+directory+"/Fluo_with_poles_1.tif] file=Fluo_with_poles_ sort");
					saveAs("Tiff", directory+"/Fluo_with_poles.tif");
					close();
					
					list=getFileList(directory);
					for (i=0; i<list.length ; i++){
						if (startsWith(list[i],"Fluo_with_poles_")) {
						//	print(directory+"/"+list[i]);
							ok=File.delete(directory+"/"+list[i]);
							}
					}
				}
				
				  // STEP b): phase contract with contours and trajectories	
					run("Image Sequence...", "open=["+directory+"/PC_with_trajectory_1.tif] file=PC_with_trajectory_ sort");
					saveAs("Tiff", directory+"/PC_with_trajectory.tif");
					close();
					
					list=getFileList(directory);
					for (i=0; i<list.length ; i++){
						if (startsWith(list[i],"PC_with_trajectory_")) {
							ok=File.delete(directory+"/"+list[i]);
							}
					}
			}
		}
	}
}

setBatchMode(false);

	print("Done with:"); // check point
	Array.print(number); // check point