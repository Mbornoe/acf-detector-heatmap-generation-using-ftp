function  runTldFunction( i,j, nOctUp, treeDepth,nWeakLearners,trainingDataDir,testDataDir)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
t = datestr([datetime('now')]);
        
dispVarString = sprintf('%s: Starting on ModelDS[%i,%i]',t,i,j);
disp(dispVarString);


if(exist('models/', 'dir'))
    delete('models/*');
    delete('workerOut/*');
end
moveToFolderPath = strcat('outputResults/modelDS[',int2str(i),',',int2str(j),']-nOctUp[',int2str(nOctUp),']-treeDepth[',int2str(treeDepth),']/');

dsStoreStringPos = sprintf('%s/pos/.DS_Store',trainingDataDir);
dsStoreStringNeg = sprintf('%s/neg/.DS_Store',trainingDataDir);

if exist(dsStoreStringPos, 'file')
    delete(dsStoreStringPos);
end
if exist(dsStoreStringNeg, 'file')
    delete(dsStoreStringNeg);
end
tldFunction( i,j,nOctUp,treeDepth,nWeakLearners,trainingDataDir,testDataDir);

if ismac
    system('sh mergeWorkers.sh workerOut');
elseif isunix
    system('sh mergeWorkers.sh workerOut');
elseif ispc
    %system('mergeWorkers.sh workerOut');
end
if (exist(moveToFolderPath) == 0)
   mkdir (moveToFolderPath);
end
copyfile('workerOut/',strcat(moveToFolderPath,'workerOut/'));
copyfile('models/',strcat(moveToFolderPath,'models/'));

save(strcat(moveToFolderPath,'workspace'));
delete('models/*');
delete('workerOut/*');


end

