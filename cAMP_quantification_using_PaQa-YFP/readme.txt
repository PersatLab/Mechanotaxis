In order to extract information on PaQa levels from your images please follow this pipline:

	1. Fliter and process your images with the fiji macro located in Image_Processing/nd2Batch3ChannelPrep.ijm

	2. Upload your processed images in Bacstalk with and select the right parameters to get as many single cells
	detected as possible. And save a CSV file with the fluorescence values for the RFP and YFP channel.

	3. Combine all CSV files in one and add information about Strain name, growth condition, biological replicate,
	etc. as seen in Image_Analysis/Data_PaQa_levels_Analysis/SummaryPaQaLevels.csv

To plot our data as in Figure S1C please run the following python code from jupyter notebook:

	1. Image_Analysis/PaQa_level_analysis.ipynb