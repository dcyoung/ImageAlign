function [ H ] = estimate_homography( img1Feat, img2Feat )
%ESTIMATE_HOMOGRAPHY Summary of this function goes here
%   Detailed explanation goes here

    parameters.numIterations = 150;      %the number of iterations to run
    parameters.subsetSize = 4;          %number of matches to use each iteration
    parameters.inlierDistThreshold = 10;   %the minimum distance for an inlier
    parameters.minInlierRatio = .3;     %minimum inlier ratio required to store a fitted model

    [H, inlierIndices] = ransac_H(parameters, img1Feat, img2Feat, @fit_homography, @calc_residuals);

end