%==================================================
%==  Draft script for flip-reg-subtract method  ===
%==      as detailed in Raina et al., 2019      ===
%==        available at arXiv:1907.08196        ===
%==================================================

clear

% Path to some image
pth_img = 'C:\Users\lchalcroft\CT-CNN\data\CT_STORM\Pts_with_ARTQ_or_CAT\PS1390\sXA40405-0003-00001-000001_pre_fix_ge_ct.nii';

% Get image and flip

Nii  = nifti(pth_img);
img = single(Nii(1).dat());
mn   = min(img(:));
mx   = max(img(:));
imgflip = flip(img);



