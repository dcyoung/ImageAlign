function [composite] = stitch(im1, im2, H)

    [h1, w1, numChannels1] = size(im1);
    [h2, w2, numChannels2] = size(im2);
    %create a matrix of corner points for the first image
    corners = [ 1 1 1;
                w1 1 1;
                w1 h1 1;
                1 h1 1];
    %warp the corner points using the homography matrix    
    warpCorners = homo_2_cart( corners * H );

    %determine the minimum and maximum bounds for the composite image based off
    %the warped corners
    minX = min( min(warpCorners(:,1)), 1);
    maxX = max( max(warpCorners(:,1)), w2);
    minY = min( min(warpCorners(:,2)), 1);
    maxY = max( max(warpCorners(:,2)), h2);

    %use those min and max bounds to define the resolution of the composite image
    xResRange = minX : maxX; %the range for x pixels
    yResRange = minY : maxY; %the range for y pixels

    [x,y] = meshgrid(xResRange,yResRange) ;
    Hinv = inv(H);

    warpedHomoScaleFactor = Hinv(1,3) * x + Hinv(2,3) * y + Hinv(3,3);
    warpX = (Hinv(1,1) * x + Hinv(2,1) * y + Hinv(3,1)) ./ warpedHomoScaleFactor ;
    warpY = (Hinv(1,2) * x + Hinv(2,2) * y + Hinv(3,2)) ./ warpedHomoScaleFactor ;


    if numChannels1 == 1
        %images are black and white... so simple interpolation
        blendedLeftHalf = interp2( im2double(im1), warpX, warpY, 'cubic') ;
        blendedRightHalf = interp2( im2double(im2), x, y, 'cubic') ;
    else
        %images are RGB, so interpolate each channel individually
        blendedLeftHalf = zeros(length(yResRange), length(xResRange), 3);
        blendedRightHalf = zeros(length(yResRange), length(xResRange), 3);
        for i = 1:3
            blendedLeftHalf(:,:,i) = interp2( im2double( im1(:,:,i)), warpX, warpY, 'cubic');
            blendedRightHalf(:,:,i) = interp2( im2double( im2(:,:,i)), x, y, 'cubic');
        end
    end
    %create a blend weight matrix based off the presence of a pixel value from
    %either image in the composite... ie: overlapping region has blendweight of
    %2, a non overlapping region of 1 img has a blendweight of 1, and a region
    %with no img (blank space) has a blendweight of 0.
    blendWeight = ~isnan(blendedLeftHalf) + ~isnan(blendedRightHalf) ;
    %replace all NaN with 0, so they can be blended properly even if there is
    %no pixel value there
    blendedLeftHalf(isnan(blendedLeftHalf)) = 0 ;
    blendedRightHalf(isnan(blendedRightHalf)) = 0 ;
    %add the blendedLeft and Right halves together while dividing by the
    %blendWeight for that pixel.
    composite = (blendedLeftHalf + blendedRightHalf) ./ blendWeight ;

end