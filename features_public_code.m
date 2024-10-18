function [feat_st, feats_all_epochs_tb] = features_public_code(eeg_data)

addpath(genpath('qEEG_feature_set-master'));

addpath('\qEEG_feature_set-master\utils\');
addpath('\qEEG_feature_set-master\spectral_features\');
addpath('\qEEG_feature_set-master\range_EEG\');
addpath('\qEEG_feature_set-master\preprocessing\');
addpath('\qEEG_feature_set-master\amplitude_features\');


      
 feat_set={ 'spectral_power','spectral_entropy','rEEG_upper_margin' ,'rEEG_width'};
      
% channel_names='C4-O2';
ch_labels='C4-O2';
         
 %---------------------------------------------------------------------
% 2. generate features
%---------------------------------------------------------------------

N_feats=length(feat_set);
feats_all_epochs_tb = [];
N_channels=9;
Fs=256;
EPOCH_LENGTH = 8;  % seconds
EPOCH_OVERLAP = 50; % percent

EPOCH_IGNORE_PRC_NANS = 50; 
return_feat_epoch = false;
% A) iterate over features
for n=1:N_feats

    L_feature=size_feature(feat_set{n});
    feat_group=strsplit(feat_set{n},'_');
    feat_group=feat_group{1};

    %---------------------------------------------------------------------
    % SPECTRAL and AMPLITUDE
    % (analysis on a per-channel basis and divide each channel into epochs)
    %---------------------------------------------------------------------
    if( any(strcmp({'amplitude','spectral','rEEG','FD'},feat_group)) )

        % B) iterate over channels
        feats_channel=[]; x_epochs=[]; feats_tbl = [];
        for c=1:N_channels
            [x_epochs, epoch_start_times] = overlap_epochs(eeg_data(c,:)',Fs,EPOCH_LENGTH,50);
              
            N_epochs=size(x_epochs,1);
            
            % C) iterate over epochs
            feats_epochs=NaN(N_epochs,L_feature);
            for e=1:N_epochs
                L_nans=length(find(isnan(x_epochs(e,:))));
                
                if(100*(L_nans/length(x_epochs(e,:))) < EPOCH_IGNORE_PRC_NANS)
                    if(strcmp(feat_group,'spectral'))
                        feats_epochs(e,:)=spectral_features(x_epochs(e,:),Fs, ...
                                                            feat_set{n});
                                                        
                       
                    elseif(strcmp(feat_group,'FD'))
                        feats_epochs(e,:)=fd_features(x_epochs(e,:),Fs);
                        
                    elseif(strcmp(feat_group,'amplitude'))
                        feats_epochs(e,:)=amplitude_features(x_epochs(e,:),Fs, ...
                                                             feat_set{n});
                        
                    elseif(strcmp(feat_group,'rEEG'))
                        feats_epochs(e,:)=rEEG(x_epochs(e,:),Fs,feat_set{n});
                        
                    end
                end
            end
            % if want to return feature estimated over all epochs:
            if(return_feat_epoch)
        	% feats_per_epochs{n}(c,:,:)=feats_epochs;
                
                % create table with features and start time of epoch:
                fb_names = arrayfun(@(x) ['FB' num2str(x)], 1:size(feats_epochs, 2), 'un', false);
                tb = array2table([epoch_start_times' feats_epochs], ...
                                 'VariableNames', ['start_time_sec', fb_names]);
                % add channel:
                tb.channel(:) = string(ch_labels{c});
                
                % convert from wide to long format for frequency bands:
                tb = stack(tb, fb_names, 'newDataVariableName', {'feature_value'}, ...
                           'IndexVariableName', {'freq_band'});
                
                feats_tbl = [feats_tbl; tb];
            end
            
            % median over all epochs
            feats_channel(c,:)=nanmedian(feats_epochs, 1);
        end
        % and median over all channels:
        feat_st.(char(feat_set{n}))=nanmedian(feats_channel, 1);
        

        if(return_feat_epoch)
            % add feature name and combine:
            feats_tbl.feature(:) = string(feat_set{n});
            feats_all_epochs_tb = [feats_all_epochs_tb; feats_tbl];
        end


        %---------------------------------------------------------------------
        % CONNECTIVITY FEATURES
        % (use over all channels but also divide into epochs)
        %---------------------------------------------------------------------
    elseif(strfind(feat_set{n},'connectivity'))

        x_epochs=[]; 
        for c=1:N_channels
            if(c == N_channels)
                [x_epochs(c,:,:), epoch_start_times] = ...
                    overlap_epochs(eeg_data(c,:)',Fs,EPOCH_LENGTH,EPOCH_OVERLAP);
            else
                x_epochs(c,:,:) = overlap_epochs(eeg_data(c,:)',Fs,EPOCH_LENGTH,EPOCH_OVERLAP);
            end
        end
        N_epochs=size(x_epochs,2); 
        
        % B) iterate over epochs:
        feats_epochs=NaN(N_epochs,L_feature);
        x_ep=[];
        
        for e=1:N_epochs
            x_ep=reshape(x_epochs(:,e,:),size(x_epochs,1),size(x_epochs,3));
            
            L_nans=length(find(isnan(x_ep(:))));
            if(100*(L_nans/length(x_ep(:))) < EPOCH_IGNORE_PRC_NANS)
                
                feats_epochs(e,:)=connectivity_features(x_ep,Fs,feat_set{n},[], ...
                                                        ch_labels);
            end
            
        end
        % median over all epochs
        feat_st.(char(feat_set{n}))=nanmedian(feats_epochs, 1);
        
        % if want to return feature estimated over all epochs:
        if(return_feat_epoch)
            % create table with features and start time of epoch:
            fb_names = arrayfun(@(x) ['FB' num2str(x)], 1:size(feats_epochs, 2), 'un', false);
            tb = array2table([epoch_start_times' feats_epochs], ...
                             'VariableNames', ['start_time_sec', fb_names]);
            % add channel:
            tb.channel(:) = NaN;
            
            % convert from wide to long format for frequency bands:
            tb = stack(tb, fb_names, 'newDataVariableName', {'feature_value'}, ...
                       'IndexVariableName', {'freq_band'});
            
            % add feature name and combine:
            tb.feature(:) = string(feat_set{n});
            feats_all_epochs_tb = [feats_all_epochs_tb; tb];
        end
        
        

        %---------------------------------------------------------------------
        % inter-burst interval features
        % (use entire recording but channel-by-channel)
        %---------------------------------------------------------------------
    elseif(strfind(feat_set{n},'IBI_'))
        
        % B) iterate over channels
        feats_channel=NaN(N_channels,L_feature); 
        for c=1:N_channels
            feats_channel(c,:)=IBI_features(eeg_data(c,:)',Fs,feat_set{n});
        end
        % and median over all channels:
        feat_st.(char(feat_set{n}))=nanmedian(feats_channel,1);


    end
end


end


    

