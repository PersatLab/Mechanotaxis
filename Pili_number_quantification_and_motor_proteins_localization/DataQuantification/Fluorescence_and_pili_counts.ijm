// @File(label="DataSet save directory", style="directory") SaveDir
// @Boolean(Label="Reset registration parameters", value=false) NewReg
// @Float(Label="Scaling factor", value=1.38202) scaling
// @Integer(Label="Pole radius", value=10) radius
// @Integer(Label="BiologicalReplicate", value=1) BioRep
// @Integer(Label="Cell min area", value=450) MinCellArea
// @Boolean(Label="First event?", value=false) isFirst
// @Integer(Label="Event nubmer", value=1) EventNB
// @String(label="", description="Chose between: Li dark, IsoData dark, Otsu dark or Triangle dark (Brightfield)", value="Otsu dark") threshold
// @Boolean(Label="Brightfield image?", value=false) Brightfield
// @Boolean(Label="Count retractions?", value=false) RetractCount

// ------------------------------------------------Main -------------------------------------------------------
setTool("line");

// Set global variables
RootMinCellArea = MinCellArea; // value of minimum cell area to take into account for Analize particles
Global_Stop = false;
file_path=SaveDir+File.separator+"CurrentDataPoints.txt";

//Initialization of parameters:
run("Set Measurements...", "area mean min centroid redirect=None decimal=5");


//Check if first time lounching the software or if you want to start at a precise event number
if (isFirst){
	Coordinates=newArray(271,284,245,249,205,213,187,190, EventNB);
	print("\\Clear");
}


//Main loop
while (Global_Stop == false){
	//Initializing results, ROI manager and log windows
	if(isOpen("Results")){
			selectWindow("Results");
			run("Close");
	 	}
	roiManager("Reset");
	print("Macro start for event"+EventNB);
	//Initialization of parameters
	if (!isFirst){
		Coordinates = getCurrentDataPoints(file_path);
		EventNB=Coordinates[8];
	}
		
	//Opening images
	openWorkingImg(SaveDir, EventNB, "iSCAT");
	openWorkingImg(SaveDir, EventNB, "TIRF");
	if (nImages>0){
		run("Enhance Contrast", "saturated=0.35");
		run("Tile");
	}
	
	//Checking Image quality and properties
	waitForUser( "Pause","Inspect fluorescent image");
	Dialog.create("Fluorescence parameters");
		Dialog.addCheckbox("Discard event?", false);
		Dialog.addCheckbox("New Registration?", NewReg);
		Dialog.addCheckbox("Specific fluorescent frame(s)?", false);
		Dialog.addString("Fluorescent frame(s) (1 frame=a or range=a-b)", "1");
		Dialog.addCheckbox("Quit", false);
	Dialog.show();
	dropEvent=Dialog.getCheckbox();
	NewReg=Dialog.getCheckbox();
	JustFrame=Dialog.getCheckbox();
	FrameNb=Dialog.getString();
	Quit=Dialog.getCheckbox();

	//Quitting software
	if (Quit){
		dropEvent = true;
		Global_Stop = true;
	}

	//Analysis if you don't drop the event
	if(!dropEvent){
		//Identify iSCAT and Tirf images
		titles = newArray(nImages());
		for (i=1; i<=nImages(); i++) {
			selectImage(i);
			titles[i-1] = getTitle();
			if (indexOf(titles[i-1],"iSCAT")>0){
				IDiSCAT=getImageID;
			} else if (indexOf(titles[i-1],"tirf")>0){
				IDtirf=getImageID;
			}
		}

		//Get directory for TIRF images to save CSV result file.
		selectImage(IDtirf);
		dir=getInfo("image.directory");
		Title=getTitle();

		//iSCAT and tirf imgaes registration
		IDReg=registration(IDiSCAT, IDtirf, NewReg, JustFrame, FrameNb, Coordinates, dir, scaling, Brightfield);
		run("Tile");
		selectImage(IDReg);
		run("In [+]");
		selectImage(IDiSCAT);
		run("In [+]");
		
		//Initialization of variables
		Pole=newArray(2);
		Pole[0]="Dim";
		Pole[1]="Bright";
		
		/*PiliCount = newArray(2);
		FlagellaCount = newArray(2);
		area = newArray(2);
		mean = newArray(2);
		min = newArray(2);
		max = newArray(2);
		std = newArray(2);
		TotalFluPole = newArray(2);*/

		
		//Loop over cells in the event
		AddCell=true;
		CellNb=1;
		while (AddCell==true){
			Discard_cell=false;
			n=nResults;
			Booleans=cellAnalysis(Pole, IDiSCAT, IDReg, radius, AddCell, Discard_cell, Global_Stop, threshold, MinCellArea, RootMinCellArea, n, Brightfield, CellNb, RetractCount);
			CellNb=CellNb+1;
			AddCell=Booleans[0];
			Global_Stop=Booleans[1];
		}
		
		selectImage(IDReg);
		run("Save");
		close();
		
		Ind=indexOf(Title, "_tirf");
		NewTitle=substring(Title, 0, Ind);
		saveAs("Results", dir+NewTitle+".csv");
		
		run("Clear Results");
		
		/*selectImage(IDiSCAT);
		close();
		selectImage(IDtirf);
		close();*/
		run("Close All");
		
		if (Global_Stop == false) isFirst = false;
		
		EventNB=EventNB+1;
		Coordinates[8]=EventNB;
		file=File.open(file_path);
		datapoints2save=""+Coordinates[0]+","+Coordinates[1]+","+Coordinates[2]+","+Coordinates[3]+","+Coordinates[4]+","+Coordinates[5]+","+Coordinates[6]+","+Coordinates[7]+","+Coordinates[8];
		print(file, datapoints2save);
		File.close(file);
	
	} else {
		EventNB=EventNB+1;
		Coordinates[8]=EventNB;
		file=File.open(file_path);
		datapoints2save=""+Coordinates[0]+","+Coordinates[1]+","+Coordinates[2]+","+Coordinates[3]+","+Coordinates[4]+","+Coordinates[5]+","+Coordinates[6]+","+Coordinates[7]+","+Coordinates[8];
		print(file, datapoints2save);
		File.close(file);
		run("Close All");
	}
}
selectWindow("Log");
saveAs("Text", SaveDir+File.separator+"Log.txt");
//----------------------------------------------------Functions--------------------------------------------------

