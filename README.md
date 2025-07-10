## Scripts for low-kV paper

Explanation of scope of repo here when we have all the scripts

## Reference 
These scripts are associated with the following publicatons, please include a citation in your own works if you found these scripts useful: 
pre-print DOI here

## Usage Instructions

# Processing through-focus series

Processing through focus series - 

Based on paper by Kimoto et al (DOI goes here)
(they did not provide scripts however, so have attempted to write scripts to do same process)

Through Focus Series - on acquisition binning with OneView adds artefacts (would Rio be same?)
Data set can be overly huge (especially with K3) so consider binning before processing (Volume/ReBin X and Y) to get 1024x1024 or smaller volume - this may not be a matter of time, the memory allocation required may simply be too large. Note, may need to change bit density before binning to avoid saturation

Current versions of scripts:

DMScript language:
Stack_2_FFTstack.s	(Jan 2024)
Stack_2_FFTstack_Threaded.s (Jan 2024)
RadialProfilefromFFTSeries0.3.s	(Jan 2024)

Python
3DFFTStack.py (Feb 2024)
This python script can be used to make the 2dFFT stack (line 97) or the 3DFFT stack (line 98) - comment out the one not wanted. 

Please see the associated preprint for greater context: pre-print DOI here

Usage instructions go here

## List of Scripts 
- script 1
- script 2
- etc.
