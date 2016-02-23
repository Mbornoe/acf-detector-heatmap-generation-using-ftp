function [modelDsX, modelDsY,nOctUp,treeDepth, nWeakLearners]=fetchParameters( settingVar )

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
	%disp(ts);
	cd(ts,settingVar);
	%dir(ts); % Show content
    %overviewFilenamePath = 'overview.csv';
    overviewFilenamePath = 'overview.txt';
    overviewInUseFilenamePath = 'overviewInUse.txt';
    detectorParmsPath = 'detectorParams.txt';

	mget(ts,overviewFilenamePath); % New overview.txt file to make sure we have the latest
    mget(ts,overviewInUseFilenamePath);
    mget(ts,detectorParmsPath);

    fid = fopen(overviewInUseFilenamePath);
    tline = fgetl(fid);
    inUse = strsplit(tline);
    fclose(fid);

    fidParams = fopen(detectorParmsPath);
    tlineParams = fgetl(fidParams);
    inUseParams = strsplit(tlineParams,';');

    nOctUp=inUseParams(2);

    tlineParams = fgetl(fidParams);
    inUseParams = strsplit(tlineParams,';');

    treeDepth=inUseParams(2);

    tlineParams = fgetl(fidParams);
    inUseParams = strsplit(tlineParams,';');

    expression = ',';
    replace = ' ';

    newStr = regexprep(inUseParams(2),expression,replace);

    nWeakLearners= str2num(newStr{1});

    fclose(fidParams);


    if (char(inUse(1)) == '0')

        lockFile('1');
        %pause(2)
        mput(ts,overviewInUseFilenamePath);
        %pause(2)

        mget(ts,overviewFilenamePath);
        mget(ts,detectorParmsPath);

        fid = fopen(overviewFilenamePath);
        tline = fgetl(fid);
        C = strsplit(tline,';');
        rowNumber = 0;
        %disp('File is not in use');
        totalNumberModelDS = length(C)-1;
        array = zeros(totalNumberModelDS);

        upperBound = str2num(cell2mat(C(length(C))));
        lowerBound = str2num(cell2mat(C(2)));

        while ischar(tline)
            tline = fgetl(fid);
            if ischar(tline)
                C = strsplit(tline,';');
                rowNumber = rowNumber + 1;
            end
            for i=2:length(C)
                 char(C(i));
                 array((i-1),rowNumber) = str2num(cell2mat(C(i))) ;
            end
        end
        fclose(fid);
    else
        modelDsX = -2;
        modelDsY = -2;
        return;
    end

    diff = upperBound-lowerBound;
    modelDsX = -1;
    modelDsY = -1;
    proceed=checkForNoZero(array);
    if( proceed == 1 )
        modelDsX = -3;
        modelDsY = -3;
        t = datestr([datetime('now')]);

        dispVarString = sprintf('%s: It seems we are done??',t);
        disp(dispVarString);
        return;
    end

    while( modelDsX == -1 && modelDsY == -1 )
        xCoordinate = round(1 + diff.*rand(1,1));
        yCoordinate = round(1 + diff.*rand(1,1));
        %yCoordinate = round(lowerBound + (upperBound-lowerBound).*rand(1,1))
        if(array(xCoordinate,yCoordinate)==0)
            modelDsX = xCoordinate+lowerBound;
            modelDsY = yCoordinate+lowerBound;
            % Set this to active(1)
        end

    end


    lockFile('0');
    %pause(2)
    mput(ts,overviewInUseFilenamePath);
    %pause(2)
    close(ts);



end
