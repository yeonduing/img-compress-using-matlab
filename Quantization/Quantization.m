clear
clc
%%% HW1
%% No.1,2 Choose an image and load the image
colorImg = imread('RyuYeonsu.JPG');
colorImg = imresize(colorImg, 0.5);

%% No.3 Convert into gray scale
% extract rgb value
r = colorImg(:, :, 1);
g = colorImg(:, :, 2);
b = colorImg(:, :, 3);
% convert rgb color moder to y
y = 0.299 * r + 0.587 * g + 0.144 * b;

%% No.4 Crop the image into 256x256 size
posY = 200; posX = 150;
originalImg = y(posY:posY+255, posX:posX+255);
figure(1); imshow(originalImg);

%% No.5 Save the original image to jpeg file
imwrite(originalImg, 'originalImg.jpeg');
save('originalImg.mat','originalImg')

%% No.6,7 Make 8x8 block by using 256x256 image array and do DCT
% caculuate image size
[col, row] = size(originalImg);
colB = floor(col / 8);
rowB = floor(row / 8);

afterDCT = zeros(256,256);
for y = 0: colB-1
    for x = 0: rowB-1
        % make 8x8 block
        block = zeros(8,8);
        for u = 1:8
            for v = 1:8
                block(u, v) = originalImg((y*8)+u,(x*8)+v);
            end
        end
        % do DCT
        for u = 1:8
            if u == 1
                cu = sqrt(2) / 2;
            else
                cu = 1;
            end
            for v = 1:8
                if v == 1
                    cv = sqrt(2) / 2;
                else
                    cv = 1;
                end
                tempSum = 0;
                for i = 0:7
                    tempYcos = cos( ((2 * i + 1) * (u-1) * pi) / 16);
                    for j = 0:7
                        tempXcos = cos( ((2 * j + 1) * (v-1) * pi) / 16);
                        temp = tempYcos * tempXcos * block(i+1, j+1);
                        tempSum = tempSum + temp;
                    end
                end
                tempSum = tempSum * cu * cv / 4;
                afterDCT((y*8)+u,(x*8)+v) = tempSum;
            end
        end
    end
end

%% No.8 Save the image converted to 2D DCT to file
afterDCT = int32(afterDCT);
save('DCT_result.mat','afterDCT')

%%% HW2
%% No.1 Using the fomula (9.1), find the quantized DCT coefficients F^(u,v)
%quantization matrix
Q = [16  11  10  16  24   40   51   61   
12  12  14  19  26   58   60   55   
14  13  16  24  40   57   69   56   
14  17  22  29  51   87   80   62   
18  22  37  56  68   109  103  77   
24  35  55  64  81   104  113  92   
49  64  78  87  103  121  120  101  
72  92  95  98  112  100  103  99 ];

% do quantization
quantizedF = zeros(256,256);
colB = 32;
rowB = 32;
for y = 0: colB-1
    for x = 0: rowB-1
        for u = 1:8
            for v = 1:8
                quantizedF((y*8)+u,(x*8)+v) = round(afterDCT((y*8)+u,(x*8)+v) / Q(u,v));
            end
        end
    end
end

%% No.2 Find inverse quantized DCT coefficients F~(u,v)
inverseQF = zeros(256,256);
colB = 32;
rowB = 32;
for y = 0: colB-1
    for x = 0: rowB-1
        for u = 1:8
            for v = 1:8
                inverseQF((y*8)+u,(x*8)+v) = quantizedF((y*8)+u,(x*8)+v) * Q(u,v);
            end
        end
    end
end

%% No.3 Using no.2's results, find 4 cases.
% b. Remain only the F~(0,0) value and zero all the others
inverseQFb = zeros(256,256);
% c. Remain the F~(0,0), F~(0,1), F~(1,0) value and zero all the others
inverseQFc = zeros(256,256);
% d. Remain the F~(0,0), F~(0,1), F~(1,0), F~(1,1), F~(0,2), F~(2,0) value
% and zero all the others
inverseQFd = zeros(256,256);
% d. Remain the F~(0,0), F~(0,1), F~(1,0), F~(1,1), F~(0,2), F~(2,0),
% F~(0,3), F~(1,2), F~(2,1), F~(3,0) value and zero all the others
inverseQFe = zeros(256,256);

