clear;
close all;
fpadc=fopen('../test/ADC.img');
fpttp=fopen('../test/PWIttp.img');

BW = binmaskadc(fpadc);
imshow(BW);

nBW = binmaskttp(fpttp);
figure,imshow(nBW);
fclose(fpadc);
fclose(fpttp);
fpadc=fopen('../test/ADC.img');
modfpadc = skullstrip(fpadc,BW);
%xd=modfpadc(:,:,24);
%figure,imshow(xd,[]);
fpttp=fopen('../test/PWIttp.img');
modfpttp = skullstript(fpttp,nBW);