/*  cellAnalysis(Pole, PiliCount, FlagellaCount, area, mean, min, max, std, TotalFluPole, IDiSCAT, IDReg,
 *  radius, AddCell, Discard_cell, Global_Stop, threshold, MinCellArea, RootMinCellArea, n) Allows to
 *  automatically detect cell poles and record number of pili in each pole.
 * 
 */
 
function cellAnalysis(Pole, IDiSCAT, IDReg, radius, AddCell, Discard_cell, Global_Stop, threshold, MinCellArea, RootMinCellArea, n, Brightfield, CellNb, RetractCount){
	//Initializing variables
	PiliCount = newArray(2);
	FlagellaCount = newArray(2);
	area = newArray(2);
	mean = newArray(2);
	min = newArray(2);
	max = newArray(2);
	std = newArray(2);
	TotalFluPole = newArray(2);
	if(!isOpen("Results")){
		Table.create("Results");
	}
	
	//Ask user to select cell of interest
	roiManager("Show All with labels");
	waitForUser( "Pause","Draw line along the cell starting from the dim to the bright pole");
	getSelectionBounds(x, y, SizeSquareX, SizeSquareY);

	//Extract squared region from registered image containing the cell of interest
	selectImage(IDReg);
	correction=2*radius;
	makeRectangle(x-correction, y-correction, SizeSquareX+2*correction, SizeSquareY+2*correction);
	run("Duplicate...", "title=cell"+n+" duplicate");
	CellID=getImageID;
	run("Duplicate...", "title=Mask"+n+" duplicate");
	MaskID=getImageID;
	selectImage(MaskID);
	if(Brightfield){
		run("Find Edges");
		setOption("BlackBackground", false);
		setAutoThreshold("Triangle dark");
		run("Convert to Mask");
		run("Dilate");
		run("Dilate");
		run("Fill Holes", "stack");
		run("Erode");
		run("Erode");
		run("Median...", "radius=2 stack");
	} else {
		setAutoThreshold(threshold); //Li dark
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Median...", "radius=2");
	}
	
	Cell_detected = false;
	while (Cell_detected == false){
		selectImage(MaskID);
		run("Analyze Particles...", "size="+MinCellArea+"-Infinity show=[Bare Outlines] exclude");
		getStatistics(a, m, min_check, max_check, s, h);
		ID_Particle=getImageID();
		if (min_check == max_check){
			selectImage(ID_Particle);
			close();
			Dialog.create("Min Cell Area too big, no cells detected");
				Dialog.addNumber("Enter a value smaller than "+MinCellArea, 0);
				if (MinCellArea==0){
					Dialog.addCheckbox("Discard cell?", false);
					Dialog.addCheckbox("add another cell?", false);
				}
			Dialog.show();
			MinCellArea=Dialog.getNumber();
			if (MinCellArea==0){
				Discard_cell=Dialog.getCheckbox();		
				AddCell=Dialog.getCheckbox();
			}
			if(Discard_cell){
				Cell_detected = true;
				MinCellArea = RootMinCellArea;
				selectImage(MaskID);
				close();
				selectImage(CellID);
				close();
		
			}
		} else {
			Cell_detected = true;
		}
	}
		
	if(!Discard_cell){
		run("Fill Holes");
		run("Create Selection");
		getSelectionCoordinates( xCell_raw, yCell_raw);
		PixSel=pixelizeSelection(xCell_raw, yCell_raw, "closed");
		xCell=Array.slice(PixSel,0,lengthOf(PixSel)/2);
		yCell=Array.slice(PixSel,lengthOf(PixSel)/2,lengthOf(PixSel));
		//print(xCell[0]);
		selectImage(CellID);
		run("Restore Selection");
		getStatistics(Cellarea, Cellmean, Cellmin, Cellmax, Cellstd, histogram);
		TotalFlu=Cellmean*Cellarea;
		setResult("Label", n, Title);
		setResult("Cell_ID", n, CellNb);
		setResult("BiologicalReplicate", n, BioRep);
		setResult("CellArea", n, Cellarea);
		setResult("CellMean", n, Cellmean);
		setResult("CellTotalFluorescence", n, TotalFlu);
		setResult("CellMin", n, Cellmin);
		setResult("CellMax", n, Cellmax);
		setResult("CellStd", n, Cellstd);
		selectImage(MaskID);
		close();
		selectImage(CellID);
		close();
		selectImage(ID_Particle);
		close();
		
		new_x=correctSelection(xCell, x-correction);
		new_y=correctSelection(yCell, y-correction);
		selectImage(IDReg);
		getDimensions(width, height, channel, slice, frame);
		makeSelection( "polyline", new_x, new_y );
		roiManager("Add");
		LastROI=roiManager("count");
		Poles_Coordinates=getPolesCoordinates(new_x, new_y , width);
		pole_rad=Poles_Coordinates[4];
		for(i=0; i<2; i++){
			if(i==0){
				r=0;
			} else if (i==1){
				r=2;
			}
			selectImage(IDReg);
			// makeOval(Poles_Coordinates[5+r]-round(pole_rad/2),Poles_Coordinates[5+r+1]-round(pole_rad/2),pole_rad,pole_rad);
//			//
			x_i=Poles_Coordinates[5+r]-round(pole_rad/2);
			y_i=Poles_Coordinates[5+r+1]-round(pole_rad/2);
			makeOval(x_i, y_i, pole_rad, pole_rad);
			getStatistics(ar, me, mi, ma, st, histo);
			TotFlu_i=ar*me;
			print("\nPole i="+i+" at "+x_i+";"+y_i+" has an initial total flu of "+TotFlu_i);
			Open=false;
			if(isOpen("Results")){
				Open=true;
				IJ.renameResults("Results","Main_Results");
			}
			run("Find Maxima...", "prominence=10 output=[List]"); //Should create a new Table
			if (nResults>1) {
				x_ar=newArray(nResults);
				y_ar=newArray(nResults);
				for (i = 0; i < nResults; i++) {
					x_ar[i]=getResult("X", i);
					y_ar[i]=getResult("Y", i);
				}
				Array.getStatistics(x_ar, min, max, x_cor, stdDev);
				Array.getStatistics(y_ar, min, max, y_cor, stdDev);
			} else {
				if (nResults==0) {
					getSelectionBounds(x_cor, y_cor, trashX, trashY);
				}else {
					x_cor=getResult("X", 0);
					y_cor=getResult("Y", 0);
				}
			}
			selectWindow("Results"); 
			run("Close");
			
			if (Open){
				IJ.renameResults("Main_Results","Results");
			}
			
			if (x_cor==x_i && y_cor==y_i) {
				x_o=x_i;
				y_o=y_i;
			} else {
				x_o=x_cor-round(pole_rad/2)+1;
				y_o=y_cor-round(pole_rad/2)+1;
			}
			makeOval(x_o, y_o, pole_rad, pole_rad);
//			//
			getStatistics(area[i], mean[i], min[i], max[i], std[i], histogram);
			TotFlu_o=mean[i]*area[i];
			print("Corrected pole i="+i+" at "+x_o+";"+y_o+" has "+TotFlu_o);
			if (TotFlu_i>=TotFlu_o) {
				TotFlu_Final=TotFlu_i;
				area[i]=ar;
				mean[i]=me;
				min[i]=mi;
				max[i]=ma;
				std[i]=st;
				Poles_Coordinates[5+r]=x_i;
				Poles_Coordinates[5+r+1]=y_i;
			} else {
				TotFlu_Final=TotFlu_o;
				Poles_Coordinates[5+r]=x_o;
				Poles_Coordinates[5+r+1]=y_o;
			}
			TotalFluPole[i]=TotFlu_Final;
			print("Conclusion: Pole i="+i+" at "+x_o+";"+y_o+" has "+TotalFluPole[i]);
		}
		if(TotalFluPole[0]<TotalFluPole[1]){
			Pole_order=true;
			print("Normal pole order, bright pole: "+1);
		} else {
			print("Inverted pole order, bright pole: "+0);
			Pole_order=false;
		}
		for(i=0; i<2; i++){
			if (Pole_order==true) {
				p=i;
				if(i==0){
				r=0;
				} else if (i==1){
					r=2;
				}
			} else {
				if (i==0){
					p=1;
					r=2;
				} else if (i==1){
					p=0;
					r=0;
				}
			}
			selectImage(IDiSCAT);
			roiManager("Show All with labels");
			roiManager("Select", LastROI-1);
			makeOval(Poles_Coordinates[5+r],Poles_Coordinates[5+r+1],pole_rad,pole_rad);
			waitForUser( "Pause","Count pili and flagella at the "+Pole[i]+" pole");
			Dialog.create("Pole at ("+Poles_Coordinates[5+r]+", "+Poles_Coordinates[5+r+1]+")");
				Dialog.addNumber("Number of pili at the pole", 0);
				Dialog.addNumber("Number of flagella at the pole", 0);
				if(i==1){
					Dialog.addCheckbox("add another cell?", false);
					Dialog.addCheckbox("End analysis now?", false);
				}
			Dialog.show();
			PiliCount[i]=Dialog.getNumber();
			FlagellaCount[i]=Dialog.getNumber();
			if(i==1) {
				AddCell=Dialog.getCheckbox();
				Global_Stop = Dialog.getCheckbox();
			}
			print("Pole order is "+Pole[i]+", p="+p+" and r="+r);
			setResult("X_Pole"+Pole[i], n, Poles_Coordinates[5+r]);
			setResult("Y_Pole"+Pole[i], n, Poles_Coordinates[5+r+1]);
			setResult("Pole_Radius"+Pole[i], n, pole_rad);
			setResult("AreaPole"+Pole[i], n, area[p]);
			setResult("MeanPole"+Pole[i], n, mean[p]);
			setResult("TotalFluorescencePole"+Pole[i], n, TotalFluPole[p]);
			setResult("MinPole"+Pole[i], n, min[p]);
			setResult("MaxPole"+Pole[i], n, max[p]);
			setResult("StdPole"+Pole[i], n, std[p]);
			setResult("Nb_Pili_Pole"+Pole[i], n, PiliCount[i]);
			setResult("Nb_Flagella_Pole"+Pole[i], n, FlagellaCount[i]);
		}
		cellFlu=TotalFlu-(TotalFluPole[0]+TotalFluPole[1]);
		ratio1=(TotalFluPole[0]+TotalFluPole[1])/cellFlu;
		ratio2=(area[0]+area[1])/(Cellarea-(area[0]+area[1]));
		PolarRatio=ratio1/ratio2;
		print(ratio1+"% / "+ratio2+"% = "+PolarRatio+"\n");
		setResult("PolarRatio", n, PolarRatio);	
		if (RetractCount) {

			poleDim_retraction_pili_lengths=newArray();
			poleDim_retraction_pili_slices=newArray();
			poleBright_retraction_pili_lengths=newArray();
			poleBright_retraction_pili_slices=newArray();
			for (i = 0; i < 2; i++) {
				print("Recording pili");
				if (Pole_order==true) {
						p=i;
						if(i==0){
						r=0;
						} else if (i==1){
							r=2;
						}
					} else {
						if (i==0){
							p=1;
							r=2;
						} else if (i==1){
							p=0;
							r=0;
						}
					}
				if ((PiliCount[i]>0)){
					Dialog.create("Pole at ("+Poles_Coordinates[5+r]+", "+Poles_Coordinates[5+r+1]+")");
						Dialog.addCheckbox("Do you want to record retraction events?", false);
					Dialog.show();
					rec_retraction=Dialog.getCheckbox();
				} else {
					rec_retraction=false;
				}
				if ((PiliCount[i]>0) & rec_retraction) {
	
					selectImage(IDiSCAT);
					roiManager("Show All with labels");
					roiManager("Select", LastROI-1);
					makeOval(Poles_Coordinates[5+r]-round(pole_rad/2),Poles_Coordinates[5+r+1]-round(pole_rad/2),pole_rad,pole_rad);
					still_retraction=true;
					while (still_retraction) {
						waitForUser( "Pause","Draw line on retracted pilus on "+Pole[i]+" pole");
						Roi.getCoordinates(xpoints, ypoints);
						pilus_length=sqrt(pow(xpoints[0]-xpoints[xpoints.length-1],2)+pow(ypoints[0]-ypoints[ypoints.length-1],2));
						Slice=getSliceNumber();
						print("Retraction Number: "+poleDim_retraction_pili_lengths.length+1+", Pilus length="+pilus_length+", Slice number="+Slice);
						if (i==0){
							poleDim_retraction_pili_lengths=Array.concat(poleDim_retraction_pili_lengths, pilus_length);
							poleDim_retraction_pili_slices=Array.concat(poleDim_retraction_pili_slices, Slice);
						} else {
							poleBright_retraction_pili_lengths=Array.concat(poleBright_retraction_pili_lengths, pilus_length);
							poleBright_retraction_pili_slices=Array.concat(poleBright_retraction_pili_slices, Slice);
						}
						waitForUser( "Pause","Check for other retractions...");
						Dialog.create("Pole at ("+Poles_Coordinates[5+r]+", "+Poles_Coordinates[5+r+1]+")");
							Dialog.addCheckbox("add another retraction?", true);
						Dialog.show();
						still_retraction=Dialog.getCheckbox();
					}
				}
			}
			Lengths=newArray(poleDim_retraction_pili_lengths.length, poleBright_retraction_pili_lengths.length);
			Array.getStatistics(Lengths, m_drop, max_pili_nb, me_drop, std_drop);
			print(max_pili_nb);
			for (k = 0; k < max_pili_nb; k++) {
				setResult("Label", n+k, Title);
				setResult("Cell_ID", n+k, CellNb);
				setResult("BiologicalReplicate", n+k, BioRep);
				setResult("CellArea", n+k, Cellarea);
				setResult("CellMean", n+k, Cellmean);
				setResult("CellTotalFluorescence", n+k, TotalFlu);
				setResult("CellMin", n+k, Cellmin);
				setResult("CellMax", n+k, Cellmax);
				setResult("CellStd", n+k, Cellstd);
				for(i=0; i<2; i++){
					if (Pole_order==true) {
						p=i;
						if(i==0){
						r=0;
						} else if (i==1){
							r=2;
						}
					} else {
						if (i==0){
							p=1;
							r=2;
						} else if (i==1){
							p=0;
							r=0;
						}
					}
					setResult("X_Pole"+Pole[i], n+k, Poles_Coordinates[5+r]);
					setResult("Y_Pole"+Pole[i], n+k, Poles_Coordinates[5+r+1]);
					setResult("AreaPole"+Pole[i], n+k, area[p]);
					setResult("MeanPole"+Pole[i], n+k, mean[p]);
					setResult("TotalFluorescencePole"+Pole[i], n+k, TotalFluPole[p]);
					setResult("MinPole"+Pole[i], n+k, min[p]);
					setResult("MaxPole"+Pole[i], n+k, max[p]);
					setResult("StdPole"+Pole[i], n+k, std[p]);
					setResult("Nb_Pili_Pole"+Pole[i], n+k, PiliCount[i]);
					setResult("Nb_Flagella_Pole"+Pole[i], n+k, FlagellaCount[i]);
				}
				if (k<poleDim_retraction_pili_lengths.length) {
					setResult("RetractedPilusLength_Dim", n+k, poleDim_retraction_pili_lengths[k]);
					setResult("RetractedPilusFrame_Dim", n+k, poleDim_retraction_pili_slices[k]);
				}
				if (k<poleBright_retraction_pili_lengths.length) {
					setResult("RetractedPilusLength_Bright", n+k, poleBright_retraction_pili_lengths[k]);
					setResult("RetractedPilusFrame_Bright", n+k, poleBright_retraction_pili_slices[k]);
				}
			}
		}
		
	}
	Booleans=newArray(2);
	Booleans[0]=AddCell;
	Booleans[1]=Global_Stop;
	return Booleans;
}

