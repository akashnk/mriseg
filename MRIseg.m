clear variables;
close all;
fpadc=fopen('set2/ADC.img');
image =fread(fpadc,192*192*35,'*uint16');
c=reshape(image,192,192,35);
cd=zeros(size(c));
BWM=zeros(128,128,35);
csfdwi=zeros(192,192,3,35);
maxi = max(max(max(c)));
c=double(c);
maxi=double(maxi);
c=uint16(c*255/maxi);
sumbrain = 0;
sumstroke = 0;
for i=1:35
    gd=c(:,:,i);
    if i <=5
        gd(1:192,96:192)=0;
    end
    if i <=7 && i > 5
        gd(1:192,130:192)=0;
    end
     if i <=12 && i > 7
        gd(1:192,144:192)=0;
     end
     if i <=15 && i > 12
        gd(1:192,152:192)=0;
    end
    gd(gd<20)=0;
    %imshow(gd,[]);
    d=imrotate(gd,90,'bilinear','crop');
  d = medfilt2(d);
    cd(:,:,i)=d;
    st=multithresh(d,4);
    seg(:,:,i)=imquantize(d,st);
    BW=imcomplement(seg(:,:,i)==1);
    se=strel('disk',4);
    BW=imopen(BW,se);
    
    BW=bwareafilt(BW,1);
    BW=imfill(BW,'holes');
    BW=bwareafilt(BW,1);
    brainv = sum(BW(:));
    sumbrain = sumbrain + brainv;
    d(~BW)=0;
     dk(:,:,i)=d;
   % k = kmeans(d(:), 5);
   % d = reshape(k, size(d));
%    [mu,mask]=kmeans(d(:),5); 
%    mask= reshape(mu, size(d));
    %imshow(mask, []);
    %adcdwi(:,:,i)=d;
    csfmask = d>105;
    csfmask = and(csfmask,BW);
    csfmask = bwareaopen(csfmask,30);
    csfmaskmat(:,:,i) = csfmask;
      d=mat2gray(d);
    SegoutRGB = imoverlay(d, csfmask, 'blue');
     csfdwi(:,:,:,i)=SegoutRGB;
    imshow(SegoutRGB);
    end 

A = permute(cd, [ 1 2 4 3]);
%figure,imshow(csfdwi(:,:,:,24));



%B = permute(adcdwi, [1 2 4 3]);
figure,montage(A,'DisplayRange', [0 256]);
figure,montage(mat2gray(csfdwi),'DisplayRange',[0 256]);
h =  montage(mat2gray(csfdwi),'DisplayRange',[0 256]);
    
MyMontage = get(h, 'CData');
imwrite(MyMontage, 'csf.png', 'png');

fpadc=fopen('set2/ADC.img');
image =fread(fpadc,192*192*35,'*uint16');
c=reshape(image,192,192,35);
cd=zeros(size(c));
adcdwi=zeros(192,192,3,35);
maxi = max(max(max(c)));
c=double(c);
maxi=double(maxi);
c=uint16(c*255/maxi);
sumbrain = 0;
sumstroke = 0;
strokemaskmat=zeros(size(c));
for i=1:35
    gd=c(:,:,i);
    if i <=5
        gd(1:192,96:192)=0;
    end
    if i <=7 && i > 5
        gd(1:192,130:192)=0;
    end
     if i <=12 && i > 7
        gd(1:192,144:192)=0;
     end
     if i <=15 && i > 12
        gd(1:192,152:192)=0;
    end
    gd(gd<20)=0;
    %imshow(gd,[]);
    d=imrotate(gd,90,'bilinear','crop');
  d = medfilt2(d);
    cd(:,:,i)=d;
    st=multithresh(d,4);
    seg(:,:,i)=imquantize(d,st);
    BW=imcomplement(seg(:,:,i)==1);
    se=strel('disk',4);
    BW=imopen(BW,se);
    
    BW=bwareafilt(BW,1);
    BW=imfill(BW,'holes');
    BW=bwareafilt(BW,1);
    brainv = sum(BW(:));
    sumbrain = sumbrain + brainv;
    d(~BW)=0;
     
   % k = kmeans(d(:), 5);
   % d = reshape(k, size(d));
%    [mu,mask]=kmeans(d(:),5); 
%    mask= reshape(mu, size(d));
    %imshow(mask, []);
    %adcdwi(:,:,i)=d;
    strokemask = d<30;
    strokemask = and(strokemask,BW);
    strokemask = bwareaopen(strokemask,20);
    strokemask = bwareafilt(strokemask,1);
    
    strokev = sum(strokemask(:));
     sumstroke = sumstroke + strokev;
    Segout = d; 
    strokemaskmat(:,:,i)=strokemask;
    Segout(strokemask) = 255;

    d=mat2gray(d);
    SegoutRGB = imoverlay(d, strokemask, 'red');

    adcdwi(:,:,:,i)=SegoutRGB;

