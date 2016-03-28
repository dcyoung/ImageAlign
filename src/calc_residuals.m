function residuals = calc_residuals(H, pts1_homogenous, pts2_homogenous)
%CALC_RESIDUALS Summary of this function goes here
%   Detailed explanation goes here

    %transform the points from img 1 by multiplying the homo coord by H
    transformedPoints = pts1_homogenous * H;
    
    %divide each pt by 3rd coord (scale factor lambda) to yield [x;y;1]
    %before taking difference
    lambda_t =  transformedPoints(:,3); %scale factor
    lambda_2 = pts2_homogenous(:,3);    %scale factor 
    du = transformedPoints(:,1) ./ lambda_t - pts2_homogenous(:,1) ./ lambda_2;
    dv = transformedPoints(:,2) ./ lambda_t - pts2_homogenous(:,2) ./ lambda_2;
    residuals = du .* du + dv .* dv;
  %  
    %{
    if size(img1Feat) ~= size(img2Feat)
        error('Number of matched features in the subset supplied to calc_residuals does not match for both images')
    end 
    
    [numMatches, ~] = size(img1Feat);
    
    %homogenous versions of all the feature points
    p1_homogenous = pts1_homogenous';
    %p2_homogenous = pts2_homogenous';
    
    %transform the points from img 1 by multiplying the homo coord by H
    transformedPts = H * p1_homogenous;
    
    
    %divide each pt by 3rd coord (scale factor lambda) to yield [x;y;1]
    scaleFactors = transformedPts(3,:); %lambdas
    transformedPts = bsxfun(@rdivide, transformedPts,scaleFactors);
    transformedPts = transformedPts(1:2,:);
    
    squaredErrorsByDimension = (img2Feat'-transformedPts).^2;
    euclidianDistErrorForEachMatch = sum(squaredErrorsByDimension);
    residuals = euclidianDistErrorForEachMatch;
    %}
end

