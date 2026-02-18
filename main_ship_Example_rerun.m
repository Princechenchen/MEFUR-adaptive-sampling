% function [rel_true, ErrorEUR,ErrorMEU,ErrorMCE,ErrorEFF,ErrorERF] = main_Example1() 
clear
addpath('./src'); addpath('./sampling_Funciton'); addpath('./testFunc'); addpath('.\grid');
% %shipdata
scheme = xlsread('./dataset/realdata.xlsx',2); %加载数据
scheme = scheme(:,2:8);
response = xlsread('./dataset/realdata.xlsx',1);  
OUTPUT = response(:,[4,27,28]);   %OUTPUT = response(:,[4,27,28]); 
for j = 1:size(response,1)
INPUT(j,:) = scheme(response(j,1),:);
end
ClassPos = [1,1,2]; %%%处理分类响应  2维画图展示与多维通用分开


% guiyihua
[inp,settings2]=mapminmax(INPUT',0,1);
INPUT = inp';

ns = 100; model.ns=ns;% number of candidate points
model.variables.ns=ns;
model.variables.dim=size(INPUT,2); % dimension number
model.ClassPos = ClassPos;
model.total_iter = 70;       % Number of final sample points
model.n_init=20; % Number of initial sample points
model.dim=model.variables.dim;


rerun_num = 10;  %重复运行10
rsl=randperm(ns,rerun_num);
%% 重复运行多次取平均
for j=1:rerun_num
% candidate_set+RefX_set+test_set
% rng default;  % 重置为MATLAB默认的初始状态
rs=rsl(j); model.rs=rs;  %random seed rng(rs)
rng(rs)
% model=cand_gen(model,ns,'uniform');  %candidate samples原始
n=model.n_init+model.ns;  %训练集
indeices = randperm(size(OUTPUT,1),n);
trainy = OUTPUT(indeices,:); trainx = INPUT(indeices,:);
%candidate samples原始
model.candidate = trainx(1+model.n_init:end,:); 
candidatey = trainy(1+model.n_init:end,:);
% initial MMRGP model training
model.init_x = trainx(1:model.n_init,:); 
model.init_value=trainy(1:model.n_init,:); 
%测试集
% ytest = OUTPUT; model.testset = INPUT; ytest(indeices,:)=[]; model.testset(indeices,:)=[];
% tnum = 10000; tsam = 12000;  %loan_data
% tnum = 100; tsam = 250;    % student_mat
tnum = 100; tsam = 70;    % shipdata
indeices = randperm(size(OUTPUT,1),tnum+tsam);
ytest = OUTPUT(indeices(1:tnum),:); model.testset = INPUT(indeices(1:tnum),:);

model.testsample = INPUT(indeices(1+tnum:end),:);
% model.testsample = lhsdesign(12000,model.variables.dim); %test
model.candidate0 = model.candidate;  %原始候选点集

% R = corrcoef(model.init_value);

model.MMRGP = MMRGP0(model.init_value,model.init_x,model.ClassPos,model.dim);
% [y, s, model.MMRGP]=predict_resp(model.MMRGP,model.init_x);
model.now_value=model.init_value; model.now_x=model.init_x;

% Comparison of Multiple methods
modelmaxMSE{j} = model;
modelmeanMSE{j} = model;
modelwmeanMSE{j} = model;
modelIMSE{j} = model;
modelwMSEGrad{j} = model;
% modelSUR{j} = model;
modelSCF{j} = model;
% modelSUR2{j} = model;
% modelSUR2w{j} = model;
modelSUR2wvar{j} = model;
modelSUR2wvarc2{j} = model;
modelSUR2wvarc3{j} = model;
modelSUR2wvarc{j} = model;
modelSUR2wvarcs01{j} = model;
modelSUR2wvarcs03{j} = model;
modelROI_SURwvarcs03{j} = model;
% modelSUR2_sum{j} = model;
% modelSUR_ROI{j} = model;
% modelSUR_ROI2{j} = model;
modelmKMDT{j} = model;
modelMVAS{j} = model;
modelIRS{j} = model;
modelIRS_SUR2wvarc{j} = model;
% modelROI_SUR{j} = model;  %龙志涛方法
modelROI_SURwvarc{j} = model;  %龙志涛方法
% modelROI_SURwvar{j} = model;  %龙志涛方法
% modelROI_SURwsum{j} = model;  %龙志涛方法
modelSUR_ROI2wvarc{j} = model;
modelIWPS{j} = model;
modelUF{j} = model;
modelEIER{j} = model;
modelMELL{j} = model;
modelMEZL{j} = model;
modelmemeroy{j} = model;

%Start of computational time measurements for sequential sampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%      多响应采样     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% maxMSE method
for i = 1:model.total_iter-model.n_init
    [x_star, modelmaxMSE{j}] = maxMSE(modelmaxMSE{j});
    f_star = obj_fct(x_star);
    modelmaxMSE{j}.now_value=[modelmaxMSE{j}.now_value;f_star];
    modelmaxMSE{j}.now_x=[modelmaxMSE{j}.now_x;x_star];
    modelmaxMSE{j}.MMRGP = MMRGP0(modelmaxMSE{j}.now_value,modelmaxMSE{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelmaxMSE{j}.MMRGP,model.testset);  %计算预测误差 
    errormaxMSE = error_func(ytest,ypred,model.ClassPos);         
    modelmaxMSE{j}.error{i} = errormaxMSE;
end
% mMSE method
for i = 1:model.total_iter-model.n_init
    [x_star, modelmeanMSE{j}] = meanMSE(modelmeanMSE{j});
    f_star = obj_fct(x_star);
    modelmeanMSE{j}.now_value=[modelmeanMSE{j}.now_value;f_star];
    modelmeanMSE{j}.now_x=[modelmeanMSE{j}.now_x;x_star];
    modelmeanMSE{j}.MMRGP = MMRGP0(modelmeanMSE{j}.now_value,modelmeanMSE{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelmeanMSE{j}.MMRGP,model.testset);  %计算预测误差 
    errormeanMSE = error_func(ytest,ypred,model.ClassPos);         
    modelmeanMSE{j}.error{i} = errormeanMSE;
end
% IMSE方法
for i = 1:model.total_iter-model.n_init
    [x_star, modelIMSE{j}] = IMSEs(modelIMSE{j});
    xind = model.candidate0(modelIMSE{j}.M_ind(end),:); 
    f_star = candidatey(modelIMSE{j}.M_ind(end),:);
    modelIMSE{j}.now_value=[modelIMSE{j}.now_value;f_star];
    modelIMSE{j}.now_x=[modelIMSE{j}.now_x;x_star];
    modelIMSE{j}.MMRGP = MMRGP0(modelIMSE{j}.now_value,modelIMSE{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelIMSE{j}.MMRGP,model.testset);  %计算预测误差 
    errorIMSE = error_func(ytest,ypred,model.ClassPos);         
    modelIMSE{j}.error{i} = errorIMSE;
end
% mSUR2wvarcs03 method  
for i = 1:model.total_iter-model.n_init  
    [x_star, modelSUR2wvarcs03{j}] = mSUR2w_varcs03(modelSUR2wvarcs03{j});
    xind = model.candidate0(modelSUR2wvarcs03{j}.M_ind(end),:); 
    f_star = candidatey(modelSUR2wvarcs03{j}.M_ind(end),:);
    modelSUR2wvarcs03{j}.now_value=[modelSUR2wvarcs03{j}.now_value;f_star];
    modelSUR2wvarcs03{j}.now_x=[modelSUR2wvarcs03{j}.now_x;x_star];
    modelSUR2wvarcs03{j}.MMRGP = MMRGP0(modelSUR2wvarcs03{j}.now_value,modelSUR2wvarcs03{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelSUR2wvarcs03{j}.MMRGP,model.testset);  %计算预测误差 
    errorSUR2wvarcs03 = error_func(ytest,ypred,model.ClassPos);         
    modelSUR2wvarcs03{j}.error{i} = errorSUR2wvarcs03;
end
% 独立建模
modelind{j} = model;
modelind{j}.SOGP = SOGP(model.init_value,model.init_x,model.ClassPos,model.dim);
for i = 1:model.total_iter-model.n_init
    [x_star, modelind{j}] = SCFind(modelind{j});
    xind = model.candidate0(modelind{j}.M_ind(end),:); 
    f_star = candidatey(modelind{j}.M_ind(end),:);
    modelind{j}.now_value=[modelind{j}.now_value;f_star];
    modelind{j}.now_x=[modelind{j}.now_x;x_star];
    modelind{j}.SOGP = SOGP(modelind{j}.now_value,modelind{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_respind(modelind{j},model.testset);  %计算预测误差 
    errorSCFind = error_func(ytest,ypred,model.ClassPos);         
    modelind{j}.error{i} = errorSCFind;
end

% % mKMDT topsis方法  
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelmKMDT{j}] = mKMDT(modelmKMDT{j});
%     xind = model.candidate0(modelmKMDT{j}.M_ind(end),:); 
%     f_star = candidatey(modelmKMDT{j}.M_ind(end),:);
%     modelmKMDT{j}.now_value=[modelmKMDT{j}.now_value;f_star];
%     modelmKMDT{j}.now_x=[modelmKMDT{j}.now_x;x_star];
%     modelmKMDT{j}.MMRGP = MMRGP0(modelmKMDT{j}.now_value,modelmKMDT{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelmKMDT{j}.MMRGP,model.testset);  %计算预测误差 
%     errormKMDT = error_func(ytest,ypred,model.ClassPos);         
%     modelmKMDT{j}.error{i} = errormKMDT;
% end
% MVAS topsis方法
for i = 1:model.total_iter-model.n_init
    [x_star, modelMVAS{j}] = MVAS(modelMVAS{j});
    xind = model.candidate0(modelMVAS{j}.M_ind(end),:); 
    f_star = candidatey(modelMVAS{j}.M_ind(end),:);
    modelMVAS{j}.now_value=[modelMVAS{j}.now_value;f_star];
    modelMVAS{j}.now_x=[modelMVAS{j}.now_x;x_star];
    modelMVAS{j}.MMRGP = MMRGP0(modelMVAS{j}.now_value,modelMVAS{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelMVAS{j}.MMRGP,model.testset);  %计算预测误差 
    errorMVAS = error_func(ytest,ypred,model.ClassPos);         
    modelMVAS{j}.error{i} = errorMVAS;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%     关键区域采样    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mROI_SURwvarcs03 method 增加关键区域+加权采样+预测方差+U函数  ！！！要记得改关键区域生成样本的函数！！！
addpath('.\MS-PSO');  
for i = 1:model.total_iter-model.n_init
    [x_star, modelROI_SURwvarcs03{j}] = mROI_SUR2w_varcs03(modelROI_SURwvarcs03{j});
    xind = model.candidate0(modelROI_SURwvarcs03{j}.M_ind(end),:); 
    f_star = candidatey(modelROI_SURwvarcs03{j}.M_ind(end),:);
    modelROI_SURwvarcs03{j}.now_value=[modelROI_SURwvarcs03{j}.now_value;f_star];
    modelROI_SURwvarcs03{j}.now_x=[modelROI_SURwvarcs03{j}.now_x;x_star];
    modelROI_SURwvarcs03{j}.MMRGP = MMRGP0(modelROI_SURwvarcs03{j}.now_value,modelROI_SURwvarcs03{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelROI_SURwvarcs03{j}.MMRGP,model.testset);  %计算预测误差 
    errorROI_SURwvarcs03 = error_func(ytest,ypred,model.ClassPos);         
    modelROI_SURwvarcs03{j}.error{i} = errorROI_SURwvarcs03;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%     分类响应采样    %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% EIER method                
for i = 1:model.total_iter-model.n_init
    i
    [x_star, modelEIER{j}] = EIER(modelEIER{j});
    xind = model.candidate0(modelEIER{j}.M_ind(end),:); 
    f_star = candidatey(modelEIER{j}.M_ind(end),:);
    modelEIER{j}.now_value=[modelEIER{j}.now_value;f_star];
    modelEIER{j}.now_x=[modelEIER{j}.now_x;x_star];
    modelEIER{j}.MMRGP = MMRGP0(modelEIER{j}.now_value,modelEIER{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelEIER{j}.MMRGP,model.testset);  %计算预测误差 
    errorEIER = error_func(ytest,ypred,model.ClassPos);         
    modelEIER{j}.error{i} = errorEIER;
end
end

