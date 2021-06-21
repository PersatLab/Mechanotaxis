// @File(Label="Select data path", style="directory") dir

setBatchMode(true)

File.makeDirectory(dir+File.separator+"Tiles_5s");

movies=getFileList(dir);
movies_length=lengthOf(movies);


for (j = 0; j < movies_length; j++) {

	if (matches(movies[j], ".*h.*")) {
		
		dot = indexOf(movies[j], ".");
		title = substring(movies[j], 0, dot);

		open(dir+File.separator+movies[j]);
		
		id = getImageID;

		N = 2;
		w = getWidth;
		h = getHeight;
		
		for(i=0; i<N; i++){
			sector = i+1;
			selectImage(id);
			run("Duplicate...", "duplicate");
			makeRectangle(0, i*h/N, w/N, h/N);
			run("Crop");
			run("StackReg ", "transformation=Translation");
			//run("Reduce...", "reduction=5");
			saveAs("Tiff", dir+File.separator+"Tiles_5s"+File.separator+title+"_sector_"+sector+".tif");
			close();
		}

		for(i=0; i<N; i++){
			sector = i+3;
			selectImage(id);
			run("Duplicate...", "duplicate");
			makeRectangle(w/N, i*h/N, w/N, h/N);
			run("Crop");
			run("StackReg ", "transformation=Translation");
			//run("Reduce...", "reduction=5");
			saveAs("Tiff", dir+File.separator+"Tiles_5s"+File.separator+title+"_sector_"+sector+".tif");
			close();
		}
		
		
		selectImage(id);
		close();
		
		print("Done with:");
		print(title);
		
	}
}

setBatchMode(false)