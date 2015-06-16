%INSTRUCTIONS:
% Install PRTools first
% choose classifier (lines 16-22), choose API, Permissions or combination
% (lines 69-74) by uncommenting the one that you want

%files
load ApiLegitimate.csv
load ApiMalware.csv
load PermissionsLegitimate.csv
load PermissionsMalware.csv

labels = [zeros(1, size(ApiLegitimate,1)) ones(1, size(ApiMalware,1))]';

dsetAPI                 = dataset([ApiLegitimate; ApiMalware], labels);
dsetPermissions         = dataset([PermissionsLegitimate; PermissionsMalware], labels);

%choose classifier
 %w = ldc;
 %w = qdc;
 %w = svc;
 w = knnc;
 %w = adaboostc;


%initialize random generator to create comparable experiments
rand('seed',12345);


%3-fold validation
allScores = [];
allLabels = [];

[dsetAPIFolds{1} tmp ia ib] = gendat(dsetAPI,0.333);

dsetPermissionsFolds{1} = dsetPermissions(ia,:);

[dsetAPIFolds{2} dsetAPIFolds{3} ia ib] = gendat(tmp,0.5);

dsetPermissionsFolds{2} = dsetPermissions(ia,:);
dsetPermissionsFolds{3} = dsetPermissions(ib,:);


%fold combinations (I know I could code this better, but I'm lazy)
trainCombinations = [2 3; 1 3; 1 2];
for i=1:3 %folds
    trainingSet1 = [dsetAPIFolds{trainCombinations(i, 1)}; dsetAPIFolds{trainCombinations(i, 2)}];
    trainingSet2 = [dsetPermissionsFolds{trainCombinations(i, 1)}; dsetPermissionsFolds{trainCombinations(i, 2)}];
    testSet1 = dsetAPIFolds{i};
    testSet2 = dsetPermissionsFolds{i};
    
%     %optional: application of PCA
%     [PCAmapping1, tmp] = PCA(trainingSet1, 20);
%     trainingSet1 = trainingSet1*PCAmapping1;
%     testSet1 = testSet1*PCAmapping1;
%     [PCAmapping2, tmp] = PCA(trainingSet2, 20);
%     trainingSet2 = trainingSet2*PCAmapping2;
%     testSet2 = testSet2*PCAmapping2;
    
    %train classifier
    trainedClassifier = w([trainingSet1 trainingSet2]);
    trainedClassifier1 = w(trainingSet1);
    trainedClassifier2 = w(trainingSet2);
    
    %apply classifier to compute scores
    result =  [testSet1 testSet2]*trainedClassifier;
    result1 = testSet1*trainedClassifier1;
    result2 = testSet2*trainedClassifier2;
    
    %choose API, permissions or combination (avg or sqr)
     %foldScores = result1(:,2);   %API only
     %foldScores = result2(:,2);   %Permissions only
     %foldScores = (result1(:,2) + result2(:,2))/2;   %Average score
     foldScores = (result1(:,2).^2 + result2(:,2).^2)/2;   %Average Sqr score
    
    foldTrueLabels = getlabels(testSet1);
    
    allScores = [allScores foldScores];
    allLabels = [allLabels; foldTrueLabels];
end


%plot things
getEER_FVC_2(allScores,allLabels);

figure;
[Pmiss, Pfa] = Compute_DET(allScores(allLabels == 1),allScores(allLabels == 0));
Plot_DET(Pmiss, Pfa,'r',2);