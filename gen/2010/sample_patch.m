function [patch, nRejected, left, right, top, bottom] = sample_patch(img, saliencyMapBlur, patchSize)
    flattenedSaliencyMap = double(saliencyMapBlur(:));
    left = -1;
    right = 0;
    top = 0;
    bottom = 0;
    [height, width, c] = size(img);
    nRejected = -1;
    while (left <= 0 || right > width || top <= 0 || bottom > height)
        nRejected = nRejected + 1;
        
        % draw a center pixel
        center = rndsample(length(flattenedSaliencyMap), 1, true, flattenedSaliencyMap);
        [centerY, centerX] = ind2sub(size(img), center);
    
        left = centerX - round(patchSize/2);
        right = left + patchSize;
    
        top = centerY - round(patchSize/2);
        bottom = top + patchSize;
    end
    try 
	patch = img(top:bottom, left:right);
    catch
	disp(['top: ' num2str(top) '  bottom: ' num2str(bottom) '  left: ' ...
	      num2str(left) '  right: ' num2str(right) '  size: ' num2str(size(img))]);
    end