/*  registration(IDiSCAT, IDtirf, NewReg, JustFrame, FrameNb, Coordinates, dir) takes the iSCAT and tirf imaege
 *  IDs as input as well as the booleans: NewReg for a new registration, JustFrame for a specific tirf frame to
 *  select, the frame number, the two lines coordinates, the scaling factor and the directory of the Tirf Image
 *  to save the registered result image and returns its ID.
 * 
 */
function registration(IDiSCAT, IDtirf, NewReg, JustFrame, FrameNb, Coordinates, dir, scaling, Brightfield){
	selectImage(IDiSCAT);
	run("Gaussian Blur...", "sigma=2 stack");
	makeLine(Coordinates[0], Coordinates[1], Coordinates[2], Coordinates[3]);
	
	selectImage(IDtirf);
	makeLine(Coordinates[4], Coordinates[5], Coordinates[6], Coordinates[7]);
	
	if (NewReg){
		waitForUser( "Pause","Draw a line in iSCAT and Fluorescence images \ncorresponding to shared landmarks");
	}
	
	selectImage(IDiSCAT);
	getLine(iPointX1, iPointY1, iPointX2, iPointY2, lineWidth);
	getDimensions(widthSCAT, heightSCAT, channel, slice, frame);
	
	selectImage(IDtirf);
	getLine(fPointX1, fPointY1, fPointX2, fPointY2, lineWidth);
	
	run("Select All");
	getDimensions(width, height, channel, slice, frame);

	
	if(JustFrame){
		FrameRange=split(FrameNb, "-");
		if (lengthOf(FrameRange)==1) {
			setSlice(FrameRange[0]);
			run("Duplicate...", "title=CopyTirf use");
		} else {
			run("Z Project...", "start="+FrameRange[0]+" stop="+FrameRange[1]+" projection=[Average Intensity]");
		}
	} else run("Duplicate...", "title=CopyTirf duplicate");
	IDCopy=getImageID;
	run("Median...", "radius=2 stack");
	if(!Brightfield) run("Subtract Background...", "rolling=50 sliding stack");
	if(!JustFrame){
		run("Z Project...", "projection=[Average Intensity]");
	} else run("Duplicate...", "title=CopyTirf use");
	IDAverage=getImageID;
	
	
	angle=atan2((fPointX1-fPointX2), (fPointY1-fPointY2))-atan2((iPointX1-iPointX2), (iPointY1-iPointY2));
	angleDeg=angle*180/PI;
	NewWidth=round(width*scaling);
	NewHeight=round(height*scaling);
	run("Scale...", "x="+scaling+" y="+scaling+" width="+NewWidth+" height="+NewWidth+" interpolation=Bilinear average create title=["+"Registered_AVG_"+Title+"]");
	IDReg=getImageID;
	TitleTIRF=getTitle;
	run("Rotate... ", "angle="+angleDeg+" grid=1 interpolation=Bilinear");
	makeRectangle(266-widthSCAT/2,266-heightSCAT/2,widthSCAT,heightSCAT);
	run("Crop");
	saveAs("tif", dir+TitleTIRF);
	selectImage(IDAverage);
	close();
	selectImage(IDCopy);
	close();
	Coordinates[0]=iPointX1;
	Coordinates[1]=iPointY1;
	Coordinates[2]=iPointX2;
	Coordinates[3]=iPointY2;
	Coordinates[4]=fPointX1;
	Coordinates[5]=fPointY1;
	Coordinates[6]=fPointX2;
	Coordinates[7]=fPointY2;
	
	return IDReg;
}

