Data was obtained by manual counting pili on iSCAT images processed with fiji.

To process and isolate iSCAT signal from the raw movies, dowload the iSCATImageProcessing folder and follow these steps:

	1. Copy and paste the two java plugins (Temporal_Moving_Average.class and Temporal_Moving_Median.class) into the "plugins" folder of your fiji installation
	2. Open the macro "Process_iSCAT_movies.ijm" into your fiji installation and find the right iSCAT processing protocol included in the macro that yield the best
	   images.
	3. Pili counts were recorded into an Excel file (found in the "data" folder)
	
	NB: Raw iSCAT data is not found in this respository.
	
To assist in pili counting and pole fluorescence quantification open the followin imageJ macro:

	1. DataQuantification/Fluorescence_and_pili_counts.ijm

To analyze and plot our results of Figure 3C and 6F, please use the following jupyter notebook:

	1. ImageAnalysis/pili_vs_motor_localization.ipynb