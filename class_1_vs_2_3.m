function class_test_new=class_1_vs_2_3(TRANING1,TEST1,class_test_total)

class_training=TRANING1(:,end);

index_bin_inactive=find(class_training>3);

m=1;

h=1;   


    
  for k=1:1:size(TRANING1,1) 

      
             if (k~=index_bin_inactive(h))
                 TRANING1_new(m,:)= TRANING1(k,:);
                 m=m+1;
             else
                 if (h<length(index_bin_inactive))
                 h=h+1;
                 
                 end
              end
         end
%    end

class_training_new=TRANING1_new(:,end);
class_training_bin=ones(1, length(class_training_new));
index_bin_1_vs_2_3=find(class_training_new>1);

for h=1:1:length(index_bin_1_vs_2_3)
    
    class_training_bin(index_bin_1_vs_2_3(h))=0;
end

svmStruct = fitcsvm(TRANING1_new(:,1:end-1),class_training_bin');



class_test=class_test_total;
index_bin_inactive_test=find(class_test>3);

class_test_bin=ones(1, length(class_test));


h=1;   
m=1;
% while (h<length(index_bin_inactive))
  if (~isempty(index_bin_inactive_test))  
      for k=1:1:size(TEST1,1) 


                 if (k~=index_bin_inactive_test(h))
                     TEST_new(m,:)= TEST1(k,:);
                     m=m+1;
                 else
                     if (h<length(index_bin_inactive_test))
                     h=h+1;
                     
                     end
                  end
        end
  else
       TEST_new= TEST1;
  end


 class_test_new=class_test_total;

pred_grade_1 = predict(svmStruct,TEST_new); 
index_1=find(pred_grade_1==1);



for i=1:1:length(pred_grade_1)
    
    if (pred_grade_1(i)==0)
        pred_grade_1(i)=2;
        
    end
    
end

class_test_new=[];
k=1;
index2=1;
last_k=1;
brojac=0;
pred_grade_1=pred_grade_1';



index_diff=setdiff(1:1:length(class_test_total),index_bin_inactive_test);

for j=1:1:length(class_test_total)
    index=find(index_bin_inactive_test==j);
    index2=find(index_diff==j);
    
    if (~isempty(index))
        class_test_new=[class_test_new,class_test_total(index_bin_inactive_test(index))];
    else
        class_test_new=[class_test_new,pred_grade_1(index2)];
    end
end
end