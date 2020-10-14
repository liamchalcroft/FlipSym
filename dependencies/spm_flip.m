function Vo = spm_flip(V)
% flips images, writes them and adjusts their mat-files
% FORMAT spm_flip
% V - a vector of structures containing image volume information.
% For explanation of the elements of the structure see spm_vol
%___________________________________________________________________________
%
% If spm_flip is called without argument, the interactive function
% spm_get is used for getting images.
%
% The data of the images is flipped in voxel-x-direction.
% The new images are written to img-files with a leading "f".
% The associated new mat-files are calculated to obtain a flipping in
% world-x-direction (the left-right-direction, if the respective prior
% image is aligned properly).
%___________________________________________________________________________
%
% Modified by Liam Chalcroft 2020/10/14
% Added output of new volume for use in FlipSym
% Operational on SPM12,SPM8
% Work performed as student at FIL, UCL
% liam.chalcroft.20@ucl.ac.uk
%___________________________________________________________________________
% Author:       Thomas Kamer
% Last change:  2001/04/12
% Version:      1.0
% Dependencies: SPM99
%
% Usage of code from Karl Friston
%
% Distributed under GNU General Public License (GPL) as published by the
% Free Software Foundation (Version 2 or higher)
%
% Laboratory for Psychiatric Brain Research,
% Department for Psychiatry,
% University of Bonn

if nargin==0
        % get image names
        P     = spm_get(Inf,'*.img',{'select images for flipping'});

        % start progress bar
        spm_progress_bar('Init',length(P),'flipping','');

        % circle through images
        for i = 1:length(P)

                % flip and write
                Vo = flip( spm_vol(P{i}) );

                % show progress
                spm_progress_bar('Set',i);
        end

        % end progress bar
        spm_progress_bar('Clear')
else
        % circle through images
        for i = 1:length(V)

                % flip and write
                Vo = flip( V(i) );
        end
end


function Vo = flip(Vi)
% flips image, calculates mat-data, writes all

        % get image data
        Y             = spm_read_vols(Vi,0);

        % flip image data
        Y             = flipdim(Y,1);

        % prepare name and header of image
        Vo            = Vi;
        [p,f,e]       = fileparts(Vi.fname);
        Vo.fname      = fullfile(p,['f' f e]);
        Vo.descrip    = [Vo.descrip ' - flipped'];

        % calculate adjusted mat-file data
        Vo.mat(1:3,4) = Vo.mat(1:3,4)+Vo.mat(1:3,1)*Vo.dim(1);
        Vo.mat(2:3,1) = -Vo.mat(2:3,1);
        Vo.mat(1,2:4) = -Vo.mat(1,2:4);

        % write flipped image
        Vo            = spm_write_vol(Vo,Y);