end 
corem=sumstroke/sumbrain*100;
A = permute(cd, [ 1 2 4 3]);
%figure,imshow(adcdwi(:,:,:,24));



%B = permute(adcdwi, [1 2 4 3]);
figure,montage(A,'DisplayRange', [0 256]);
figure,montage(mat2gray(adcdwi),'DisplayRange',[0 256]);
h =  montage(mat2gray(adcdwi),'DisplayRange',[0 256]);
Strokevolume=(sumstroke/sumbrain)*100;
MyMontage = get(h, 'CData');
MyMontage = padarray(MyMontage,[10 10],0,'both');
fig = figure;
t = text(.05,.1,'Core area','FontSize',10,'FontWeight','bold');
F = getframe(gca,[20 20 20 20]);
close(fig);
c = F.cdata(:,:,1);
[i,j] = find(c==0);

ind = sub2ind(size(MyMontage),i,j);
MyMontage(ind) = uint8(255);
imwrite(MyMontage, 'adc.png', 'png');

fpttp=fopen('set2/PWIttp.img');
image =fread(fpttp,128*128*35,'*uint16');
h=reshape(image,128,128,35);
maxi = max(max(max(h)));
mini = min(min(min(h)));
monttp=zeros(128,128,3,35);
h=double(h);
maxi=double(maxi);
h=uint16(h*255/maxi);
sumbraintt = 0;
sumstrokett = 0;
for i=1:35
    ngd=h(:,:,i);
    ngd(ngd<30)=0;
   % imshow(ngd,[]);
    nd=imrotate(ngd,90,'bilinear','crop');
    nd = medfilt2(nd);
    %imshow(nd,[]);
    h(:,:,i) = nd;
    kst=multithresh(nd,4);
    kseg(:,:,i)=imquantize(nd,kst);
    nBW=imcomplement(kseg(:,:,i)==1);
    nBW = bwareaopen(nBW, 50);
    nBW = bwareafilt(nBW,1);
    se = strel('disk', 2, 0);
    nBW = imerode(nBW, se);
    nBW = imclose(nBW, se);
    nBW = imclose(nBW, se);
    nBW = bwareaopen(nBW, 50);
    nBW = bwareafilt(nBW,1);
    nBW = imfill(nBW,'holes');
    nd(~nBW)=0;
%     knd = imresize(nd,1.5);
%     ndsk(:,:,i) = knd;
    brainv = sum(nBW(:));
    sumbraintt = sumbraintt + brainv;

kd=nd;
    nd(nd<200)=0;
nstrokeBW = nd;
nstrokeBW = bwareaopen(nstrokeBW,24);
    mstrokeBW = bwareafilt(nstrokeBW,1);
    %mkstrokeBW=imresize(mstrokeBW,1.5);
   BWM(:,:,i) = mstrokeBW;
   strokev = sum(mstrokeBW(:));
   sumstrokett = sumstrokett + strokev;
 Segout = kd; 
    
      kd=mat2gray(kd);
    SegoutRGB = imoverlay(kd, mstrokeBW, [1 0 1]);
    monttp(:,:,:,i)=SegoutRGB;
    imshow(SegoutRGB);
    
   
end
ttpvol=sumstrokett/sumbraintt*100;
A = permute(h, [ 1 2 4 3]);
%B = permute(monttp, [1 2 4 3]);
montage(A,'DisplayRange', [0 256]);
figure,montage(mat2gray(monttp),'DisplayRange', [0 256]);
b = montage(mat2gray(monttp),'DisplayRange', [0 256]);
MyMontage = get(b, 'CData');
imwrite(MyMontage, 'ttp.png', 'png');
close all;

xttpover=zeros(128,128,3,35);

result_dirm= strcat(pwd,'/montages');
    
    if (~isdir(result_dirm))
        mkdir(result_dirm);
        
    end

% Overlay over ttp
    result_dir= strcat(pwd,'/resultsttp');
    
    if (~isdir(result_dir))
        mkdir(result_dir);
        
    end
for i = 1:35
    ai = monttp(:,:,:,i);
    bwai = strokemaskmat(:,:,i);
    bwai = imresize(bwai, [128 128]);
    ai=mat2gray(ai);
    
    bx = imoverlay(ai, bwai, [0 1 0]);
    csfxi=csfmaskmat(:,:,i);
    csfxi=imresize(csfxi, [128 128]);
    bx=mat2gray(bx);
    ttpbx=imoverlay(bx, csfxi, [0 0 1]);
    xttpover(:,:,:,i)=ttpbx;
    baseFileName = sprintf('%d.png', i); 
    fullFileName = fullfile(result_dir, baseFileName);
    imwrite(ttpbx, fullFileName);
