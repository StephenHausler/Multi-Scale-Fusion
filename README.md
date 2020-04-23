# Multi-Scale-Fusion
WIP - further code tweaks, to make the code more portable and easier to read, will occur in future weeks.

Copyright: Stephen Hausler
S. Hausler, Z. Chen, M. Hasselmo, M. Milford, "Bio-Inspired Multi-Scale Fusion", published in Biological Cybernetics, 2020.

Code requires MATLAB. Currently configured for Windows, but just have to adjust the filepaths to use on Ubuntu.

Start by running initialize.m

Two main code folders: Aerial_Code and Ground_Code. Aerial_Code is for Nearmaps aerial localization, while Ground_Code is for a forward-facing dataset like Nordland.

Run the file runAll.m to generate results on the pre-computed features. Note that with the currently provided features, only Scales 1 and 9 are available for testing. However, you are welcome to create your own features.

Quite a few file paths need to be edited to use on your local machine. Will be looking into making this code more portable in the upcoming weeks.

Please contact me if you want the original Nearmaps dataset, as the total filesize is 140GB. 
