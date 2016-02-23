function  updateLog( modelDsX,modelDsY,timing, statusVar,settingVar )
%UNTITLED2 Summary of this function goes here
%   if statusVar 0: Detection started
%   if statusVar 1: Detection done
    t = datestr([datetime('now')]);
    
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
    mget(ts,'logFile.txt');

    if ismac
        currentUser=getenv('USER');
    elseif isunix
        currentUser=getenv('USER');
    elseif ispc
        currentUser=getenv('USERNAME');
    end

    if(statusVar==0) % Detection started
        logString = sprintf('%s: %s STARTED on [%s,%s]',t,currentUser,modelDsX,modelDsY);
    elseif(statusVar==1) % Detection done
        logString = sprintf('%s: %s ENDED on [%s,%s] in %s minutes.',t,currentUser,modelDsX,modelDsY,timing/60);
    end
    prepend2file(logString,'logFile.txt',1);


    mput(ts,'logFile.txt');
    close(ts);
end
