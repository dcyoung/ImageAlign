%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab Equivalent (GOLD STANDARD)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Clean up the console and workspace
clear all;
clc;

% Load both images
img1Filename = 'uttower_left.JPG';
img2Filename = 'uttower_right.JPG';
colorImg1 = imread(img1Filename);
colorImg2 = imread(img2Filename);
% Convert to double and to grayscale
colorImg1 = im2double(colorImg1);
colorImg2 = im2double(colorImg2);
I1 = rgb2gray(colorImg1);
I2 = rgb2gray(colorImg2);

%detect features
points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);
%describe features
[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);
%match features
indexPairs = matchFeatures(features1,features2);

matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);
%display matches
figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2, 'montage');