Data was obtained by manual counting pili on iSCAT images processed with fiji.

To process and isolate iSCAT signal from the raw movies, dowload the iSCATImageProcessing folder and follow these steps:

	1. Copy and paste the two java plugins (Temporal_Moving_Average.class and Temporal_Moving_Median.class) into the "plugins" folder of your fiji installation
	2. Open the macro "Process_iSCAT_movies.ijm" into your fiji installation and find the right iSCAT processing protocol included in the macro that yield the best
	   images.
	3. Pili counts were recorded into an Excel file (found in the "data" folder)
	
	NB: Raw iSCAT data is not found in this respository but can be asked to the corresponding author
	
To analyze and plot our results of Figure S1D, please unzip "Chp-cAMP_experiments_summary.zip" and place "Chp-cAMP_experiments_summary.xlsx" in the data folder. Then use the following Matlab script:

	1. ChpMutantPiliCount.m
