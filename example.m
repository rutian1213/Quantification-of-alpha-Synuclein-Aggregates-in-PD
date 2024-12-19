clc;clear;addpath('lib');

% The LAB value for a brown colour
Lmean_br = 50;
amean_br = 15.4;
bmean_br = 9.3;
tolerance_brown = 15; % The euclidean distance to the specific LAB value
brown_param = [Lmean_br,amean_br,bmean_br,tolerance_brown];

%%
img = imread('example.tif');
BW_asyn = colourFilterLAB(img,brown_param,3,0.3); % find the binary mask for the speficic colour

BW_asyn = imclose(BW_asyn,strel('disk',1)); % remove gaps within a shape
BW_asyn = bwareaopen(BW_asyn,9); % remove diffraction-limited objects
BW_asyn = imfill(BW_asyn,'holes'); % fill the detected objects
BW_asyn = imclearborder(BW_asyn); % remove objects touching the boundary

% reject very small and very large object
t_asyn  = regionprops('table',BW_asyn,'MinorAxisLength','MajorAxisLength');
minorA  = t_asyn.MinorAxisLength; majorA = t_asyn.MajorAxisLength;
BW_asyn = fillRegions(BW_asyn,find(minorA<3 | majorA>300));

% result table
t_asyn  = regionprops('table',BW_asyn,'Area','Centroid','MajorAxisLength','MinorAxisLength');
pseduo_circ = 2*t_asyn.MinorAxisLength./(t_asyn.MinorAxisLength + t_asyn.MajorAxisLength); % pseduo circularity = 2*majorLength / (minorLength + majorLength)

% overlay the binary mask with the original image with the binary mask
f1 = figure;
imshow(img);
f2 = figure;
imshow(img);
plotBinaryMask(f2,BW_asyn,[0.4660 0.6740 0.1880]);
