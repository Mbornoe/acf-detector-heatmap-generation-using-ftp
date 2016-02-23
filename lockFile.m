function lockFile( locked )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if locked == '1'
        t = datestr([datetime('now')]);
        dispVarString = sprintf('%s: File locked',t);
        disp(dispVarString);

        fileID = fopen('overviewInUse.txt','w');
        fprintf(fileID,'1');
        fclose(fileID);
    elseif locked == '0'
        t = datestr([datetime('now')]);
        dispVarString = sprintf('%s: File unlocked',t);
        disp(dispVarString);

        fileID = fopen('overviewInUse.txt','w');
        fprintf(fileID,'0');
        fclose(fileID);
    end
end

