function [ r1, c1, r2, c2 ] = detect_features( grayImg1, grayImg2 )
%DETECT_FEATURES Summary of this function goes here
%   Detailed explanation goes here

    %use harris corner detector
    points1 = detectHarrisFeatures(grayImg1);
    points2 = detectHarrisFeatures(grayImg2);

    %extract the pixel locations from the features
    [r1, c1] = deal( zeros(length(points1),1) );
    [r2, c2] = deal( zeros(length(points2),1) );
    for i = 1: length(points1)
        cornerLoc = points1(i).Location;
        r1(i) = round(cornerLoc(2));
        c1(i) = round(cornerLoc(1));
    end
    for i = 1: length(points2)
        cornerLoc = points2(i).Location;
        r2(i) = round(cornerLoc(2));
        c2(i) = round(cornerLoc(1));
    end
end

