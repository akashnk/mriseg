function [nBW] = binmaskttp(fpttp)
slice=24;
fontSize = 10;
fp=fopen('../test/PWIttp.img');
image =fread(fpttp,128*128*35,'*uint16');
h=reshape(image,128,128,35);

%figure
%montage(kg,'displayRange' , []);

ngd=h(:,:,slice);
ngd=imadjust(ngd);
nd=imrotate(ngd,90,'bilinear','crop');

title('Original Image', 'FontSize', fontSize);
nlevel = graythresh(nd);
nBW = imbinarize(nd,nlevel);

nBW = bwareaopen(nBW, 50);

title('Binary Image', 'FontSize', fontSize);





%nBW = imfill(nBW, 'holes');


nse = strel('disk', 2, 0);
nBW = imerode(nBW, nse);
nBW = imfill(nBW, 'holes');
for i=1:2
    knse = strel('disk', 1, 0);
    nBW = imopen(nBW, knse);
end
%nBW = bwareafilt(nBW,1);
end
