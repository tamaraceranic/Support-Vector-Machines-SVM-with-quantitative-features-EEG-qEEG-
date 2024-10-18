function results=main()
%---------------------------------------------------------------------
% 1. use for extraction features for new datasets
%---------------------------------------------------------------------

% Define the folder path where your CSV files are located
 folderPath = 'CSV_format';

% Get a list of all files in the folder
fileList = dir(fullfile(folderPath, '*.csv')); 
file_name = string(zeros(length(fileList),1));

% Loop through the fileList and extract filenames without extension
for i = 1:length(fileList)
    file_name(i) = strrep(fileList(i).name,'.csv','');
end 

R_index=[];

for k=1:1:length(file_name)

    A = importdata(strcat(file_name{k},'.csv'));
    recorddata=A.data;
    recorddata=recorddata';
    


   [F,feat_st]=feature_extraction(recorddata);

    R(k,:)=F;
    R1(k,:)=feat_st.spectral_power;
    R2(k,:)=feat_st.spectral_entropy;
    R3(k,:)=feat_st.rEEG_upper_margin;
    R4(k,:)= feat_st.rEEG_width;

    [value,index]=max(R1(k,:));
    [value2,index2]=min(R2(k,:));
    [value4,index4]=min(R3(k,:));
    [value5,index5]=max(R4(k,:));
    

     R_index(k,:)=[index,index2,index4,index5];
     

       VALIDATION(k,:)=[R(k,1:2),R1(k,index),R2(k,index2),R3(k,index4),R4(k,index5),R(k,3)];

       
end
% 
% % data normalization
% VALIDATION=xlsread('Validation_new_last_version.xlsx');
mean_validation=mean(VALIDATION);
max_validation=max(VALIDATION);
min_validation=min(VALIDATION);

VALIDATION_norm=(VALIDATION-mean_validation)./(max_validation-min_validation);
VALIDATION=VALIDATION_norm;


%---------------------------------------------------------------------
% 2. use files with training and validation  data sets features (https://zenodo.org/record/6587973#.YtARtb0zZaT)
%---------------------------------------------------------------------


% % % TRAINING=xlsread('TrainingNorm.xlsx');
% % %  VALIDATION=xlsread('ValidationNorm.xlsx');


% 
% true_value=xlsread('TrueClassValidation.xlsx');
results=[];

[MV,NV]=size(VALIDATION);

    for k=1:1:MV


        test=VALIDATION(k,:);


        [M,N]=size(TRAINING);
        TRAINING_NORM=[TRAINING(:,1:N-1);test];
        mean_value=mean((TRAINING_NORM));
        std_value=std((TRAINING_NORM));

        %NORMALIZACIJA ZA SVM
        for m=1:1:N-1
            TRANING(:,m)=(TRAINING_NORM(:,m)-mean_value(m))./(std_value(m));

        end

         TRANING_n=TRANING(1:end-1,:);
         test_norm=TRANING(end,:);



        data=[TRANING_n,TRAINING(:,end)];


        [est_test]=classification_svm(data,test_norm);
        results=[results,est_test];


    end

 csvwrite('validation_res.csv',results');
end