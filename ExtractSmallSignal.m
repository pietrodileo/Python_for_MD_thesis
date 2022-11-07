folder = "C:\Users\Pietro Di Leo\Documents\MATLAB\Tesi Magistrale\CNN\DatasetTesiFinale_vowelE_FineCut";

% Create a Datastore
ds = audioDatastore(folder,...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

fs_array = [];
i = 1;
doPlot = 0;
while hasdata(ds)
    % read a file
    [audio,inform] = read(ds);
    % Check if audio is mono
    if size(audio,2) == 2
        % convert stereo to mono
        audio = (audio(:,1)+audio(:,2))/2;
    end
    % Extract more audio informations
    info = audioinfo(inform.FileName);
    % extract file name
    cellName = strsplit(inform.FileName,filesep); % Delimiter is based on the operating system through filesep function (Windows '\', Linux '/', ...) 
    fileName = cellName{end};
    fileName = strsplit(fileName,'.');
    fileName = fileName{1};
    % index
    sprintf('Now reading: %s',fileName)
    % Insert Padding for a better speech detection   
    padding = zeros(1,floor(length(audio)/2));
    PaddedAudio = [padding audio' padding];
    % Speech detection through spectral energy
    win = hamming(50e-3*info.SampleRate,"periodic");
    idx = detectSpeech(PaddedAudio',info.SampleRate,Window=win);
    % Take the audio some k samples before the first index  
    %k = 20;
    %idxStart = idx(1)-abs(floor(length(padding)/k));
    % k value is set in order to have a starting sample that is 0 (part of
    % the padding)
    %while PaddedAudio(idxStart) ~= 0
    %    k = k/2;
    %    idxStart = idx(1)-abs(floor(length(padding)/k));
    %end
    % NEW CODE, more simple
    search = not(not(diff(PaddedAudio)));
    idxStart = find(search, 1, 'first')-5;
    % Take two seconds of audio after the transient
    idxStop = idxStart + 2*info.SampleRate; 
    if idxStop > length(audio)+length(padding)
        idxStop = idx(2);
    end
    DurationPadded = length(PaddedAudio) / info.SampleRate;
    t = 0:1/info.SampleRate:DurationPadded;
    t = t(1:end-1);
    if doPlot == 1
        % plot
        figure()
        plot(t,PaddedAudio)
        xlabel('Time')
        ylabel('Audio Signal')
        title(fileName)
        xline(idxStart/info.SampleRate,Color='r')
        xline(idxStop/info.SampleRate,Color='r')
        i=i+1;
    end
    AudioCut = PaddedAudio(idxStart:idxStop);
    % Save Fine cutted File
    splitted = strsplit(info.Filename,filesep);
    splitted{end} = erase(splitted{end},'.wav');
    splitted{end} = join({splitted{end},'Cut'},'_');
    splitted{end} = join({splitted{end}{1},'.wav'},'');
    splitted{end} = splitted{end}{1};
    newpath = join({splitted{8},'ShortCut'},'_');
    splitted{8} = newpath{1};
    newfolder = join(splitted(1:end-1),filesep);
    if not(exist("newfolder","dir"))
        [status, msg, msgID] = mkdir(newfolder{1});
    end
    cutName = join(splitted,filesep);
    audiowrite(cutName{1},AudioCut,fs);
end