/*  getCurrentDataPoints(file_path) get coordinates for TIRF and iSCAT image registration and event number 
 *  from the CurrentDataPoints.txt file created during the first analysis of the folder.
 * 
 */
function getCurrentDataPoints(file_path){
	if (File.exists(file_path)){
		raw_data=File.openAsString(file_path);
		split_raw_data=split(raw_data, ",");
		l=lengthOf(split_raw_data);
		Coordinates=newArray(l);
			for(i=0; i<l; i++){
				Coordinates[i]=parseInt(split_raw_data[i]);
			}
	}
	return Coordinates;
}

/*  readResult(NameOfTable, Column, Row) return the value on the column and row of the Result
 *  table of NameOfTable. If NameOfTable exists it reads the value, if it doesn't exists it 
 *  prints a warning message If the column doesn't exist the function retruns "null".
 * 
 */
function readResult(NameOfTable, Column, Row){
	if(isOpen(NameOfTable)){
		IJ.renameResults(NameOfTable,"Results");
		Value=getResult(Column, Row);
		if(isNaN(Value)) Value=getResultString(Column, Row);
		IJ.renameResults("Results",NameOfTable);
		return Value;
	}
	else {
		print(NameOfTable+" does not exist");
		return NaN;
	}
	
}

/*  writeResult(NameOfTable, Column, Row, Value) write the value on the column and row of the Result
 *  table of NameOfTable. If NameOfTable exists it calls it and make the desired change, if it
 *  doesn't exists it ceates it.
 * 
 */
