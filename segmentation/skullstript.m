function modfpttp = skullstript(fpttp,nBW)
modfpttp=zeros(128,128,35);
image =fread(fpttp,128*128*35,'*uint16');
h=reshape(image,128,128,35);
h=im2uint8(h);
for i=1:35
    ngd=h(:,:,i);
    ngd=imadjust(ngd);
    nd=imrotate(ngd,90,'bilinear','crop');
    nfinalImage = nd;
    nfinalImage(~nBW) = 0;
    modfpttp(:,:,i) = nfinalImage;
    
    
    xnfinalImage = imgaussfilt(nfinalImage, 2);
    nstrokeBW = imbinarize(xnfinalImage,.79);
    nstrokeBW = bwareafilt(nstrokeBW,1);
    [~, threshold] = edge(nstrokeBW, 'sobel');
    fudgeFactor = .9;
    nBWstroke = edge(nstrokeBW,'sobel', threshold*fudgeFactor );
    figure,imshow(nBWstroke);
    nBWoutline = bwperim(nBWstroke);

    
    nSegoutR = nfinalImage;
    nSegoutG = nfinalImage;
    nSegoutB = nfinalImage;
    %now set pink, [255 0 255]
    nSegoutR(nBWoutline) = 255;
    nSegoutG(nBWoutline) = 0;
    nSegoutB(nBWoutline) = 255;
    nSegoutRGB = cat(3, nSegoutR, nSegoutG, nSegoutB);
    %figure,imshow(nSegoutRGB);
end
end