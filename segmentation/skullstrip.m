function modfpadc = skullstrip(fpadc,BW)
modfpadc=zeros(192,192,35);
image =fread(fpadc,192*192*35,'*uint16');
c=reshape(image,192,192,35);
%c=im2uint8(c);
for i=1:35
    gd=c(:,:,i);
    %gd=squeeze(gd);
    gd=imadjust(gd);
    d=imrotate(gd,90,'bilinear','crop');
    finalImage = d;
    finalImage(~BW) = 0;
    %finalImage=imresize(finalImage,2/3);
    %figure,imshow(finalImage);
    
    
    xfinalImage = imgaussfilt(finalImage, 2);
    strokeBW = imbinarize(xfinalImage);
    [~, threshold] = edge(strokeBW, 'sobel');
    fudgeFactor = .5;
    BWstroke = edge(strokeBW,'sobel', threshold*fudgeFactor );

    BWoutline = bwperim(BWstroke);
    SegoutR = finalImage;
    SegoutG = finalImage;
    SegoutB = finalImage;
    %now set yellow, [255 0 255]
    SegoutR(BWoutline) = 255;
    SegoutG(BWoutline) = 0;
    SegoutB(BWoutline) = 255;
    SegoutRGB = cat(3, SegoutR, SegoutG, SegoutB);
    figure,imshow(SegoutRGB);
    %modfpadc(:,:,i) = SegoutRGB;

end

end