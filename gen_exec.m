% Script to compile OrigamiHP.m to Windows executable

% Set output directory
outPath = 'bin';

% Compile m-file
mcc('-e', '-d', outPath, 'OrigamiHP.m')
