function changeOverview( myModelDsX, myModelDsY, label,settingVar )
%UNTITLED2 Summary of this function goes here
%   label 0 : not done
%   label 1 : in progress
%   label 2 : done

ftpFidFile = fopen('ftpSettings.txt');
tlineFtp = fgetl(ftpFidFile);
ftpParams = strsplit(tlineFtp,';');

ftpServerPath = ftpParams(1);
ftpServerUser = ftpParams(2);
ftpServerPassword = ftpParams(3);
fclose(ftpFidFile);

ts = ftp(ftpServerPath,ftpServerUser,ftpServerPassword);

pasv(ts);
dataMode(ts);
cd(ts,settingVar);

overviewFilenamePath ='overview.txt';
mget(ts,overviewFilenamePath);


fid = fopen(overviewFilenamePath,'r');
i = 1;
tline = fgetl(fid);
C = strsplit(tline,';');
rowNumber = 0;
%disp('File is not in use');
totalNumberModelDS = length(C)-1;
array = zeros(totalNumberModelDS);

upperBound = str2num(cell2mat(C(length(C))));
lowerBound = str2num(cell2mat(C(2)));
workingX = myModelDsX-lowerBound+1;
workingY = myModelDsY-lowerBound+1;

A{i} = tline;
while ischar(tline)
    i = i+1;
    tline = fgetl(fid);
    A{i} = tline;
end
fclose(fid);

%A{modelDsY} = '1231230';
tempA=A{workingY};
workingC = strsplit(A{workingY},';');
workingString = '';
for j=1:length(workingC)

    if j==workingX
        workingString = sprintf('%s%s',workingString,num2str(label));
    else
        workingString = sprintf('%s%s',workingString,cell2mat(workingC(j)));
    end
    if j < length(workingC)
        workingString = sprintf('%s;',workingString);
    end
end

A{workingY} = workingString;
% Write cell A into txt
fid = fopen(overviewFilenamePath, 'w');
for i = 1:numel(A)
    if A{i+1} == -1
        fprintf(fid,'%s', A{i});
        break
    else
        fprintf(fid,'%s\n', A{i});
    end
end

mput(ts,overviewFilenamePath);
close(ts);
fclose(fid);

end
