function [nSegout,nfinalImage] = myttpseg(fpttp,slice)
fontSize = 10;
fp=fopen('../test/PWIttp.img');
image =fread(fpttp,128*128*35,'*uint16');
h=reshape(image,128,128,35);

%figure
%montage(kg,'displayRange' , []);

ngd=h(:,:,24);
ngd=imadjust(ngd);
nd=imrotate(ngd,90,'bilinear','crop');
subplot(2,3,1)
imshow(nd);
title('Original Image', 'FontSize', fontSize);
nlevel = graythresh(nd);
nBW = imbinarize(nd,nlevel);
subplot(2,3,2)
imshow(nBW);
nBW = bwareaopen(nBW, 50);
subplot(2,3,3)
imshow(nBW);
title('Binary Image', 'FontSize', fontSize);





%nBW = imfill(nBW, 'holes');
subplot(2,3,4)
imshow(nBW);
title('Cleaned Binary Image', 'FontSize', fontSize);

nse = strel('disk', 2, 0);
nBW = imerode(nBW, nse);
nBW = imfill(nBW, 'holes');
for i=1:2
    knse = strel('disk', 1, 0);
    nBW = imopen(nBW, knse);
end
%nBW = bwareafilt(nBW,1);

subplot(2, 3, 5);
imshow(nBW, []);
title('Eroded Binary Image', 'FontSize', fontSize);

nfinalImage = nd;
nfinalImage(~nBW) = 0;
subplot(2, 3, 6);
imshow(nfinalImage, []);
title('Skull stripped Image', 'FontSize', fontSize);
nfinalImage=imresize(nfinalImage,1.5);

xnfinalImage = imgaussfilt(nfinalImage, 2);
nstrokeBW = imbinarize(xnfinalImage,.79);
nstrokeBW = bwareafilt(nstrokeBW,1);
[~, threshold] = edge(nstrokeBW, 'sobel');
fudgeFactor = .9;
nBWstroke = edge(nstrokeBW,'sobel', threshold*fudgeFactor );
figure,imshow(nBWstroke);
nBWoutline = bwperim(nBWstroke);
nSegout = nfinalImage; 
nSegout(nBWoutline) = 65536; 
figure,imshow(nSegout);
title('Stroke area', 'FontSize', fontSize);
end