function writeResult(NameOfTable, Column, Row, Value){
	if(isOpen(NameOfTable)){
		IJ.renameResults(NameOfTable,"Results");
		setResult(Column, Row, Value);
		IJ.renameResults("Results",NameOfTable);
	}
	else {
		if(isOpen("Results")) IJ.renameResults("Results","Tmp");
		setResult(Column, Row, Value);
		IJ.renameResults("Results",NameOfTable);
		if(isOpen("Tmp")) IJ.renameResults("Tmp","Results");
	}
}

/*  getNResultsFromTabel(NameOfTable) write the value on the column and row of the Result
 *  table of NameOfTable. If NameOfTable exists it calls it and make the desired change, if it
 *  doesn't exists it ceates it.
 * 
 */
 function getNResultsFromTabel(NameOfTable){
 	if(isOpen(NameOfTable)){
		IJ.renameResults(NameOfTable,"Results");
		n=nResults;
		IJ.renameResults("Results",NameOfTable);
 	} else n=0;
 	return n;
 }

/*  correctSelection(x_selection, y_selection, x_offset, y_offset) Correct the selection coordinates
 *  by translating the input coordinates by the offset in x and y.
 * 
 */
 function correctSelection(x_selection, x_offset){
 	x=newArray(x_selection.length);
 	for(i=0; i<x_selection.length; i++){
 		x[i]=x_selection[i]+x_offset;
 	}
 	return x;
 }

