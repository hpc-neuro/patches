function [lft_ndx rgt_ndx] = contrastMatch(patch_struct,flag)

  %% finds images of similar luminance
  %% breaks up a list of lenI (1000) images
  %% into nbins (25) by ordering the image by median luminace
  %% returns pairs of images with similar mean luminance values

    %%imgs = patch_struct.imgs; %%dir([patch_struct.path_stim '*.jpeg']);
    lenI = 1000;
    mp = zeros(lenI,1);
    mpG = zeros(lenI,1);
    rmsc = zeros(lenI,1);
    nbins = 25;
    nreps = lenI/nbins/2;
    
    if flag
        % calculate the median pixel intensity for each image
        for i = 1:lenI
            I = double(imread([patch_struct.path_stim patch_struct.imgs(i).name]));
            mp(i) = median(I(:));
            mI = mean(I(:));
            s = size(I);
            rmsc(i) = (1/(s(1)*s(2)))*sum((mI-I(:)).^2);
            if mod(i,100) == 1
                disp(num2str(i));
            end
         end
       save([patch_struct.path_data, 'medPI'], 'mI', 'mp', 'rmsc')  
    else
        load([patch_struct.path_data, 'medPI'])
    end

    % sort in ascending order
    % mp -- median pixel
    [mpS, mpNdx] = sort(mp);
    %[mpS, mpNdx] = sort(rmsc);
    
    mpL = mpNdx(1:2:lenI);
    mpR = mpNdx(2:2:lenI);
    
    % group index
    gNdxL = repmat(1:nbins,nreps,1);
    gNdxL = gNdxL(:);
    
    gNdxR = repmat(1:nbins,nreps,1);
    gNdxR = gNdxR(:);

    lft_ndx = zeros(nbins,nreps);
    rgt_ndx = zeros(nbins,nreps);
    
    for i = 1:nbins
            lft_ndx(i,:) = Shuffle(mpL(gNdxL == i));
            rgt_ndx(i,:) = Shuffle(mpR(gNdxR == i));
    end

    lft_ndx = lft_ndx(:);
    rgt_ndx = rgt_ndx(:);
    