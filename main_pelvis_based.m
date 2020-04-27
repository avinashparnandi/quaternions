
clear all
close all
clc

% load the csv file (ones that have already been converted to 3.10 so that the column number match up)
% get the quaternions
% take the pelvis quats

%%

%%
addpath 'C:\Users\parnaa01\OneDrive - NYU Langone Health\code\Matlab\quaternion transformation'


%%
% cd 'C:\Users\parnaa01\OneDrive - NYU Langone Health\IMU data\sensor-based tabletop data\S0008\shelf left side'
cd 'C:\Users\parnaa01\OneDrive - NYU Langone Health\IMU data\pelvis-based tabletop data'

% check 

%% list folders for each subject
% then list folder for one subject
folderMain = dir;
folderListMain = cell(size(folderMain,1)-2,1); % first two elements are . and ..
parfor i=3:size(folderMain,1)
    folderListMain{i-2} = folderMain(i).name; % folderList has all the folders
end


for folderMainCntr = 1:length(folderListMain) % this will loop over all subjects
        cd(char(folderListMain(folderMainCntr))); % cd into folder for each subject

    
%% list all folders for a subject
folderAll = dir;
folderList = cell(size(folderAll,1)-2,1); % first two elements are . and ..
parfor i=3:size(folderAll,1)
    folderList{i-2} = folderAll(i).name; % folderList has all the folders
end

%% cd

for folderCntr = 1:(length(folderList)) % the last element is subjectData.mat and not a folder; so not counting that
  tic
    cd(char(folderList(folderCntr))); % cd into folder for each task
    filesAll = dir('*.csv');
    filesCsv = cell(size(filesAll,1),1);
    
    for j=1:size(filesAll,1)
        filesCsv{j} = filesAll(j).name; % filesCsv has all the csv file in this folder
    end
    
    %%
    
    for k=1:size(filesCsv,1) % looping through csv files in a folder
        
        try
            t = readtable( filesCsv{k});
            filesCsv{k};
        catch
            warning('file does not exisit');
            filesCsv{k} % display the name
            tempFile = {}; % empty cell
        end
        
        
        
        %% calculate a calibrated sample for each sample_quat(i) relative to the current pelvis_quat(i):
        % calibrated_sample(i) = qtransform(sample_quat(i),qinverse(pelvis_quat(i));
        
        % the calibrated sample might have 4 elements; need to check
        
        
        %% sensor-based quaternion transformation
        % quaternion are from column 78 to 104 (x-y-z)
        % for each sensor take the first row and three columns corresponding to
        % x-y-z quaternion; this is the reference
        
        % for each sensor; for each time stamp
        
        for sensorNum=78:3:99, % start for col 78 and go to 101 (not transforming pelvis data)
            
            pelvisStartCol = 102;
            pelvisEndCol = 104;
            
            startCol = sensorNum;
            endCol = startCol+2;

                            refQuat = [sqrt(1-sumsqr(cell2mat(table2cell(t(1,pelvisStartCol:pelvisEndCol))))) cell2mat(table2cell(t(1,pelvisStartCol:pelvisEndCol)))]; % first row, 3 columns: rot x-y-z; concatenated 4th element (rssq) -- unit quat

            
            parfor rowNum=1:size(t,1) % from row#1 to the last row
                
                %% transformation: 
                % % calculate a calibrated sample for each sample_quat(i) using first initial_sample_quat(i) for each sensor, on each record
                % % calibrated_sample(i) = qtransform(sample_quat(i),qinverse(inital_sample_quat(i))
%                 CalibQuat(rowNum,:)= qtransform([rssq(cell2mat(table2cell(t(rowNum,startCol:endCol)))) cell2mat(table2cell(t(rowNum,startCol:endCol)))],qinverse(refQuat)); % calib_sample is 3/4 element vector
                CalibQuat(rowNum,:)= qtransform([sqrt(1-sumsqr(cell2mat(table2cell(t(rowNum,startCol:endCol))))) cell2mat(table2cell(t(rowNum,startCol:endCol)))], qinverse(refQuat)); % qtransform(nth sample, 1st sample)

%                 clearvars refQuat

            end
            
            % calibQuat is a 4 element vector; the first element is 1 (unit quaternion)
            transformedQuat(:,(startCol-77):(endCol-77)) = real(CalibQuat(:,2:end)); % ignore the first column; ensuring that all elements are real since the transformaiton is resulting in imaginary numbers (however the imaginary  component is zero)
            clearvars CalibQuat 
            
        end % sensorNum
        
        % copy the transfored quaternion into the table
        t2=t;
        
        for c = 78:101
            t2.(t2.Properties.VariableNames{c}) = transformedQuat(:,c-77);
        end
        
        % t2 has the modified quaternion
        
        %% writing the csv file
        
%         mkdir('mod')
%         cd('mod')
        formatspec = 'PB_%s'; % SB for sensor based; PB for pelvis based
        modCsvFile = sprintf(formatspec,filesCsv{k});
        writetable(t2,modCsvFile);
%         cd .. % to get out of mod folder
         
        delete(filesCsv{k}) % deleting the old file; % this is dangerous; be careful
%         pause
        clearvars t t2 transformedQuat
        
    end % processing of csv files in a one folder ends here
    
    cd .. % to be able to get into the folder for another task
    toc
end % folder counter ends here (at this point processed all folders for one subject)
cd ..
% pause
end % folder main counter ends (at this point processed all subjects)

% figure,
% subplot(2,1,1), plot([rssq(cell2mat(table2cell(t(:,startCol:endCol))),2) cell2mat(table2cell(t(:,startCol:endCol)))])
% subplot(2,1,2), plot(CalibQuat)