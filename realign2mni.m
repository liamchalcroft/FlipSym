function [M_a, M_t, M_i, dm_t] = realign2mni(P,samp)
% Reposition an image by affine aligning to MNI space
% FORMAT rigid_align(P)
% INPUT
% P - name of NIfTI image
% samp - subsampling, larger means faster algorithm [4]
%
% OUTPUT
% M_a - affine matrix
% M_t - template matrix
% M_i - image matrix
% dm_t - template dimensions
%__________________________________________________________________________
% Copyright (C) 2018 Wellcome Trust Centre for Neuroimaging

if nargin < 2, samp = 4; end
    
% Load tissue probability data
tpm = fullfile(spm('dir'),'tpm','TPM.nii,');
tpm = [repmat(tpm,[6 1]) num2str((1:6)')];
tpm = spm_load_priors8(tpm);
M_t = tpm.M;
dm_t = size(tpm.dat{1});

% Do the affine registration
V = spm_vol(P);

M_i             = V(1).mat;
c               = (V(1).dim+1)/2;
V(1).mat(1:3,4) = -M_i(1:3,1:3)*c(:);
[Affine1,ll1]   = spm_maff8(V(1),2*samp,(0+1)*16,tpm,[],'mni'); % Closer to rigid
Affine1         = Affine1*(V(1).mat/M_i);

% Run using the origin from the header
V(1).mat      = M_i;
[Affine2,ll2] = spm_maff8(V(1),2*samp,(0+1)*16,tpm,[],'mni'); % Closer to rigid

% Pick the result with the best fit
if ll1>ll2, Affine  = Affine1; else Affine  = Affine2; end

Affine = spm_maff8(P,samp,32,tpm,Affine,'mni'); % Heavily regularised
Affine = spm_maff8(P,samp,1 ,tpm,Affine,'mni'); % Lightly regularised

% Generate mm coordinates of where deformations map from
x = affind(rgrid(size(tpm.dat{1})),tpm.M);

% Generate mm coordinates of where deformation maps to
y1 = affind(x,inv(Affine));

% Weight the transform via GM+WM
weight = single(exp(tpm.dat{1})+exp(tpm.dat{2}));

% Weighted Procrustes analysis
M_a = spm_get_closest_affine(x,y1,weight);
%==========================================================================

%==========================================================================
function x = rgrid(d)
x = zeros([d(1:3) 3],'single');
[x1,x2] = ndgrid(single(1:d(1)),single(1:d(2)));
for i=1:d(3)
    x(:,:,i,1) = x1;
    x(:,:,i,2) = x2;
    x(:,:,i,3) = single(i);
end
%==========================================================================

%==========================================================================
function y1 = affind(y0,M)
y1 = zeros(size(y0),'single');
for d=1:3
    y1(:,:,:,d) = y0(:,:,:,1)*M(d,1) + y0(:,:,:,2)*M(d,2) + y0(:,:,:,3)*M(d,3) + M(d,4);
end
%==========================================================================