function [F,feat_st]=feature_extraction(recorddata)


fs=256;%set value of sampling frequency


  recorddata(2,:)=do_bandpass_filtering(recorddata(2,:),fs,0.5,10);
  recorddata(3,:)=do_bandpass_filtering(recorddata(3,:),fs,0.5,10);
  recorddata(4,:)=do_bandpass_filtering(recorddata(4,:),fs,0.5,10);
  recorddata(5,:)=do_bandpass_filtering(recorddata(5,:),fs,0.5,10);
  recorddata(6,:)=do_bandpass_filtering(recorddata(6,:),fs,0.5,10);
  recorddata(7,:)=do_bandpass_filtering(recorddata(7,:),fs,0.5,10);
  recorddata(8,:)=do_bandpass_filtering(recorddata(8,:),fs,0.5,10);
  recorddata(9,:)=do_bandpass_filtering(recorddata(9,:),fs,0.5,10);
  recorddata(10,:)=do_bandpass_filtering(recorddata(10,:),fs,0.5,10);

[feat_st, feats_all_epochs_tb] = features_public_code(recorddata(2:10,:));

  

[M,N]=size(recorddata);



window=7680;
no_window=round(N/window);


    
    for j=1:no_window-1
         
                data_p(1:9,:)=recorddata(2:10,(j-1)*window+1:(j)*window);
                [U,S2,V] = svd(data_p);
                S_main=diag(S2);
               
                COP = copula_parametri_delF(data_p(1,:),data_p(2,:),1);

                R1(j,:)=S_main';

                R4(j,:)=COP;
       
    end
  
    sum_copula=sum(abs(R4));
    STD_copula=std( R4);

    max_svd=max(max(R1));

   [f1,y1,bw] = ksdensity(recorddata(2,:));
    
   F(1,1)=sum_copula;

   F(1,2)=max_svd;

   F(1,3)=max(f1);
   F(1,4)=STD_copula;


   end


