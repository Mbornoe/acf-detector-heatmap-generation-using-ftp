setting = 'settings1';

trainingDataDir = '../data/trafficLights/train/night';
testDataDir = '../test/nightSeq1';

keepRunning = -1;

while( keepRunning == 1)
    doDetection = 0;

    [modelDsX, modelDsY,nOctUp,treeDepth,nWeakLearners] = fetchParameters(setting);

    if(modelDsX == -3)
        t = datestr([datetime('now')]);

        dispVarString = sprintf('%s: We are done with this setting',t);
        disp(dispVarString);
        keepRunning = 0;
        break;
    elseif(modelDsX == -2)

        timeoutVar = round(15+15*rand(1,1));
        timeoutString = '';
        t = datestr([datetime('now')]);

        timeoutString = sprintf('%s: File was in use. We wait %s seconds, and try again',t, num2str(timeoutVar));
        disp(timeoutString);
        pause(timeoutVar) % If the file is in use, we wait atleast 15 sec an try again
        [modelDsX, modelDsY,nOctUp,treeDepth,nWeakLearners] = fetchParameters(setting);
    else
        doDetection = 1;
    end

    if doDetection == 1
        changeOverview(modelDsX,modelDsY,'1',setting);
        workingDsX = modelDsX-1;
        workingDsY = modelDsY-1;
        %
        startDispString ='';
        t = datestr([datetime('now')]);
        startDispString = sprintf('%s: Detection started on ModelDs[%s,%s]',t,num2str(workingDsX),num2str(workingDsY));
        disp(startDispString);
        tic;
        updateLog(num2str(workingDsX),num2str(workingDsY),0,0,setting);
        %
        % Do your magic!
        %pause(1)
        doMagicString = '';
        t = datestr([datetime('now')]);
        doMagicString = sprintf('%s: modelDsX: %s modelDsY: %s nOctUp: %s treeDepth: %s Weaklearnes: %s',t,num2str(workingDsX),num2str(workingDsY),num2str(nOctUp{1}), num2str(treeDepth{1}),num2str(nWeakLearners));
        disp(doMagicString);
        runTldFunction(workingDsX,workingDsY,str2double(nOctUp{1}), str2double(treeDepth{1}),nWeakLearners,trainingDataDir,testDataDir)
        %
        changeOverview(modelDsX,modelDsY,'2',setting);
        doneDispString ='';
        t = datestr([datetime('now')]);
        doneDispString = sprintf('%s: Detection done on ModelDs[%s,%s]',t,num2str(workingDsX),num2str(workingDsY));
        detectionTimeStopped = toc;
        updateLog(num2str(workingDsX),num2str(workingDsY),detectionTimeStopped,1,setting);
        disp(doneDispString);
        %
    end

end

if(keepRunning == =1)
    t = datestr([datetime('now')]);
    workingDsX=20;
    workingDsY=20;
    runTldFunction(workingDsX,workingDsY,2, 4,[10,100,4000],trainingDataDir,testDataDir);
    t = datestr([datetime('now')]);
    doneDispString = sprintf('%s: Detection done on ModelDs[%s,%s]',t,num2str(workingDsX),num2str(workingDsY));
end
