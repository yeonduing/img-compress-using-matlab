clear
clc
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

%% No.9 Do IDCT
% caculuate image size
[col, row] = size(afterDCT);
colB = floor(col / 8);
rowB = floor(row / 8);

afterIDCT = zeros(256,256);
for y = 0: colB-1
    for x = 0: rowB-1
        % make 8x8 block
        block = zeros(8,8);
        for i = 1:8
            for j = 1:8
                block(i, j) = afterDCT((y*8)+i,(x*8)+j);
            end
        end
        % do IDCT
        for i = 1:8
            for j = 1:8
                tempSum = 0;
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
                        tempSum = tempSum + temp;
                    end
                end
                %clipping
                if tempSum > 255
                    tempSum = 255;
                elseif tempSum<0
                    tempSum = 0;
                end
                afterIDCT((y*8)+i,(x*8)+j) = tempSum;
            end
        end
    end
end

%% No.10
afterIDCT = uint8(afterIDCT);
save('IDCT_result.mat','afterIDCT')
imwrite(afterIDCT,'IDCT.jpeg')
figure(2); imshow(afterIDCT);

%% No.11,12
% most complex block
py = 25; px = 97;
complexBlock = originalImg(py:py+7, px:px+7);
complexDCTblock = afterDCT(py:py+7, px:px+7);
% figure(3); imshow(complexBlock);
save('complex.mat','complexBlock')
save('complexDCT.mat','complexDCTblock')

% simple and bright block
py = 225; px = 225;
simpleNbrightBlock = originalImg(py:py+7, px:px+7);
simpleNbrightDCTblock = afterDCT(py:py+7, px:px+7);
% figure(5); imshow(simpleNbrightBlock);
save('simpleNbright.mat','simpleNbrightBlock')
save('simpleNbrightDCT.mat','simpleNbrightDCTblock')

% simple and dark block
py = 249; px = 33;
simpleNdarkBlock = originalImg(py:py+7, px:px+7);
simpleNdarkDCTblock = afterDCT(py:py+7, px:px+7);
% figure(5); imshow(simpleNdarkBlock);
save('simpleNdark.mat','simpleNdarkBlock')
save('simpleNdarkDCT.mat','simpleNdarkDCTblock')

% vertical edge
py = 73; px = 129;
verticalEdgeBlock = originalImg(py:py+7, px:px+7);
verticalEdgeDCTblock = afterDCT(py:py+7, px:px+7);
% figure(5); imshow(verticalEdgeBlock);
save('verticalEdge.mat','verticalEdgeBlock')
save('verticalEdgeDCT.mat','verticalEdgeDCTblock')

% horizontal edge
py = 193; px = 73;
horizontalEdgeBlock = originalImg(py:py+7, px:px+7);
horizontalEdgeDCTblock = afterDCT(py:py+7, px:px+7);
% figure(5); imshow(horizontalEdgeBlock);
save('horizontalEdge.mat','horizontalEdgeBlock')
save('horizontalEdgeDCT.mat','horizontalEdgeDCTblock')
