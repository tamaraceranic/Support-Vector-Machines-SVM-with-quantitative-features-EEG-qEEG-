function class_test_total=class_4_vs_1_2_3(TRANING1,TEST1)

class_training=TRANING1(:,end);

index_bin_inactive=find(class_training>3);

class_training_bin=ones(1, length(class_training));

for h=1:1:length(index_bin_inactive)
    
    class_training_bin(index_bin_inactive(h))=0;
end



class_test=zeros(1,size(TEST1,1));

class_test_total=class_test;

svmStruct = fitcsvm(TRANING1(:,1:end-1),class_training_bin');

pred_grade_4 = predict(svmStruct,TEST1); 

index_4=find(pred_grade_4==0);

for j=1:1:length(index_4)
    class_test_total(index_4(j))=4; 
end


end