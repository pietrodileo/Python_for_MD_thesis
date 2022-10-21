tic;
% random seed
rng(123)

imds = imageDatastore("SpectrogramDatastore", ...
    "IncludeSubfolders",true,LabelSource="foldernames");
[trainImgs,valImgs,testImgs] = splitEachLabel(imds,0.8,0.1,0.1,"randomized");

trainDs = augmentedImageDatastore([100 100], trainImgs);
valDs = augmentedImageDatastore([100 100], valImgs);
testDs = augmentedImageDatastore([100 100], testImgs);

% check image size, it is fundamental!

% Define CNN from scratch
numClasses = 5;
dropoutProb = 0.2;
layers = [
    imageInputLayer([100 100 3])

    convolution2dLayer(3,16,"Padding","same")
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,"Stride",2)

    convolution2dLayer(3,32,"Padding","same")
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,"Stride",2,"Padding",[0,1])

    dropoutLayer(dropoutProb)
    convolution2dLayer(3,64,"Padding","same")
    batchNormalizationLayer
    reluLayer

    dropoutLayer(dropoutProb)
    convolution2dLayer(3,64,"Padding","same")
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer(2,"Stride",2,"Padding",[0,1])

    dropoutLayer(dropoutProb)
    convolution2dLayer(3,64,"Padding","same")
    batchNormalizationLayer
    reluLayer

    dropoutLayer(dropoutProb)
    convolution2dLayer(3,64,"Padding","same")
    batchNormalizationLayer
    reluLayer

    maxPooling2dLayer([1 13])

    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

options = trainingOptions("adam", ...
    "Plots","training-progress", ...
    "ValidationData",valDs, ...
    "LearnRateSchedule","piecewise", ...
    "LearnRateDropPeriod",15);

scratchNet = trainNetwork(trainDs,layers,options);

testPred = classify(scratchNet,testDs);
nnz(testPred == testImgs.Labels)/numel(testImgs.Labels)

[cmap,clabel] = confusionmat(testImgs.Labels,testPred);
heatmap(clabel,clabel,cmap)

toc;

%% Sensitivity Map
k = 9
testImgs.Labels(k)
testDs.Files{k}
img = imread(testDs.Files{k});
img = imresize(img,[100 100]);
pred = classify(scratchNet,img)
map = occlusionSensitivity(scratchNet,img,pred);
imshow(img)
hold on 
imagesc(map,"AlphaData",.5)
hold off
colormap jet
colorbar
res = strcmp(testImgs.Labels(k),pred);
{testImgs.Labels(k), pred, res}