colB = 32;
rowB = 32;
for y = 0: colB-1
    for x = 0: rowB-1
        for u = 1:8
            for v = 1:8
                if u == 1 && v == 1
                    inverseQFb((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                    inverseQFc((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                    inverseQFd((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                    inverseQFe((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                elseif (u == 1 && v == 2) || (u == 2 && v == 1)
                    inverseQFb((y*8)+u,(x*8)+v) = 0;
                    inverseQFc((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                    inverseQFd((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                    inverseQFe((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                elseif (u == 2 && v == 2) || (u == 1 && v == 3) || (u == 3 && v == 1)
                    inverseQFb((y*8)+u,(x*8)+v) = 0;
                    inverseQFc((y*8)+u,(x*8)+v) = 0;
                    inverseQFd((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                    inverseQFe((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                elseif (u == 1 && v == 4) || (u == 2 && v == 3) || (u == 3 && v == 2) || (u == 4 && v == 1)
                    inverseQFb((y*8)+u,(x*8)+v) = 0;
                    inverseQFc((y*8)+u,(x*8)+v) = 0;
                    inverseQFd((y*8)+u,(x*8)+v) = 0;
                    inverseQFe((y*8)+u,(x*8)+v) = inverseQF((y*8)+u,(x*8)+v);
                else
                    inverseQFb((y*8)+u,(x*8)+v) = 0;
                    inverseQFc((y*8)+u,(x*8)+v) = 0;
                    inverseQFd((y*8)+u,(x*8)+v) = 0;
                    inverseQFe((y*8)+u,(x*8)+v) = 0;
                end
            end
        end
    end
end

%% No.4,5 Using the fomula (8.18), caculate 2D IDCT and clipping the value
afterIDCT = zeros(256,256);
afterIDCTa = zeros(256,256);
afterIDCTb = zeros(256,256);
afterIDCTc = zeros(256,256);
afterIDCTd = zeros(256,256);
afterIDCTe = zeros(256,256);
colB = 32;
rowB = 32;
for y = 0: colB-1
    for x = 0: rowB-1
        % make 8x8 block
        block = zeros(8,8);
        blockA = zeros(8,8);
        blockB = zeros(8,8);
        blockC = zeros(8,8);
        blockD = zeros(8,8);
        blockE = zeros(8,8);
        for i = 1:8
            for j = 1:8
                block(i, j) = afterDCT((y*8)+i,(x*8)+j);
                blockA(i, j) = inverseQF((y*8)+i,(x*8)+j);
                blockB(i, j) = inverseQFb((y*8)+i,(x*8)+j);
                blockC(i, j) = inverseQFc((y*8)+i,(x*8)+j);
                blockD(i, j) = inverseQFd((y*8)+i,(x*8)+j);
                blockE(i, j) = inverseQFe((y*8)+i,(x*8)+j);
            end
        end
        % do IDCT
        for i = 1:8
            for j = 1:8
                tempSum = 0;
                tempSumA = 0;
                tempSumB = 0;
                tempSumC = 0;
                tempSumD = 0;
                tempSumE = 0;
                for u = 0:7
                    if u == 0
                        cu = sqrt(2) / 2;
                    else
                        cu = 1;
                    end
                    tempUcos = cos( ((2 * (i-1) + 1) * u * pi) / 16);
                    for v = 0:7
                        if v == 0
                            cv = sqrt(2) / 2;
                        else
                            cv = 1;
                        end
                        tempVcos = cos((2 * (j-1) + 1) * v * pi / 16 ) * cu * cv / 4;
                        temp = tempUcos * tempVcos * block(u+1, v+1);
                        tempA = tempUcos * tempVcos * blockA(u+1, v+1);
                        tempB = tempUcos * tempVcos * blockB(u+1, v+1);
                        tempC = tempUcos * tempVcos * blockC(u+1, v+1);
                        tempD = tempUcos * tempVcos * blockD(u+1, v+1);
                        tempE = tempUcos * tempVcos * blockE(u+1, v+1);
                        
                        tempSum = tempSum + temp;
                        tempSumA = tempSumA + tempA;
                        tempSumB = tempSumB + tempB;
                        tempSumC = tempSumC + tempC;
                        tempSumD = tempSumD + tempD;
                        tempSumE = tempSumE + tempE;
                    end
                end
                %clipping
                if tempSum > 255
                    tempSum = 255;
                elseif tempSum < 0
                    tempSum = 0;
                end
                if tempSumA > 255
                    tempSumA = 255;
                elseif tempSumA < 0
                    tempSumA = 0;
                end
                if tempSumB > 255
                    tempSumB = 255;
                elseif tempSumB < 0
                    tempSumB = 0;
                end
                if tempSumC > 255
                    tempSumC = 255;
                elseif tempSumC < 0
                    tempSumC = 0;
                end
                if tempSumD > 255
                    tempSumD = 255;
                elseif tempSumD < 0
                    tempSumD = 0;
                end
                if tempSumE > 255
                    tempSumE = 255;
                elseif tempSumE < 0
                    tempSumE = 0;
                end
                afterIDCT((y*8)+i,(x*8)+j) = tempSum;
                afterIDCTa((y*8)+i,(x*8)+j) = tempSumA;
                afterIDCTb((y*8)+i,(x*8)+j) = tempSumB;
                afterIDCTc((y*8)+i,(x*8)+j) = tempSumC;
                afterIDCTd((y*8)+i,(x*8)+j) = tempSumD;
                afterIDCTe((y*8)+i,(x*8)+j) = tempSumE;
            end
        end
    end
end

%% No.6,7
% Calculate MSE
sum=0;sumA=0;sumB=0;sumC=0;sumD=0;sumE=0;
originalImg = int32(originalImg);
for i=1:256
    for j = 1:256
        sum = sum + power((originalImg(i,j)-afterIDCT(i,j)),2);
        sumA = sumA+power((originalImg(i,j)-afterIDCTa(i,j)),2);
        sumB = sumB+power((originalImg(i,j)-afterIDCTb(i,j)),2);
        sumC = sumC+power((originalImg(i,j)-afterIDCTc(i,j)),2);
        sumD = sumD+power((originalImg(i,j)-afterIDCTd(i,j)),2);
        sumE = sumE+power((originalImg(i,j)-afterIDCTe(i,j)),2);
    end
end

N = 256 * 256;
MSE = single(sum / N);
MSEa = single(sumA / N);
MSEb = single(sumB / N);
MSEc = single(sumC / N);
MSEd = single(sumD / N);
MSEe = single(sumE / N);

% Caculate PSNR
xPeak = 255*255;
PSNR = 10*log10(xPeak / MSE);
PSNRa = 10*log10(xPeak / MSEa);
PSNRb = 10*log10(xPeak / MSEb);
PSNRc = 10*log10(xPeak / MSEc);
PSNRd = 10*log10(xPeak / MSEd);
PSNRe = 10*log10(xPeak / MSEe);

%% No.5 Save the IDCT results into file
afterIDCT = uint8(afterIDCT);
save('IDCT_result.mat','afterIDCT')
imwrite(afterIDCT,'IDCT.jpeg')
figure(2); imshow(afterIDCT);

afterIDCTa = uint8(afterIDCTa);
save('IDCT_result_a.mat','afterIDCTa')
imwrite(afterIDCTa,'IDCTa.jpeg')
figure(3); imshow(afterIDCTa);

afterIDCTb = uint8(afterIDCTb);
save('IDCT_result_b.mat','afterIDCTb')
imwrite(afterIDCTb,'IDCTb.jpeg')
figure(4); imshow(afterIDCTb);

afterIDCTc = uint8(afterIDCTc);
save('IDCT_result_c.mat','afterIDCTc')
imwrite(afterIDCTc,'IDCTc.jpeg')
figure(5); imshow(afterIDCTc);

afterIDCTd = uint8(afterIDCTd);
save('IDCT_result_d.mat','afterIDCTd')
imwrite(afterIDCTd,'IDCTd.jpeg')
figure(6); imshow(afterIDCTd);

afterIDCTe = uint8(afterIDCTe);
save('IDCT_result_e.mat','afterIDCTe')
imwrite(afterIDCTe,'IDCTe.jpeg')
figure(7); imshow(afterIDCTe);
