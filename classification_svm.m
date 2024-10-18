function [est_test]=classification_svm(data,TEST)

class_test_new=[];


  TRAINING=data;


   class_test_total=class_4_vs_1_2_3(TRAINING,TEST);

    if (class_test_total~=4)
       class_test_total2=class_1_vs_2_3(TRAINING,TEST,class_test_total);
    else
        class_test_new=class_test_total;
        
    end

    if (isempty(class_test_new))
    
        if (class_test_total2~=1)
           class_test_new=class_2_vs_3(TRAINING,TEST,class_test_total2);
        else
            class_test_new=class_test_total2;

        end
    end

       est_test=class_test_new;
       
end
  


