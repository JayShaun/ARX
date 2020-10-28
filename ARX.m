clc
clear all
%导入数据
%A = xlsread('update5000.xlsx');
load 'A.mat'
%数据预处理：去除nan和异常值
data=A(2:5001,[1:12 14:373 375:734 736:1095 1097:1456]);

x=[1:12];

data(any(isnan(data),2),:)=[]; 
Y1=data(:,13:13+360-1);
Y2=data(:,373:373+360-1);
Y3=data(:,733:733+360-1);
Y4=data(:,1093:1093+360-1);
%plot(Y1','*');
Y1_exception_row=[];
for i=1:size(Y1,1)
    for j=1:360
        if Y1(i,j)>32000
           Y1_exception_row=[Y1_exception_row i];
        break
        end
    end
end
Y1_X=data(:,x);
%figure
Y1([1066 Y1_exception_row],:)=[];
Y1_X([1066 Y1_exception_row],:)=[];
%plot(Y1,'*');

%plot(Y2','*');
Y2_exception_row=[];
for i=1:size(Y2,1)
    for j=1:360
        if Y2(i,j)>35000
           Y2_exception_row=[Y2_exception_row i];
        break
        end
    end
end
Y2_X=data(:,x);
Y2(Y2_exception_row,:)=[];
Y2_X(Y2_exception_row,:)=[];
%plot(Y2,'*');
%figure
%plot(Y3','*');
Y3_exception_row=[];
for i=1:size(Y3,1)
    for j=1:360
        if Y3(i,j)>7 ||  Y3(i,j)<(-7)
           Y3_exception_row=[Y3_exception_row i];
        break
        end
    end
end
Y3_X=data(:,x);
Y3(Y3_exception_row,:)=[];
Y3_X(Y3_exception_row,:)=[];
%plot(Y3,'*');
%figure
%plot(Y4,'*');
%figure
Y4_exception_row=[];
for i=1:size(Y4,1)
    for j=1:360
        if Y4(i,j)>7 ||  Y4(i,j)<(-7) || (Y4(i,j)>1&&Y4(i,j)<2)
           Y4_exception_row=[Y4_exception_row i];
        break
        end
    end
end
Y4_X=data(:,x);
Y4(Y4_exception_row,:)=[];
Y4_X(Y4_exception_row,:)=[];
%plot(Y4,'*');
for i=1:12
    xmin=min( Y1_X(:, i));
    xmax=max(Y1_X(:, i));
    Y1_X(:, i)=(Y1_X(:, i)-xmin)/(xmax-xmin);
    xmin=min( Y2_X(:, i));
    xmax=max(Y2_X(:, i));
    Y2_X(:, i)=(Y2_X(:, i)-xmin)/(xmax-xmin);
    xmin=min( Y3_X(:, i));
    xmax=max(Y3_X(:, i));
    Y3_X(:, i)=(Y3_X(:, i)-xmin)/(xmax-xmin);
    xmin=min( Y4_X(:, i));
    xmax=max(Y4_X(:, i));
    Y4_X(:, i)=(Y4_X(:, i)-xmin)/(xmax-xmin);	
end
for i=1:size(Y1,1)
    Y1min(i)=min(Y1(i,1:360));
    Y1max(i)=max(Y1(i,1:360));
    Y1(i,1:360)=(Y1(i,1:360)-Y1min(i))/(Y1max(i)-Y1min(i));
end
for i=1:size(Y2,1)
    Y2min(i)=min(Y2(i,1:300));
    Y2max(i)=max(Y2(i,1:300));
    Y2(i,1:300)=(Y2(i,1:300)-Y2min(i))/(Y2max(i)-Y2min(i));
end
for i=1:size(Y3,1)
    Y3min(i)=min(Y3(i,1:300));
    Y3max(i)=max(Y3(i,1:300));
    Y3(i,1:300)=(Y3(i,1:300)-Y3min(i))/(Y3max(i)-Y3min(i));
end
for i=1:size(Y4,1)
    Y4min(i)=min(Y4(i,1:300));
    Y4max(i)=max(Y4(i,1:300));
    Y4(i,1:300)=(Y4(i,1:300)-Y4min(i))/(Y4max(i)-Y4min(i));
end


%% 
%参数设置
treeNum=100;
featureNum=10;

%lag=12;
for i=1:12
    Y1_m{i}=Y1(:,i:12:end);
    Y2_m{i}=Y2(:,i:12:end);
    Y3_m{i}=Y3(:,i:12:end);
    Y4_m{i}=Y4(:,i:12:end);
end

Y1_test_out_origin=Y1(4001:size(Y1,1),301:360);
Y2_test_out_origin=Y2(4001:size(Y2,1),301:360);
Y3_test_out_origin=Y3(4001:size(Y3,1),301:360);
Y4_test_out_origin=Y4(4001:size(Y4,1),301:360);
x_num=size(x,2)+1;
for lag=15
    
for y=1:5
    for m=1:12
 tic
        %划分训练测试集
        Y1_train_in=[Y1_X(1:4000,:) Y1_m{m}(1:4000,25-lag+(y-1):25+(y-1))];%lag=1:24
        Y1_train_out=Y1_m{m}(1:4000,25+y);
        Y1_test_in=[Y1_X(4001:size(Y1,1),:) Y1_m{m}(4001:size(Y1,1),25-lag+(y-1):25+(y-1))];
        model_Y1 = regRF_train( Y1_train_in, Y1_train_out, treeNum);
        Y1_test_out(:,(y-1)*12+m)=regRF_predict( Y1_test_in, model_Y1 );
        Y1_m{m}(4001:size(Y1,1),25+y)=Y1_test_out(:,(y-1)*12+m);
        
         Y2_train_in=[Y2_X(1:4000,:) Y2_m{m}(1:4000,25-lag+(y-1):25+(y-1))];%lag=1:24
         Y2_train_out=Y2_m{m}(1:4000,25+y);
         Y2_test_in=[Y2_X(4001:size(Y2,1),:) Y2_m{m}(4001:size(Y2,1),25-lag+(y-1):25+(y-1))];
         model_Y2 = regRF_train( Y2_train_in, Y2_train_out , treeNum);
         Y2_test_out(:,(y-1)*12+m)=regRF_predict( Y2_test_in, model_Y2 );
         Y2_m{m}(4001:size(Y2,1),25+(y-1)+1)=Y2_test_out(:,(y-1)*12+m);
         
         Y3_train_in=[Y3_X(1:4000,:) Y3_m{m}(1:4000,25-lag+(y-1):25+(y-1))];%lag=1:24
         Y3_train_out=Y3_m{m}(1:4000,25+y);
         Y3_test_in=[Y3_X(4001:size(Y3,1),:) Y3_m{m}(4001:size(Y3,1),25-lag+(y-1):25+(y-1))];
         model_Y3 = regRF_train( Y3_train_in, Y3_train_out , treeNum);
         Y3_test_out(:,(y-1)*12+m)=regRF_predict( Y3_test_in, model_Y3 );
         Y3_m{m}(4001:size(Y3,1),25+(y-1)+1)=Y3_test_out(:,(y-1)*12+m);
         
         Y4_train_in=[Y4_X(1:4000,:) Y4_m{m}(1:4000,25-lag+(y-1):25+(y-1))];%lag=1:24
         Y4_train_out=Y4_m{m}(1:4000,25+y);
          Y4_test_in=[Y4_X(4001:size(Y4,1),:) Y4_m{m}(4001:size(Y4,1),25-lag+(y-1):25+(y-1))];
         model_Y4 = regRF_train( Y4_train_in, Y4_train_out , treeNum);                                         
         Y4_test_out(:,(y-1)*12+m)=regRF_predict( Y4_test_in, model_Y4 );
         Y4_m{m}(4001:size(Y4,1),25+(y-1)+1)=Y4_test_out(:,(y-1)*12+m);

    toc/60
    end
end

end

%--------------------------------------------------------------------------------------------------