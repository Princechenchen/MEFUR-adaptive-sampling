% function [rel_true, ErrorEUR,ErrorMEU,ErrorMCE,ErrorEFF,ErrorERF] = main_Example1() 
clear
addpath('./src'); addpath('./sampling_Funciton'); addpath('./testFunc'); addpath('.\grid');
% pyenv(Version="F:\tools\Python39\python.exe");
% Design variables definition
ns = 500; model.ns=ns;% number of candidate points
model.variables.ns=ns;
model.variables.dim=2;  % dimension number
model.ClassPos = [1,1,2];
obj_fct = @(x)ackley(x);     % Experimental function.Branin_G-[2,1,1] %一定要看一下哪一位是分类响应
model.total_iter = 50;       % Number of final sample points
model.n_init=30; % Number of initial sample points
model.dim=model.variables.dim;

rerun_num = 10;  %重复运行10
rsl=randperm(ns,rerun_num);
%% 重复运行多次取平均
for j=1:rerun_num  
% candidate_set+RefX_set+test_set
% rng default;  % 重置为MATLAB默认的初始状态
rs=rsl(j); model.rs=rs;  %random seed rng(rs)
rng(rs)
model=cand_gen(model,ns,'uniform');  %candidate samples原始
% model=cand_gen_ROI(model,rs);  %candidate samples关键区域
% model.testsample = makeEvalGrid({[0:0.01:1],[0:0.01:1]}); %global uncertainty predict(RefX_set)
% model.testset = makeEvalGrid({[0:0.012:1],[0:0.012:1]}); %performance test
model.testsample = lhsdesign(12000,model.variables.dim); %test
model.testset = lhsdesign(5000,model.variables.dim); %test
model.candidate0 = model.candidate;  %原始候选点集

% initial MMRGP model training
model.init_x = lhsdesign(model.n_init,model.dim);
model.init_value=obj_fct(model.init_x); 
ytest = obj_fct(model.testset);
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
modelSUR2wvarcs01{j} = model;
modelSUR2wvarcs02{j} = model;
% modelSUR2{j} = model;
% modelSUR2w{j} = model;
modelSUR2wvarc{j} = model;
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
    f_star = obj_fct(x_star);
    modelIMSE{j}.now_value=[modelIMSE{j}.now_value;f_star];
    modelIMSE{j}.now_x=[modelIMSE{j}.now_x;x_star];
    modelIMSE{j}.MMRGP = MMRGP0(modelIMSE{j}.now_value,modelIMSE{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelIMSE{j}.MMRGP,model.testset);  %计算预测误差 
    errorIMSE = error_func(ytest,ypred,model.ClassPos);         
    modelIMSE{j}.error{i} = errorIMSE;
end
% mSUR2wvarcs02 method %%%here%%%%
for i = 1:model.total_iter-model.n_init
    tic
    [x_star, modelSUR2wvarcs02{j}] = mSUR2w_varcs02(modelSUR2wvarcs02{j});
    toc
    f_star = obj_fct(x_star);
    modelSUR2wvarcs02{j}.now_value=[modelSUR2wvarcs02{j}.now_value;f_star];
    modelSUR2wvarcs02{j}.now_x=[modelSUR2wvarcs02{j}.now_x;x_star];
    modelSUR2wvarcs02{j}.MMRGP = MMRGP0(modelSUR2wvarcs02{j}.now_value,modelSUR2wvarcs02{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelSUR2wvarcs02{j}.MMRGP,model.testset);  %计算预测误差 
    errorSUR2wvarcs02 = error_func(ytest,ypred,model.ClassPos);         
    modelSUR2wvarcs02{j}.error{i} = errorSUR2wvarcs02;
end

% % mKMDT topsis方法   %%%here%%%%
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelmKMDT{j}] = mKMDT(modelmKMDT{j});
%     f_star = obj_fct(x_star);
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
    f_star = obj_fct(x_star);
    modelMVAS{j}.now_value=[modelMVAS{j}.now_value;f_star];
    modelMVAS{j}.now_x=[modelMVAS{j}.now_x;x_star];
    modelMVAS{j}.MMRGP = MMRGP0(modelMVAS{j}.now_value,modelMVAS{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelMVAS{j}.MMRGP,model.testset);  %计算预测误差 
    errorMVAS = error_func(ytest,ypred,model.ClassPos);         
    modelMVAS{j}.error{i} = errorMVAS;
end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%     关键区域采样    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % mROI_SURwvarc method 增加关键区域+加权采样+预测方差+U函数
% addpath('.\MS-PSO');  
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelROI_SURwvarc{j}] = mROI_SUR2w_varc(modelROI_SURwvarc{j},rs);
%     f_star = obj_fct(x_star);
%     modelROI_SURwvarc{j}.now_value=[modelROI_SURwvarc{j}.now_value;f_star];
%     modelROI_SURwvarc{j}.now_x=[modelROI_SURwvarc{j}.now_x;x_star];
%     modelROI_SURwvarc{j}.MMRGP = MMRGP(modelROI_SURwvarc{j}.now_value,modelROI_SURwvarc{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelROI_SURwvarc{j}.MMRGP,model.testset);  %计算预测误差 
%     errorROI_SURwvarc = error_func(ytest,ypred,model.ClassPos);         
%     modelROI_SURwvarc{j}.error{i} = errorROI_SURwvarc;
% end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%     分类响应采样    %%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% EIER method                
for i = 1:model.total_iter-model.n_init
    i
    [x_star, modelEIER{j}] = EIER(modelEIER{j});
    f_star = obj_fct(x_star);
    modelEIER{j}.now_value=[modelEIER{j}.now_value;f_star];
    modelEIER{j}.now_x=[modelEIER{j}.now_x;x_star];
    modelEIER{j}.MMRGP = MMRGP(modelEIER{j}.now_value,modelEIER{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelEIER{j}.MMRGP,model.testset);  %计算预测误差 
    errorEIER = error_func(ytest,ypred,model.ClassPos);         
    modelEIER{j}.error{i} = errorEIER;
end
end

