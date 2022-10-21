clc; close all; 
% Start calculating execution time
tic;
% Create a Datastore
ds = audioDatastore("ProvaSpec",...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

% Subfolders Informations
labelCounts = countEachLabel(ds);

% Categorical label of each file in the subfolders
y = ds.Labels; 

% Parameters
plot3DFig = 0; % 3D plot
cm = jet; % ColorMap: jet, bone, gray, copper, parula, turbo
infoOnFigure = 0; % plot axis, title and colorbar on figure
saveImage = 1;

% Spectrogram parameters
window = kaiser(2048,5);
npoints = 2^12;
numOverlap = 0;
plotSpectrogram = 0;
plotScalogram = 1;

while hasdata(ds)
    % read a file
    [audio,info] = read(ds);
    % Check if audio is mono
    if size(audio,2) == 2
        % convert stereo to mono
        audio = (audio(:,1)+audio(:,2))/2;
    end
    % extract file name
    cellName = strsplit(info.FileName,filesep); % Delimiter is selected basing on the operating system through filesep function (Windows '\', Linux '/', ...) 
    fileName = cellName{end};
    fileName = strsplit(fileName,'.');
    fileName = fileName{1};
    % index
    sprintf('Now reading: %s',fileName)
    % Make spectrogram
    [s,f,t,ps] = spectrogram(audio,window,numOverlap,npoints,info.SampleRate);
    % Plot a figure
    fig = figure;
    spectrogram(audio,window,numOverlap,npoints,info.SampleRate,'yaxis');
    %cwt(audio,info.SampleRate)
    %spectrogram(audio,[],[],[],info.SampleRate,'yaxis');
    if plot3DFig == 1
        % 3D view
        view(-45,65)
    end
    colormap(cm);
    if infoOnFigure == 1
        % set title
        ti = join({fileName,char(info.Label)},' - ');
        ti = strrep(ti, '_', ' ');
        title(ti)
    else 
        axis off
        colorbar off
        title ''
    end

    % Export picture and create and image datastore
    if saveImage == 1
        SpecDsName = 'prova'; format = '.png'; AudioClass = char(info.Label);
        exportFigure(SpecDsName, AudioClass, fileName, format, fig)
    end
    close(fig)
end
% show execution time
toc;