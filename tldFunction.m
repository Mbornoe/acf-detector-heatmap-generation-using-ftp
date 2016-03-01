function  tldFunction(  modelDsX, modelDsY,nOctUp,treeDepth,nWeakLearners,dataDir,theInputFilenamePath )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    %% Clean up and set environment
    %dataDir
    %dataDir = '../data/trafficLights/train/night';
    %dsStoreStringPos = sprintf('%s/pos/.DS_Store',dataDir);
    %dsStoreStringNeg = sprintf('%s/neg/.DS_Store',dataDir);

    %if exist(dsStoreStringPos, 'file')
    %    delete(dsStoreStringPos);
    %end
    %if exist(dsStoreStringNeg, 'file')
    %    delete(dsStoreStringNeg);
    %end
    %% Set up ACF Detector
    opts=acfTrain();
    opts.modelDs=[modelDsX modelDsY];
    opts.modelDsPad=[25 25];
    opts.pPyramid.pChns.pColor.smooth=0;
    opts.pPyramid.nOctUp = nOctUp;
    %opts.nWeak=[10 100 4000];
    opts.nWeak = nWeakLearners;
    opts.pBoost.pTree.maxDepth=treeDepth;
    opts.pBoost.discrete=0;
    opts.pBoost.pTree.fracFtrs=1/16;
    opts.nNeg=175000;
    opts.nAccNeg=50000;
    opts.pPyramid.pChns.pGradHist.softBin=1; opts.pJitter=struct('flip',1);

    opts.posWinDir=[dataDir '/posCLAHE'];
    opts.negImgDir=[dataDir '/negCLAHE'];

    opts.pPyramid.pChns.shrink=1;
    opts.name='models/Lisa+';

    %% Train ACF Detector
     detector = acfTrain(opts);

    %% Modify ACF Detector
     pModify=struct('cascThr',-1,'cascCal',0.7);
     detector=acfModify(detector,pModify);

     %% Initialize variable
    gtBB(1)=0;
    prerecIterator=0;
    target=0;
    totalTP=0;
    totalFP=0;
    totalFN=0;
    tAverage=0;
    myFrameWidth = 1280;
    myFrameHeight = (960/2)+100;
    nFrames = 1;
    target = [];

    %% Determine number of frames
    tic
    %theInputFilenamePath = '../test/nightSeq1';
    videoReaderString = strcat(theInputFilenamePath,'/framesCLAHE/','*.png');
    d = dir(videoReaderString);
    numFrames = floor(length(d));
    C = strsplit(d(1).name,'--');
    tempTheInputFilename = C(1);
    theInputFilename= tempTheInputFilename{1};
    tEndParallelVideo = toc;
    t = datestr([datetime('now')]);
    outDeterminingFrames = sprintf('%s: Determining number of frames in %s\nFrames: %i\nTime: %f',t,videoReaderString, numFrames,tEndParallelVideo);
    disp(outDeterminingFrames);

    %% Setup worker object wrapper
    fcn = @() fopen( sprintf( 'workerOut/worker_%d.csv', labindex ), 'wt' );
    w = WorkerObjWrapper( fcn, {}, @fclose );
    %% Start detection
    tic
    t = datestr([datetime('now')]);
    outStartDetectionString = sprintf('%s: Starting parallel detection process',t);
    disp(outStartDetectionString);
    parfor frameNumber = 0:numFrames-1
        jpgFileName = strcat(theInputFilenamePath,'/framesCLAHE/',theInputFilename,'--', num2str(frameNumber,'%.5i'), '.png')
        if exist(jpgFileName, 'file')
            imageData = imread(jpgFileName);
            imgLoi = imcrop(imageData,[0 0 myFrameWidth myFrameHeight]);
            bbsAll = acfDetect(imgLoi,detector);
            bbs = bbNms(bbsAll, 'type','max', 'overlap', 0.1);
            FileNameWithExtension = strcat(theInputFilename,'--', num2str(frameNumber,'%.5i'), '.png');
            for l = 1 : size(bbs,1)
                %bbs(l,1)
                %stringEvalResults = sprintf('%s;%i;%i;%i;%d;%f\n',FileNameWithExtension,bbs(l,1),bbs(l,2),bbs(l,3)+bbs(l,1),bbs(l,4)+bbs(l,2),bbs(l,5));
                %disp('%====--------s;%i;%i;%i;%d;%f\n',FileNameWithExtension,bbs(l,1),bbs(l,2),bbs(l,3)+bbs(l,1),bbs(l,4)+bbs(l,2),bbs(l,5));
                fprintf( w.Value, '%s;%.0f;%.0f;%.0f;%.0f;%f\n',FileNameWithExtension,bbs(l,1),bbs(l,2),bbs(l,3)+bbs(l,1),bbs(l,4)+bbs(l,2),bbs(l,5));
                %fprintf(fileEvalResults,stringEvalResults);
            end
        else
            fprintf('File %s does not exist.\n', jpgFileName);
        end
    end
    clear w;
    tEndReadFramePar = toc;
    t = datestr([datetime('now')]);
    readingFrameStringPar = sprintf('%s: Detecting frames Parallel: \nFrames: %f\nTotal detection time: %f\nDetection time per frame: %f\n',t,numFrames,tEndReadFramePar,tEndReadFramePar/numFrames);
    disp(readingFrameStringPar);



end
