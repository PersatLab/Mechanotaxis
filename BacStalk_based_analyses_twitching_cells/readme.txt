Processing pipeline for various analyses of twitching cells, based on segmentation and tracking with BacStalk

1. Prepare image sequences for BacStalk analysis (in "imageJ_macros" folder)
	a) for phase contrast image sequences (obtained with 40x objective)
		1. divide_image+correct_drift.ijm
		2. split_image.ijm
	b) for phase contrast and fluorescence image sequences
		1. split_image.ijm

2. Run basic analysis with a custom MATLAB code that uses a slightly modified version of Bacstalk (Hartmann, R., van Teeseling, M. C. F., Thanbichler, M. & Drescher, K. BacStalk: a comprehensive and interactive image analysis software tool for bacterial cell biology. Molecular Microbiology (2020). doi:10.1111/mmi.14501)
	1. download folder "basic_analysis_BacStalk"
	2. download original BacStalk distibution, version 1.8 (https://drescherlab.org/data/bacstalk/docs/) and copy into basic_analysis_BacStalk folder
	2. copy files from folder "basic_analysis_BacStalk\BacStalk_modified\" into downloaded BacStalk folder (replacing files)
	3. rename BacStalk folder to "BacStalk_modified" (delete other BacStalk_modified folder)
	a) for phase contrast image sequences
		4. run Basic_analysis_phase_contrast_only.m
	b) for phase contrast and fluorescence image sequences
		4. run Basic_analysis_fluorescence.m

3. To check segmentation and tracking: individual images printed by MATLAB can be combined using video_maker.ijm (in "imageJ_macros" folder)

4. Run desired analyses scripts (in "analysis_scripts" folder)
	1. save_analysis.m
		- uses the corresponding get_analysis.m function
		- saves data in a analysis_data.mat file
	2. graph_analysis.m
		- uses data saved with save_analysis.m