/* getPolesCoordinates(array_x, array_y, image_size) takes X and Y coordinates and the image size as input
 * and returns the coordinates of the two poles of a rodshaped bacterium, its center of mass, the width of
 * the bacterium and the index of the selection where the poles are defined.
 */
function getPolesCoordinates(array_x, array_y, image_size){
	//Getting the min and max value of the X and Y coordinates in order to find the initial center of mass.
	Array.getStatistics(array_x, minX, maxX, mean, stdDev);
	Array.getStatistics(array_y, minY, maxY, mean, stdDev);
	xCM=minX+(maxX-minX)/2;
	yCM=minY+(maxY-minY)/2;

	//Initializing output Array
	out=newArray(5);

	//Initializing working variables
	posLmax=-image_size;
	negLmax=-image_size;
	posLmin=image_size;
	negLmin=image_size;
	L=newArray(array_x.length);
	L0=newArray(array_x.length);
	L1=newArray(array_x.length);
	indexPole0=0;
	indexPole1=0;
	indexCenter0=0;
	indexCenter1=0;

	//Computing the lengths from CM to points of the selection in order to compute real CM
	for (i=0; i<array_x.length; i++){
		x0=array_x[i]-xCM;
		y0=array_y[i]-yCM;
		l=sqrt(x0*x0 + y0*y0);
		L[i]=l;
	}
	minima=Array.findMinima(L, 1);	//Returns the indexes of the minima of the lengths in increasing length order
	xCM=(array_x[minima[0]]+array_x[minima[1]])/2;
	yCM=(array_y[minima[0]]+array_y[minima[1]])/2;

	//Computing new Lengths from new CM.
	for (i=0; i<array_x.length; i++){
		x0=array_x[i]-xCM;
		y0=array_y[i]-yCM;
		l=sqrt(x0*x0 + y0*y0);
		L[i]=l;
	}

	//Getting index of Length maxima. These correspond to the two poles.
	//Initialization of variables
	n_maxima=Array.findMaxima(L, 1);
	raw_maxima=Array.sort(n_maxima); //From smallest to largest Index value
	maxLengths=newArray(raw_maxima.length);
	maxima=newArray(raw_maxima.length-1);

	//If There are more than 2 maxima, Get the corresponding lengths 
	if(raw_maxima.length>2){	
		for (i=0; i<raw_maxima.length; i++){
			maxLengths[i]=L[raw_maxima[i]];
		}
		//Get the index of the smallest length within the maxima
		Array.getStatistics(maxLengths, smallestL, m, me, std);
		ind_smallest_L=NaN;
		for (i=0; i<raw_maxima.length; i++){
			if(maxLengths[i]==smallestL){
				ind_smallest_L=i;
			}
		}
		//Checking the location of the smallest maxima (if more than 2 are found) in order to discard it
		//and take the bigger of the remaining ones
		if(ind_smallest_L==1){
			if(maxLengths[ind_smallest_L-1]<maxLengths[ind_smallest_L+1]){
				ind_smallest_L=ind_smallest_L+1;
			} else if (maxLengths[ind_smallest_L-1]>maxLengths[ind_smallest_L+1]){
				ind_smallest_L=ind_smallest_L-1;
			} else {
				ind_smallest_L=ind_smallest_L-1;
			}
		}
		
		n=0;
		for(i=0; i<raw_maxima.length;i++){
			if(i!=ind_smallest_L){
				maxima[n]=raw_maxima[i];
				n++;
			}
		}
	} else{
		maxima=raw_maxima;
	}

	//Generating coordinates of two spots in between the poles and the CM to extract the mean width of the bacterium
	x_0=(array_x[maxima[0]]+xCM)/2;
	y_0=(array_y[maxima[0]]+yCM)/2;
	x_1=(array_x[maxima[1]]+xCM)/2;
	y_1=(array_y[maxima[1]]+yCM)/2;

	//First pole
	for (i=0; i<array_x.length; i++){
		x0=array_x[i]-x_0;
		y0=array_y[i]-y_0;
		l=sqrt(x0*x0 + y0*y0);
		L0[i]=l;
	}
	minima0=Array.findMinima(L0, 1);
	x=(array_x[minima0[0]]-array_x[minima0[1]]);
	y=(array_y[minima0[0]]-array_y[minima0[1]]);
	r0=sqrt(x*x+y*y);

	//Second pole
	for (i=0; i<array_x.length; i++){
		x0=array_x[i]-x_1;
		y0=array_y[i]-y_1;
		l=sqrt(x0*x0 + y0*y0);
		L1[i]=l;
	}
	minima1=Array.findMinima(L1, 1);
	x=(array_x[minima1[0]]-array_x[minima1[1]]);
	y=(array_y[minima1[0]]-array_y[minima1[1]]);
	r1=sqrt(x*x+y*y);

	//Mean width
	r=(r0+r1)/2;
	//print("("+r0+"+"+r1+")/2="+r);
	
	out[0]=xCM;
	out[1]=yCM;
	out[2]=maxima[0];
	out[3]=maxima[1];
	out[4]=r;

	//Adding coordinates of poles
	out2=correctPolesCoordinates(out, array_x, array_y);
	final_out=Array.concat(out,out2);
	return final_out;
}

