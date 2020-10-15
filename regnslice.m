function out = regnslice(pth_img)

if 0
    % Translate a little bit (do this only once!)
    M0 = spm_get_space(pth_img);
    M = M0;
    M(1:3,4) = M0(1:3,4) + 10*randn(3,1);
    spm_get_space(pth_img,M);
end

% Get affine matrix aligning to MNI
[M_a, M_t, M_i, dm_t] = realign2mni(pth_img);
% M_a = eye(4);  % Uncomment to see what happens if you do not register

% Adjust voxel size of template space from 1.5 to 1.0 mm
vx_t = sqrt(sum(M_t(1:3,1:3).^2)); % Template voxel size
D    = diag([vx_t./[1 1 1] 1]);
M_t  = M_t/D;
dm_t = floor(D(1:3,1:3)*dm_t')';

% Get image data resliced to MNI space
M = M_i\M_a*M_t;    % Affine mapping from image to template
y = affine(dm_t,M); % Affine transformation grid

% Get image data
Nii  = nifti(pth_img);
info = niftiinfo(pth_img);
img0 = single(Nii(1).dat());
mn   = min(img0(:));
mx   = max(img0(:));

% Reslice image data
deg   = 1; % interpolation degree
bc    = 0; % interpolation boundary conditions
intrp = [deg deg deg bc bc bc];
c     = spm_diffeo('bsplinc',img0,intrp);
imgr  = spm_diffeo('bsplins',c,y,intrp);
imgr(~isfinite(imgr)) = 0;
imgr  = min(mx, max(mn, imgr)); % Get histogram from this image!

% prepare file for saving
out           = spm_vol(pth_img);
[p,f,e]       = fileparts(out.fname);
out.fname     = fullfile(p,['rg' f e]);
out.dim       = dm_t;
out.descrip   = [out.descrip ' - coregistered and resliced to MNI'];
spm_write_vol(out, imgr);
end