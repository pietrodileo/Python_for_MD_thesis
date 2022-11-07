folder = "C:\Users\Pietro Di Leo\Documents\MATLAB\Tesi Magistrale\CNN\DatasetTesiFinale_vowelE";

% Create a Datastore
ds = audioDatastore(folder,...
    'IncludeSubfolders',true, ...
    'LabelSource','foldernames');

doPlot=0;
fs_array = [];
i = 1;
overflow = 0;
problematicSubjects = [];
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
    % sample frequency
    fs = info.SampleRate;
    % extract file name
    % Delimiter is based on the operating system through filesep function
    % (Windows '\', Linux '/', ...)
    cellName = strsplit(inform.FileName,filesep); 
    fileName = cellName{end};
    fileName = strsplit(fileName,'.');
    fileName = fileName{1};
    % index
    sprintf('Now reading: %s',fileName)
    % Insert Padding for a better speech detection   
    padding = zeros(1,floor(length(audio)/2));
    PaddedAudio = [padding audio' padding];
    win = hamming(50e-3*fs,"periodic");
    % Speech Detection with Spectral Energy
    idx = detectSpeech(PaddedAudio',fs,Window=win);
    search = not(not(diff(PaddedAudio)));
    % leave 5 sample of padding
    idxStart = find(search, 1, 'first')-5;
    idxStop = find(search, 1, 'last')+5;
    % Compute time
    DurationPadded = length(PaddedAudio) / fs;
    t = 0:1/fs:DurationPadded;
    t = t(1:end-1);
    % overflow control on speech detection
    if numel(idx) > 2
        sprintf('Speech detection overflow on: %s',fileName)
        overflow = 1;
        figure()
        plot(t,PaddedAudio)
        xlabel('Time')
        ylabel('Audio Signal')
        title(fileName)
        xline(idxStart/fs,Color='r')
        xline(idxStop/fs,Color='r')
        xline(idx(1)/fs,Color='g')
        xline(idx(2)/fs,Color='g')
        pause()
        idxStop = idx(2);
        idxStart = idx(1);
    end
    % plot
    if doPlot == 1
        figure()
        pause()
        plot(t,PaddedAudio)
        xlabel('Time')
        ylabel('Audio Signal')
        title(fileName)
        xline(idxStart/fs,Color='r')
        xline(idxStop/fs,Color='r')
        xline(idx(1)/fs,Color='g')
        xline(idx(2)/fs,Color='g')
        pause()
        close()
    end
    if overflow == 1
        problematicSubjects{i} = fileName;
    end
    AudioCut = PaddedAudio(idxStart:idxStop);
    % Save Fine cutted File
    splitted = strsplit(info.Filename,filesep);
    splitted{end} = erase(splitted{end},'.wav');
    splitted{end} = join({splitted{end},'FineCut'},'_');
    splitted{end} = join({splitted{end}{1},'.wav'},'');
    splitted{end} = splitted{end}{1};
    cutName = join(splitted,filesep);
    audiowrite(cutName{1},AudioCut,fs);
    i=i+1;
    overflow = 0; %for the next cycle
end