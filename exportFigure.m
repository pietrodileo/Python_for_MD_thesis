function exportFigure(datastoreName, label, fileName, format, figure2export)
% check the existance of previous datastore
if ~exist(datastoreName,"dir")
    % make a new directory for the output
    mkdir(datastoreName)
end
% Create a subfolder
subfolderName = append(datastoreName,filesep,label);
output_name = append(subfolderName,filesep,fileName,format);
if ~exist(subfolderName,"dir")
    % make a new directory for the output
    mkdir(subfolderName)
end
% Save picture in the subfolder
exportgraphics(figure2export,output_name,'Resolution',300)
end