function [BW,param] = colourFilterLAB(img,init,rate,percentage)
% input: img, the colour image
%        init, the parametres defining the LAB values for a specific colour and the euclidean distance
%        rate, the rate for expanding the binary mask after each iteration
%        percentage, the upper limit for proportion of 1 (i.e. objects) in a binary mask 
% output: BW, the binary mask for the detected object with the defined colour
    mask_pre = false(size(img,1),size(img,2)); %holder for binary mask at previous iteration
    mask_cur = false(size(img,1),size(img,2)); %holder for binary mask at current iteration
    LMean = init(1);
    aMean = init(2);
    bMean = init(3);
    thres = init(4);

    lab_Image = applycform(im2double(img), makecform('srgb2lab')); %transfrom from RGB to LAB space
    count = 1;
    while (sum(mask_cur,'all') < percentage*numel(lab_Image(:,:,1))) && (count < 3) %stop at too many objects detected or reach the maximum iteration
        deltaL = lab_Image(:,:,1) - LMean;
        deltaa = lab_Image(:,:,2) - aMean;
        deltab = lab_Image(:,:,3) - bMean;
        deltaE = sqrt(deltaL.^2 + deltaa.^2 + deltab.^2); %euclidean distance to the specific colour
        mask_pre = mask_cur;
        mask_cur = deltaE <= thres; %mask = euclidean distance < threshold
        [LMean, aMean, bMean] = GetMeanLABValues(lab_Image(:,:,1), lab_Image(:,:,2), lab_Image(:,:,3), mask_cur); %LAB value for objects within the mask
        meanMaskedDeltaE  = mean(deltaE(mask_cur)); %mean of euclidean distance to the defined colour for detected objects
        stDevMaskedDeltaE = std(deltaE(mask_cur)); %std of euclidean distance to the defined colour for detected objects
        thres = meanMaskedDeltaE + rate*stDevMaskedDeltaE; %new threshold is determined based on the known objects, larger rate will include more objects in the next iteration
%         count = count + 1;
%         f = figure;
%         imshow(deltaE,[]);
%         visual.plotBinaryMask(f,mask_cur,[0.8500 0.3250 0.0980]);
    end
    BW = mask_pre;
    param = [LMean, aMean, bMean, thres] ; 
end

function [LMean, aMean, bMean] = GetMeanLABValues(LChannel, aChannel, bChannel, mask)
    LVector = LChannel(mask); % 1D vector of only the pixels within the masked area.
    LMean = mean(LVector);
    aVector = aChannel(mask); % 1D vector of only the pixels within the masked area.
    aMean = mean(aVector);
    bVector = bChannel(mask); % 1D vector of only the pixels within the masked area.
    bMean = mean(bVector);
end