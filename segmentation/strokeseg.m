clear;
close all;
fpadc=fopen('../test/ADC.img');
fpttp=fopen('../test/PWIttp.img');
slice = input('Please input slice number:');
%S = myadcseg(fpadc,slice);
%T = myttpseg(fpttp);
fprintf('1 for segmenting ADC image\n');
fprintf('2 for segmenting TTp image\n');
fprintf('3 for segmenting both images\n');
fprintf('4 for image registration');
n = input('Enter your choice: ');
switch n
    case 1
        S = myadcseg(fpadc,slice);

    case 2
        T = myttpseg(fpttp);
    case 3
        S = myadcseg(fpadc,slice);
        T = myttpseg(fpttp,slice); 
    case 4
        [S,finalImage] = myadcseg(fpadc,slice);
        [T,nfinalImage] = myttpseg(fpttp,slice);  
        [optimizer,metric] = imregconfig('multimodal');
        movingRegisteredDefault = imregister(finalImage, nfinalImage, 'affine', optimizer, metric);

        f3 = figure; 
        imshowpair(movingRegisteredDefault, finalImage);
        figure(f3);
    otherwise
        warning('Unexpected number.try again')
end