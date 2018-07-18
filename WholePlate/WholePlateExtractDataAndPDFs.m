% Move Diagnostic Plots to new folder
% =====================================================================



ParentDir = pwd;
cd ..
mkdir Results 
cd('Results')
ResultsFolder = pwd;
cd(ParentDir)
dirs = dir();
for p = 1:numel(dirs)
    if ~dirs(p).isdir
      continue;
    end
    name = dirs(p).name;
    if ismember(name,{'.','..'})
      continue;
    end
    cd(name);
    cd(name);
    cd([name '_JAABA']);
    PDFList = dir('*.pdf');
    for x = 1:length(PDFList)
        disp(['Now moving PDFs for: ' name]);
        movefile(PDFList(x).name, ResultsFolder) 
    end
    cd ..
    cd ..
    cd ..
end



% Extract all the Data
% =====================================================================

% Setup array length since it varries depending on video length, fps, and
% ffmpeg idiosyncrasies
% =====================================================================
% If the Arrays in each directory are different lengths this bit will
% crash

dirs = dir;
dirs = dirs([dirs.isdir]);
dirs = dirs(~ismember({dirs.name},{'.','..'}));

for w = 1:1
watchajigger = dirs(w).name;
cd (watchajigger);
cd (watchajigger);
cd ([watchajigger '_JAABA']);
ExampleFiles = dir('scores_*.mat');
ExampleFileData(w) = load(fullfile(pwd, ExampleFiles(w).name));
ArrayLength = length(ExampleFileData(w).allScores.postprocessed{1,1});
cd ..
cd ..
cd ..
end

HorzGenotypeArray = {}; 
% Extract Genotype labels
% =====================================================================
for i = 1:numel(dirs)
  if ~dirs(i).isdir
    continue;
  end
  yetanothername = dirs(i).name;
  if ismember(yetanothername,{'.','..'})
    continue;
  end
  disp(['Now extracting genotype labels from: ' yetanothername]);
  
  [TempArray{1:ArrayLength}] = deal(yetanothername);
  HorzGenotypeArray = [HorzGenotypeArray, TempArray];
  VertGenotypeArray = transpose(HorzGenotypeArray);
   
  GenotypeVariableNames{1,1} = ('FileName');
end

% Extract Data from each csv in each folder and add to common table
% =====================================================================
VertDataArray = [];

for k = 1:numel(dirs)
  if ~dirs(k).isdir
    continue;
  end
  anothername = dirs(k).name;
  if ismember(anothername,{'.','..'})
    continue;
  end
  disp (['Now extracting data from: ' anothername]);
  cd (anothername);
  cd (anothername);
  cd ([anothername '_JAABA']);
  files = dir('scores_*.mat');
  
  for m = 1:numel(files)
    FileData(m) = load(fullfile(pwd, files(m).name));
    NextArray = transpose(FileData(m).allScores.postprocessed{1,1});
    IndDataArrayWithoutFPS(1:numel(NextArray),m) = NextArray;
    FrameNumberArray = transpose([1:1:ArrayLength]);
    IndDataArray = [FrameNumberArray, IndDataArrayWithoutFPS];
    DataVariableNamesWithoutFrameNumber{1,(m)} = FileData(m).behaviorName;
    DataVariableNames = ['Frame', DataVariableNamesWithoutFrameNumber];
  end
  cd ..
  cd ..
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
writetable(MySuperFinalTable, [ResultsFolder '\AllRawCourtshipData.csv']);

% clear all


exit

