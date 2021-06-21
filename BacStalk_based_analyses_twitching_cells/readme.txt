Processing pipeline for various analyses of twitching cells, based on segmentation and tracking with BacStalk

1. Prepare image sequences for BacStalk analysis (using imageJ macros)
	a) for phase contrast image sequences (obtained with 40x objective)
		1. divide_image+correct_drift.ijm
		2. split_image.ijm
	b) for phase contrast and fluorescence image sequences
		1. split_image.ijm

2. Run basic analysis with a custom MATLAB code that uses a slightly modified version of Bacstalk (R. Hartmann, M. C. F. van Teeseling, M. Thanbichler, K. Drescher, Molecular Microbiology 114, 2020)
	a) for phase contrast image sequences
		1. Basic_analysis_phase_contrast_only.m
	b) for phase contrast and fluorescence image sequences
		1. Basic_analysis_fluorescence.m

3. To check segmentation and tracking (and for fluorescence the fit of the determined polar regions) individual images printed by MATLAB can be combined using: 
	1. video_maker.ijm
	2. ImageJ to open the movies

4. Run desired analyses scripts
	1. save_analysis.m
		- uses the corresponding get_analysis.m function
		- saves data in a analysis_data.mat file
	2. graph_analysis.m
		- uses data saved with save_analysis.m