/* correctPolesCoordinates(Coordinates, array_x, array_y) takes an Array containing CM coordinates,
 * Index of the two poles and mean cell width and returns the corrected coordinates of the poles
 */
function correctPolesCoordinates(Coordinates, array_x, array_y){
	out=newArray(4);
	x0=array_x[Coordinates[2]];
	y0=array_y[Coordinates[2]];
	x1=array_x[Coordinates[3]];
	y1=array_y[Coordinates[3]];
	xCM=Coordinates[0];
	yCM=Coordinates[1];
	r=Coordinates[4]/2;
	
	norm0=sqrt((xCM-x0)*(xCM-x0)+(yCM-y0)*(yCM-y0));
	norm1=sqrt((xCM-x1)*(xCM-x1)+(yCM-y1)*(yCM-y1));
	
	corx0=r*(xCM-x0)/norm0;
	cory0=r*(yCM-y0)/norm0;
	corx1=r*(xCM-x1)/norm1;
	cory1=r*(yCM-y1)/norm1;
	
	out[0]=x0+corx0;
	out[1]=y0+cory0;
	out[2]=x1+corx1;
	out[3]=y1+cory1;
	
	return out;
}

/* isImage(filename) is a function that checks if the input file is an image of type "lsm", "lei",
 * "lif", "tif", "ics", "bmp", "png", "TIF", "tiff", "czi", "zvi", "nd2"
 */
