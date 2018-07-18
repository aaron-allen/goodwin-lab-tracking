%...
%=====================================================================
dirs = dir();
HorzGenotypeArray = {}; 
%Extract Genotype labels
%=====================================================================
for i = 1:numel(dirs)
  if ~dirs(i).isdir
    continue;
  end
  name = dirs(i).name;
  if ismember(name,{'.','..'})
    continue;
  end
  disp(['Generating Genotype Labels for: ' name]);
  
  [TempArray{1:14999}] = deal(name);
  HorzGenotypeArray = [HorzGenotypeArray, TempArray];
  VertGenotypeArray = transpose(HorzGenotypeArray);
  GenotypeVariableNames{1,1} = ('Genotype');
end

% Extract Data from each csv in each folder and add to common table
% =====================================================================
VertDataArray = [];
for k = 1:numel(dirs)
  if ~dirs(k).isdir
    continue;
  end
  name = dirs(k).name;
  if ismember(name,{'.','..'})
    continue;
  end
  disp (['Now entering: ' name]);
  cd (name);
  files = dir('scores_*.mat');
  
  for m = 1:numel(files)
    FileData(m) = load(fullfile(pwd, files(m).name));
    NextArray = transpose(FileData(m).allScores.postprocessed{1,1});
    IndDataArray(1:numel(NextArray),m) = NextArray;
    DataVariableNames{1,(m)} = FileData(m).behaviorName;
  end
  cd ..
  VertDataArray = vertcat(VertDataArray, IndDataArray); 
end

disp('Making Data Table.')
DataTable = array2table(VertDataArray, 'VariableNames', DataVariableNames);
disp('Making Names Table.')
GenotypeTable = array2table(VertGenotypeArray, 'VariableNames', GenotypeVariableNames);
disp('Making Final Table.')
MySuperFinalTable = [GenotypeTable, DataTable];
disp('Writing CSV.')
writetable(MySuperFinalTable, 'AllRawCourtshipData.csv');
clear all
   
