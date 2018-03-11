
function [BW] = binmaskadc(fpadc)

slice=24;
fontSize = 10;
% read analyze file
% axial slices
%fp=fopen('../test/ADC.img');
image =fread(fpadc,192*192*35,'*uint16');
c=reshape(image,192,192,35);
c=im2uint8(c);


% image adjustment and binarization
gd=c(:,:,slice);
%gd=squeeze(gd);
gd=imadjust(gd);
d=imrotate(gd,90,'bilinear','crop');



level = graythresh(d);
BW = imbinarize(d,level);


BW = bwareaopen(BW, 10);


BWnew=false(192);

% 3D connectivity
% connectivity with coronal slices, discarding non-connected parts in
% binary mask
for i=1:192
    gdcor=c(:,i,:);
    gdcor=squeeze(gdcor);
    gdcor=imadjust(gdcor);
    dcor=imrotate(gdcor,90,'bilinear');
    
    levelcor = graythresh(dcor);
    
    BWcor = imbinarize(dcor,levelcor);
    BWcor = bwareaopen(BWcor, 10);
    for j=1:192
        if BWcor(slice,j)==1 && BW(i,j)==1
            BWnew(i,j)=1;
        end
    end
end

% connectivity with saggital slices, discarding non-connected parts
for i=1:192
    gdsag=c(i,:,:);
    gdsag=squeeze(gdsag);
    gdsag=imadjust(gdsag);
    dsag=imrotate(gdsag,90,'bilinear');
    levelsag = graythresh(dsag);
    BWsag = imbinarize(dsag,levelsag);
    BWsag = bwareaopen(BWsag, 10);
    for j=1:192
        if BWsag(slice,j)==1 && BW(i,j)==1
            BWnew(i,j)=1;
        end
    end
end

%Morphological operations

BW = imfill(BWnew, 'holes');


se = strel('disk', 1, 0);
BW = imopen(BW, se);
%BW = imopen(BW, se);
BW = bwareafilt(BW,1);
title('Eroded Binary Image', 'FontSize', fontSize);

end