function isImage(filename){
	// list of accepted file format
	extensions= newArray("ids", "lsm", "lei", "lif", "ics", "tif", "bmp", "png", "TIF", "tiff", "czi", "zvi", "nd2"); 
	for (i=0; i<extensions.length; i++) { // loop over each index of the array extensions
		if(endsWith(filename, "."+extensions[i])) { // check if the imageName given endswith the ith element 
			return true; // if its true, it's an image, so we don't need to continue so return
		} 
	} 
	return false; // when every element have been check, it's not an image.
}

/* openWorkingImg(SaveDir, EventNB, Source) is a function that opens iSCAT or TIRF images.
 *  SaveDir is the root folder, EventNB is the event number and source is string being
 *  either "iSCAT" or "TIRF"
 */
function openWorkingImg(SaveDir, EventNB, Source){
	if(Source == "iSCAT"){
		extension="";
		source_check=Source;
	} else if (Source == "TIRF") {
		extension="_tirf";
		source_check="tirf";
	}
	path=SaveDir+File.separator+"cam1"+File.separator+"event"+EventNB+extension;
	list= getFileList(path);
	Found_img = false;
	n=0;
	while (Found_img  == false){
		if (n<lengthOf(list)){
			Ind_Check=indexOf(list[n], source_check);
			Ind_Reg=indexOf(list[n], "Registered");
			if((Ind_Check > 0)&&(Ind_Reg < 0)){
				if (isImage(list[n])){
					open(path+File.separator+list[n]);
					Found_img = true;
				}
			}
			n=n+1;
		} else {
			waitForUser( "Pause","Couldn't find "+Source+" image of event"+EventNB+".\nPease open the image manually");
			Found_img = true;
		}	
	}
}

/*  pixelizeSelection(x_array, y_array) generate a new array "out" containing all the pixel values of
 *  a selection. The array Out contains X values first and y values last. You need to split the array
 *  in two to extract values.
 */
function pixelizeSelection(xCell, yCell, boundary){
	if(boundary=="closed"){
		x_array=Array.concat(xCell, xCell[0]);
		y_array=Array.concat(yCell, yCell[0]);
	} else {
		x_array=xCell;
		y_array=yCell;
	}
	limit=lengthOf(x_array);
	X=newArray();
	Y=newArray();
	for(i=0; i<limit-1; i++){
		X=Array.concat(X, x_array[i]);
		Y=Array.concat(Y, y_array[i]);
		dx=x_array[i+1]-x_array[i];
		dy=y_array[i+1]-y_array[i];
		if(dx*dy == 0){
			if(dx == 0){
				if(dy>=0){
					sign=1;
				}else if (dy<0){
					sign=-1;
				}
				for(y=1; y<abs(dy); y++){
					Y=Array.concat(Y, y_array[i]+y*sign);
					X=Array.concat(X, x_array[i]);
				}
			} else if(dy == 0){
				if(dx>=0){
					sign=1;
				}else if (dx<0){
					sign=-1;
				}
				for(x=1; x<abs(dx); x++){
					X=Array.concat(X, x_array[i]+x*sign);
					Y=Array.concat(Y, y_array[i]);
				}
			}
		}
	}
	X=Array.concat(X, x_array[lengthOf(x_array)-1]);
	Y=Array.concat(Y, y_array[lengthOf(y_array)-1]);
	out=newArray();
	out=Array.concat(out, X);
	out=Array.concat(out, Y);
	return out;
}