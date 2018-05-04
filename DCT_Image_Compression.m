clc;
clear all;
close all;

% Input the threshold coefficients
prompt = 'Enter the number of coefficients    ';
x = input(prompt);

% Read the image
I=imread('face_2.tif');
figure
imshow(I)
title('Original image')

% Subtracting 128 from every pixel
I1=double(I)-128;
mask =ones(8,8);
[r c] =zigzag(mask);


c(x+1:end)= 0;
[r1 c1] = inversezigzag(c,8,8);
maskedcoeff = c1

% Converting image into blocks of size 8x8
function_dct=@(block_struct) maskedcoeff.*dct2(block_struct.data);
image_dct = blockproc(I1, [8 8], function_dct);

b1 = image_dct(33:40, 1:8) %first block in row 5
figure
block1 = imresize(b1, 50,'box');
imshow(block1)
title('DCT 5th Row block 1');

%Quantization matrix
Qxy=[16 11 10 16 24 40 51 61;
    12 12 14 19 26 58 60 55;
    14 13 16 24 40 57 69 56;
    14 17 22 29 51 87 89 62;
    18 22 37 56 68 109 103 77;
    24 35 55 64 81 104 113 92;
    49 64 78 87 108 121 120 101;
    72 92 95 98 112 100 103 99];

%Quantized DCT Matrix
y_proc = @(block_struct) round( block_struct.data./Qxy);
quant_y = blockproc(image_dct, [8 8], y_proc);

quant_b1 = quant_y(33:40, 1:8)  %first block in row 5
figure
block2 = imresize(quant_b1, 50,'box');
imshow(block2)
title('Reconstructed  DCT 5th Row block 1');

%Inverse quantisaton and IDCT
yiq_proc = @(block_struct)  round(block_struct.data.*Qxy);

idct_proc = @(block_struct) idct2(block_struct.data);

yiq = blockproc(quant_y, [8 8], yiq_proc);
y_data = blockproc(yiq, [8 8], idct_proc);

% Adding back 128 to every pixel
I_new= double(y_data)+128;
figure
imshow(uint8(I_new))
title('Reconstructed Image');

% RMS error b/w actual and reconstructed image
error = sqrt(sum(sum(((single(I)-single(I_new)).^2)))/(size(I, 1)*size(I_new, 2)));
sprintf('The root mean square error value is %0.2f\n',error)


function [dc, out] = zigzag(in)
dc = in(1,1);
[r,c]=size(in);

% Initialise the output vector
out=zeros(1,r*c);

i=1;	j=1;	index=1;

while i<=r && j<=c
    if i==1 && mod(i+j,2)==0 && j~=c
        out(index)=in(i,j);
        j=j+1;							%move right at the top
        index=index+1;
        
    elseif i==r && mod(i+j,2)~=0 && j~=c
        out(index)=in(i,j);
        j=j+1;							%move right at the bottom
        index=index+1;
        
    elseif j==1 && mod(i+j,2)~=0 && i~=r
        out(index)=in(i,j);
        i=i+1;							%move down at the left
        index=index+1;
        
    elseif j==c && mod(i+j,2)==0 && i~=r
        out(index)=in(i,j);
        i=i+1;							%move down at the right
        index=index+1;
        
    elseif j~=1 && i~=r && mod(i+j,2)~=0
        out(index)=in(i,j);
        i=i+1;		j=j-1;	%move diagonally left down
        index=index+1;
        
    elseif i~=1 && j~=c && mod(i+j,2)==0
        out(index)=in(i,j);
        i=i-1;		j=j+1;	%move diagonally right up
        index=index+1;
        
    elseif i==r && j==c	%obtain the bottom right element
        out(end)=in(end);
        break
    end
end
end

function [dc, out] = inversezigzag(in,r,c)
dc = in(1,1);

% Initialise the output vector
out=zeros(r,c);

i=1;	j=1;	index=1;

while i<=r && j<=c
    if i==1 && mod(i+j,2)==0 && j~=c
        out(i,j)=in(index);
        j=j+1;							%move right at the top
        index=index+1;
        
    elseif i==r && mod(i+j,2)~=0 && j~=c
        out(i,j)=in(index);
        j=j+1;							%move right at the bottom
        index=index+1;
        
    elseif j==1 && mod(i+j,2)~=0 && i~=r
        out(i,j)=in(index);
        i=i+1;							%move down at the left
        index=index+1;
        
    elseif j==c && mod(i+j,2)==0 && i~=r
        out(i,j)=in(index);
        i=i+1;							%move down at the right
        index=index+1;
        
    elseif j~=1 && i~=r && mod(i+j,2)~=0
        out(i,j)=in(index);
        i=i+1;		j=j-1;	%move diagonally left down
        index=index+1;
        
    elseif i~=1 && j~=c && mod(i+j,2)==0
        out(i,j)=in(index);
        i=i-1;		j=j+1;	%move diagonally right up
        index=index+1;
        
    elseif i==r && j==c	%obtain the bottom right element
        out(end)=in(end);
        break
    end
end
end