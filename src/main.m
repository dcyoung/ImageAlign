%Clean up the console and workspace
clear all;
clc;

%%%%%%%%%%%%%%%%%%
% Load both images
%%%%%%%%%%%%%%%%%%
img1Filename = 'uttower_left.JPG';
img2Filename = 'uttower_right.JPG';
colorImg1 = imread(img1Filename);
colorImg2 = imread(img2Filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Convert to double and to grayscale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
colorImg1 = im2double(colorImg1);
colorImg2 = im2double(colorImg2);
[heightImg1, widthImg1, ~] = size(colorImg1);
[heightImg2, widthImg2, ~] = size(colorImg2);

grayImg1 = rgb2gray(colorImg1);
grayImg2 = rgb2gray(colorImg2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Detect feature points in both images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[r1, c1, r2, c2] = detect_features(grayImg1, grayImg2);

%display an overlay of the features ontop of the image
figure; imshow([colorImg1 colorImg2]); hold on; title('Overlay detected features (corners)');
hold on; plot(c1,r1,'ys'); plot(c2 + widthImg1, r2, 'ys'); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract local neighborhoods around every keypoint in both images
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Specify the size of the neighboring region to be described
neighborhoodRadius = 20; 

% Form descriptors simply by "flattening" the pixel values in each 
% neighborhood to one-dimensional vectors
featDescriptions_1 = describe_features(grayImg1, neighborhoodRadius, r1, c1);
featDescriptions_2 = describe_features(grayImg2, neighborhoodRadius, r2, c2);


%%%%%%%%%%%%%%%%
% Match Features
%%%%%%%%%%%%%%%%

numMatches = 200;
[img1_matchedFeature_idx, img2_matchedFeature_idx] = match_features(numMatches, featDescriptions_1, featDescriptions_2);

match_r1 = r1(img1_matchedFeature_idx);
match_c1 = c1(img1_matchedFeature_idx);
match_r2 = r2(img2_matchedFeature_idx);
match_c2 = c2(img2_matchedFeature_idx);

% Display an overlay of these best matched features on top of the images
figure; imshow([colorImg1 colorImg2]); hold on; title('Overlay top matched features');
hold on; plot(match_c1, match_r1,'ys'); plot(match_c2 + widthImg1, match_r2, 'ys'); 

% Display lines connecting the matched features
plot_r = [match_r1, match_r2];
plot_c = [match_c1, match_c2 + widthImg1];
figure; imshow([colorImg1 colorImg2]); hold on; title('Mapping of top matched features');
hold on; 
plot(match_c1, match_r1,'ys');           %mark features from the 1st img
plot(match_c2 + widthImg1, match_r2, 'ys'); %mark features from the 2nd img
for i = 1:numMatches             %draw lines connecting matched features
    plot(plot_c(i,:), plot_r(i,:));
end


%%%%%%%%%%%%%%%%%%%%%
% Estimate Homography
%%%%%%%%%%%%%%%%%%%%%
%create homogenous versions of the the matched feature points for each img
img1MatchFeatPts = [match_c1, match_r1, ones(numMatches,1)];
img2MatchFeatPts = [match_c2, match_r2, ones(numMatches,1)];
[H, inlierIndices] = estimate_homography(img1MatchFeatPts,img2MatchFeatPts);
%display(H);

match_c1 = match_c1(inlierIndices);
match_c2 = match_c2(inlierIndices);
match_r1 = match_r1(inlierIndices);
match_r2 = match_r2(inlierIndices);

% Display an overlay of the inlier matches
figure; imshow([colorImg1 colorImg2]); hold on; title('Inlier Matches');
hold on; plot(match_c1, match_r1,'ys'); plot(match_c2 + widthImg1, match_r2, 'ys'); 




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stitch/Blend the warped img1 onto img2 to create a composite
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform/Warp the first image using the found homography matrix
homographyTransform = maketform('projective', H);
img1Transformed = imtransform(colorImg1, homographyTransform);
figure, imshow(img1Transformed);
title('Warped image');

% Stitch the images together with the correct overlap
stitchedCompositeImg = stitch(colorImg1, colorImg2, H);
figure, imshow(stitchedCompositeImg);
title('Alignment by homography');

