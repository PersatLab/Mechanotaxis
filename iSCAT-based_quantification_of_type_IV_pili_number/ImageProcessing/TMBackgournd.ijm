// @File(label="Movie to process", style="file") img_dir
// @String(label="iSCAT filtering protocol", description="Chose between: Nothing, Normal, Median, Average or Differential", value="Normal") Process
// @Integer(label="Half window", value=100, description="for Median or Average protocols") half
// @Integer(label="Undersampling factor", value=20, description="for Median or Average protocols") usf
// @Boolean(label="Bandpass Filtering?", value=true) doBPfilter
// @Integer(label="Filter large structures", value=13) FL
// @Integer(label="Filter Small structures", value=1) FS
// @Integer(label="Tolerance of direction", value=10) Tol
// @Boolean(label="Save when job is done?", value=false) SaveMe
// @Boolean(label="Gaussian blurr?", value=false) Blurr
// @Double(label="Sigma", value=2) Sigma

//Strart timer
TimeA=getTime;

//Open and extract image information
open(img_dir);
Title=getTitle;
id1=getImageID();
BitDepth=bitDepth();
Path=getDirectory("image");


if (BitDepth!=32) run("32-bit"); //Increase image bit depth to allow math manipulations on pixel values

//There are 5 different processing modes for iSCAT images:

/* Median: Run temporal moving median java plugin which takes a half time-window size
 * and an undersampling factor as inputs.
 */
if (indexOf(Process, "Median")>=0) { 
	run("Temporal Moving Median", "half="+half+" undersampling="+usf);
} 
/* Average: Run temporal moving average java plugin which takes a half time-window size
 * and an undersampling factor as inputs.
 */
else if (indexOf(Process, "Average")>=0) {
	run("Temporal Moving Average", "half="+half+" undersampling="+usf);
}
/* Normal: usual image processing used: divide each frame by the median projection of the all movie.
 * and remove 1.
 */
else if (indexOf(Process, "Normal")>=0) {
	run("Z Project...", "projection=Median");
	id2=getImageID();
	imageCalculator("Divide create 32-bit stack", id1,id2);
	id3=getImageID();
	selectImage(id3);
	rename("Processed_"+Title);
	run("Subtract...", "value=1 stack"); //Subtracts the value
	selectImage(id2);
	close();
	selectImage(id3);
}
/* Differential: subtract frame n-1 to frame n.
 */
else if (indexOf(Process, "Differential")>=0) {
	getDimensions(a,b,c,Slices,f);
	run("Duplicate...", "title="+Title+"_1 duplicate");
	IDcopy1=getImageID();
	run("Duplicate...", "title="+Title+"_2 duplicate");
	IDcopy2=getImageID();
	setSlice(Slices);
	run("Delete Slice");
	selectImage(IDcopy1);
	setSlice(1);
	run("Delete Slice");
	imageCalculator("Subtract create 32-bit stack", IDcopy1,IDcopy2);
	id3=getImageID();
	rename("Differential_"+Title);
	selectImage(IDcopy1);
	close();
	selectImage(IDcopy2);
	close();
	selectImage(id3);
} else if (indexOf(Process, "Nothing")>=0) {}

//Get processed image information
ID2=getImageID();
Title2=getTitle();
getDimensions(a,b,c,f, Slices);

//Set measurements parameters
run("Set Measurements...", "area mean standard min median stack display redirect=None decimal=3");

//Run a band-pass fft filtering removing small(FS) and big(FL) features of the iSCAT images
if(doBPfilter){
	run("Duplicate...", "title=FL"+FL+"_FS"+FS+"_"+Title2+" duplicate");
	Duplicata=getTitle;
	selectWindow(Duplicata);
	run("Bandpass Filter...", "filter_large="+FL+" filter_small="+FS+" suppress=None tolerance="+Tol+" autoscale saturate process");
}

//Normalize by frame background pixel values
for (i=1;i<f+1;i++){
		setSlice(i);		
		getStatistics(area, mean);
		run("Subtract...", "value="+mean);
	}

//Adjusting contrast of images
setSlice(1);
getStatistics(area, mean, min, max, std, histogram);
diff_x_val=linspace(min, max, (max-min)/(histogram.length-1));
diff_hist=diff(histogram);
Array.getStatistics(diff_hist, thresh_min, thresh_max, mean, stdDev);
factor=0.1;
min_set=findHigherTreshold(diff_hist, thresh_max*factor);
max_set=findLowerTreshold(diff_hist, thresh_min*factor);
setMinAndMax(diff_x_val[min_set[0]], diff_x_val[max_set[max_set.length-1]]);

//Blurring the image help reduce the masking from the cell body "halo"
if (Blurr) run("Gaussian Blur...", "sigma="+Sigma+" stack");

//Option to save your processed image
if (SaveMe) saveAs("Tiff", Path+"\\"+Duplicata);

if (indexOf(Process, "Nothing")<0) {
	selectImage(ID2);
	close();
}

TimeB=getTime;
ElapsedTime=(TimeB-TimeA)/1000;
print("Elapsed Time: "+ElapsedTime+" s");
beep();

//-------------------------------------------------Functions-------------------------------------------------

/* diff(MyArray) takes a numerical array and returns its derivative
 */
function diff(MyArray){
	diff_array=newArray(MyArray.length-1);
	for(i=0;i<MyArray.length-1;i++){
		diff_array[i]=MyArray[i+1]-MyArray[i];
	}
	return diff_array;
}

/* linspace(start, end, spacing) takes a start and end value and generate an array with equal spacing
 * defined by the variable "spacing".
 */
function linspace(start, end, spacing){
	length=round((end-start)/spacing);
	x_val=newArray(length);
	for(i=0; i<length; i++){
		x_val[i]=start+i*spacing; 
	}
	return x_val;
}

/* findHigherTreshold(myArray, Threshold) takes an array and find the index of the array values that are higher
 * than the Threshold defined by the user.
 */
function findHigherTreshold(myArray, Threshold){
	Indexes=newArray;
	for (i=0; i<myArray.length; i++){
		if(myArray[i]>Threshold){
			Indexes=Array.concat(Indexes,i);
		}
	}
	return Indexes;
}

/* findLowerTreshold(myArray, Threshold) takes an array and find the index of the array values that are lower
 * than the Threshold defined by the user.
 */
function findLowerTreshold(myArray, Threshold){
	Indexes=newArray;
	for (i=0; i<myArray.length; i++){
		if(myArray[i]<Threshold){
			Indexes=Array.concat(Indexes,i);
		}
	}
	return Indexes;
}