end
bnewv = montage(mat2gray(xttpover),'DisplayRange', [0 256]);
MyMontagettp = get(bnewv, 'CData');
imwrite(MyMontagettp, 'ttpover.png', 'png');
penumb = ttpvol - corem;

position =  [50 820];
text_str = ['Core ADC region: ' num2str(corem) ' %'];
padcamttp = padarray(MyMontagettp,[50 50],'both');
newmonttp = insertText(padcamttp,position,text_str,'FontSize',16,'BoxColor','red','BoxOpacity',0.75,'TextColor','white');
position =  [650 820];
text_str1 = ['TTP region: ' num2str(ttpvol) ' %'];
newmon2ttp = insertText(newmonttp,position,text_str1,'FontSize',16,'BoxColor','green','BoxOpacity',0.75,'TextColor','white');

position =  [350 820];
text_str2 = ['Penumbra: ' num2str(penumb) ' %'];
newmon3ttp = insertText(newmon2ttp,position,text_str2,'FontSize',16,'BoxColor','magenta','BoxOpacity',0.75,'TextColor','white');
position =  [400 50];
text_str3 = ['TTP Volume'];
newmon4ttp = insertText(newmon3ttp,position,text_str3,'FontSize',18,'BoxColor','magenta','BoxOpacity',0.75,'TextColor','white');
figure,imshow(newmon4ttp);
imwrite(newmon4ttp, 'overlayed-ttp.png', 'png');
imwrite(newmon4ttp, 'montages/overlayed-ttp.png', 'png');
% Overlay over adc
adcover= zeros(128,128,3,35);
    result_dirx= strcat(pwd,'/resultsadc');
    
    if (~isdir(result_dirx))
        mkdir(result_dirx);
        
    end
for i =1:35
    xi = adcdwi(:,:,:,i);
    xi = imresize(xi, [128 128]);
    bwxi = BWM(:,:,i);
    xi = mat2gray(xi);
    adcbx = imoverlay(xi, bwxi, [0 1 0]);
    
    csfxi=csfmaskmat(:,:,i);
    csfxi=imresize(csfxi, [128 128]);
    adcbx=mat2gray(adcbx);
    adcbxcsf=imoverlay(adcbx, csfxi, [0 0 1]);
    bwai = strokemaskmat(:,:,i);
    
    bwai = imresize(bwai, [128 128]);
    intsecI = bwxi & bwai;
    adcbxcsf=mat2gray(adcbxcsf);
    adcbxtot=imoverlay(adcbxcsf, intsecI, 'magenta');
    adcover(:,:,:,i)=adcbxtot;
    baseFileNamex = sprintf('%d.png', i); 
    fullFileNamex = fullfile(result_dirx, baseFileNamex);
    imwrite(adcbxtot, fullFileNamex);
end
result_dirxx= strcat(pwd,'/montages');
    
    if (~isdir(result_dirxx))
        mkdir(result_dirxx);
        
    end
badcv = montage(mat2gray(adcover),'DisplayRange', [0 256]);
MyMontageadc = get(badcv, 'CData');
imwrite(MyMontageadc, 'adcover.png', 'png');
position =  [50 820];
text_str = ['Core ADC region: ' num2str(corem) ' %'];
padcam = padarray(MyMontageadc,[50 50],'both');
newmon = insertText(padcam,position,text_str,'FontSize',16,'BoxColor','red','BoxOpacity',0.75,'TextColor','white');
position =  [650 820];
text_str1 = ['TTP region: ' num2str(ttpvol) ' %'];
newmon2 = insertText(newmon,position,text_str1,'FontSize',16,'BoxColor','green','BoxOpacity',0.75,'TextColor','white');

position =  [350 820];
text_str2 = ['Penumbra: ' num2str(penumb) ' %'];
newmon3 = insertText(newmon2,position,text_str2,'FontSize',16,'BoxColor','magenta','BoxOpacity',0.75,'TextColor','white');
position =  [400 50];
text_str3 = ['ADC Volume'];
newmon4 = insertText(newmon3,position,text_str3,'FontSize',18,'BoxColor','magenta','BoxOpacity',0.75,'TextColor','white');
figure,imshow(newmon4);
imwrite(newmon4, 'overlayed-adc.png', 'png');
imwrite(newmon4, 'montages/overlayed-adc.png', 'png');