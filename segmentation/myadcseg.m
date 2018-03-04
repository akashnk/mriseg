
function [Segout,finalImage] = myadcseg(fpadc,slice)


fontSize = 10;
% read analyze file
% axial slices
%fp=fopen('../test/ADC.img');
image =fread(fpadc,192*192*35,'*uint16');
c=reshape(image,192,192,35);


% image adjustment and binarization
gd=c(:,:,slice);
gd=squeeze(gd);
gd=imadjust(gd);
d=imrotate(gd,90,'bilinear','crop');
subplot(2,3,1)
imshow(d);
title('Original Image', 'FontSize', fontSize);


level = graythresh(d);
BW = imbinarize(d,level);
subplot(2,3,2)
imshow(BW);
BW = bwareaopen(BW, 10);
subplot(2,3,3)
imshow(BW);
title('Binary Image', 'FontSize', fontSize);

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
    BWcor = imbinarize(dcor,level);
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
    BWsag = imbinarize(dsag,level);
    BWsag = bwareaopen(BWsag, 10);
    for j=1:192
        if BWsag(slice,j)==1 && BW(i,j)==1
            BWnew(i,j)=1;
        end
    end
end

%Morphological operations

BW = imfill(BWnew, 'holes');
subplot(2,3,4)
imshow(BW);
title('Cleaned Binary Image', 'FontSize', fontSize);

se = strel('disk', 1, 0);
BW = imerode(BW, se);
BW = imerode(BW, se);
BW = bwareafilt(BW,1);
subplot(2, 3, 5);
imshow(BW, []);
title('Eroded Binary Image', 'FontSize', fontSize);

finalImage = d;
finalImage(~BW) = 0;
subplot(2, 3, 6);
imshow(finalImage);
exa=finalImage;
title('Skull stripped Image', 'FontSize', fontSize);

%figure,imshow(BWnew);
%extraction of csf
csfBW = imbinarize(finalImage,.7);
csfBW = bwareafilt(csfBW,2);
figure,imshow(csfBW);

%extraction and overlaying of stroke
xfinalImage = imgaussfilt(finalImage, 2);
strokeBW = imbinarize(xfinalImage);
[~, threshold] = edge(strokeBW, 'sobel');
fudgeFactor = .5;
BWstroke = edge(strokeBW,'sobel', threshold*fudgeFactor );
figure,imshow(BWstroke);
BWoutline = bwperim(BWstroke);
Segout = finalImage; 
Segout(BWoutline) = 65536; 
figure,imshow(Segout);
end
