function [lft_ndx rgt_ndx] = contrstMatch(p,flag)

  %% finds images of similar luminance
  %% breaks up a list of lenI (1000) images
  %% into nbins (25) by ordering the image by median luminace
  %% returns pairs of images with similar mean luminance values

    imgs = dir([p.path_s '*.jpeg']);
    lenI = 1000;
    mp = zeros(lenI,1);
    mpG = zeros(lenI,1);
    rmsc = zeros(lenI,1);
    nbins = 25;
    nreps = lenI/nbins/2;
    lft_nd = zeros(nbins,nreps);
    rgt_nd = zeros(nbins,nreps);
    
    if flag
        % calculate the median pixel intensity for each image
        for i = 1:lenI
            I = double(imread([p.path_s imgs(i).name]));
            mp(i) = median(I(:));
            mI = mean(I(:));
            s = size(I);
            rmsc(i) = 1/(s(1)*s(2))*sum((mI-I(:)).^2);
            if mod(i,100) == 1
                disp(num2str(i));
            end
        end
    else
        load medPI
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
    
    for i = 1:nbins
        s = 1;  
        while s > 0   % not sure why this while loop is necessary,
				% shuffling each group should be
				% sufficient for randomizing trials
				% mpL(i) == mpR(j) should never be true
				% for any i, j
				% lft_nd(i,j) == rght_nd(i,j) should
				% never be true
            % sNdx = find(mpG == i);
            lft_nd(i,:) = Shuffle(mpL(gNdxL == i));
            rgt_nd(i,:) = Shuffle(mpR(gNdxR == i));
            s = sum(lft_nd(i,:) == rgt_nd(i,:));
            	    disp(num2str(s));
        end
    end

    lft_ndx = lft_nd(:);
    rgt_ndx = rgt_nd(:);
    
    save('rmsc','rmsc');
