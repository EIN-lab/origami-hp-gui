% Script to compile OrigamiHP.m to Windows executable

% Set output directory
outPath = 'C:\Code\origami-hp-gui\bin';

% Compile m-file
mcc('-e', '-d', outPath, 'OrigamiHP.m')
