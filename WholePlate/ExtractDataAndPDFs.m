% Move Diagnostic Plots to new folder
% =====================================================================
addpath(genpath('/home/goodwintracking/TheCompleteFlyTrackingBundle/struct2csv'));


ParentDir = pwd;


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
    errorlogfile = strcat(name,'ExtractDataAndPDFs_errors.log');
    try
     
        mkdir Results
        cd('Results')
        ResultsFolder = pwd;
        cd ..
        
        cd(name);
        cd([name '_JAABA']);
        PDFList = dir('*.pdf');
        disp(['Now moving PDFs for: ' name]);
        for x = 1:length(PDFList)
            movefile(PDFList(x).name, ResultsFolder)
        end
        
        ExampleFiles = dir('scores_*.mat');
        ExampleFileData(1) = load(fullfile(pwd, ExampleFiles(1).name));
        ArrayLength = length(ExampleFileData(1).allScores.postprocessed{1,1});
        
        
        
        
        % Extract Data
        % =====================================================================


        IdCorr = dir('*_id_corrected.mat');
        if length(IdCorr) >=1
            files = dir('scores_*_id_corrected.mat');
            
            load('trx_id_corrected.mat', 'trx');
            for v = 1:length([trx.id])
                trx(v).timestamps = transpose(trx(v).timestamps);
                trx(v).dt = transpose(trx(v).dt);
            end
            
            TrackingResults = ([name '_TrackingData.csv']);
            disp(['Now extracting trx data from: ' name]);
            struct2csv(trx, TrackingResults);
            movefile(TrackingResults, ResultsFolder)
            
            disp(['Now extracting JAABA scores from: ' name]);
            WholePlateDataArray = [];
            for v = 1:length([trx.id]) % get the number of flies from the trx.mat file.
                
                for m = 1:numel(files)
                    FileData(m) = load(fullfile(pwd, files(m).name));
                    NextArray = transpose(FileData(m).allScores.postprocessed{1,trx(v).id});
                    IndDataArrayWithoutFPS(1:numel(NextArray),m) = NextArray;
                    FrameNumberArray = transpose([1:1:ArrayLength]);
                    IndDataArray = [FrameNumberArray, IndDataArrayWithoutFPS];
                    
                    DataVariableNamesWithoutFrameNumber(1,(m)) = extractBetween(files(m).name,'scores_','_id_corrected.mat');
                    DataVariableNames = ['Arena', 'Id', 'Frame', DataVariableNamesWithoutFrameNumber];
                end
                
                IdNumber = ones(ArrayLength,1)*v;
                ArenaNumber = round((ones(ArrayLength,1)*v)/2);
                IndDataArrayWithArena = [ArenaNumber, IdNumber, IndDataArray];
                WholePlateDataArray = vertcat(WholePlateDataArray, IndDataArrayWithArena);
            end
        else
            files = dir('scores_*.mat');
            
            load('trx.mat', 'trx');
            for v = 1:length([trx.id])
                trx(v).timestamps = transpose(trx(v).timestamps);
                trx(v).dt = transpose(trx(v).dt);
            end
            
            TrackingResults = ([name '_TrackingData.csv']);
            disp(['Now extracting trx data from: ' name]);
            struct2csv(trx, TrackingResults);
            movefile(TrackingResults, ResultsFolder)
            
            disp(['Now extracting JAABA scores from: ' name]);
            WholePlateDataArray = [];
            for v = 1:length([trx.id]) % get the number of flies from the trx.mat file.
                
                for m = 1:numel(files)
                    FileData(m) = load(fullfile(pwd, files(m).name));
                    NextArray = transpose(FileData(m).allScores.postprocessed{1,trx(v).id});
                    IndDataArrayWithoutFPS(1:numel(NextArray),m) = NextArray;
                    FrameNumberArray = transpose([1:1:ArrayLength]);
                    IndDataArray = [FrameNumberArray, IndDataArrayWithoutFPS];
                    
                    DataVariableNamesWithoutFrameNumber(1,(m)) = extractBetween(files(m).name,'scores_','.mat');
                    DataVariableNames = ['Arena', 'Id', 'Frame', DataVariableNamesWithoutFrameNumber];
                end
                
                IdNumber = ones(ArrayLength,1)*v;
                ArenaNumber = round((ones(ArrayLength,1)*v)/2);
                IndDataArrayWithArena = [ArenaNumber, IdNumber, IndDataArray];
                WholePlateDataArray = vertcat(WholePlateDataArray, IndDataArrayWithArena);
            end
        end


        
        
        % Extract Genotype labels
        % =====================================================================
        HorzGenotypeArray = {};
        
        disp(['Now extracting genotype labels from: ' name]);
        [TempArray{1:length(WholePlateDataArray)}] = deal(name);
        HorzGenotypeArray = [HorzGenotypeArray, TempArray];
        VertGenotypeArray = transpose(HorzGenotypeArray);
        
        GenotypeVariableNames{1,1} = ('FileName');
        
        
        
        
        
        disp('Making Data Table.')
        DataTable = array2table(WholePlateDataArray, 'VariableNames', DataVariableNames);
        disp('Making Names Table.')
        GenotypeTable = array2table(VertGenotypeArray, 'VariableNames', GenotypeVariableNames);
        disp('Making Final Table.')
        MySuperFinalTable = [GenotypeTable, DataTable];
        disp('Writing CSV.')
        writetable(MySuperFinalTable, [ResultsFolder '/' name '_JAABAScores.csv']);
    catch ME
        errorMessage= ME.message;
        disp(errorMessage);
        cd (ParentDir);
        fidd = fopen(errorlogfile, 'a');
        fprintf(fidd, '%s\n', errorMessage); % To file
        fclose(fidd);
    end

      
  cd(ParentDir)
end
exit