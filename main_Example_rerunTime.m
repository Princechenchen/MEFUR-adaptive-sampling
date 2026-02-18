%%%%%%%%%%%%%%%%%%%%%这个代码是统计时间的实验%%%%%%%%%%%%%%%%%%%%%
clear
addpath('./src'); addpath('./sampling_Funciton'); addpath('./testFunc'); addpath('.\grid');
% pyenv(Version="F:\tools\Python39\python.exe");
% Design variables definition
% ns = 100; model.ns=ns;% number of candidate points
% model.variables.ns=ns;
% model.variables.dim=2;  % dimension number
% model.ClassPos = [1,1,2];
obj_fct = @(x)Branin_G(x);     % Experimental function. 
% model.total_iter = 50;       % Number of final sample points
% model.n_init=30; % Number of initial sample points

% model.dim=model.variables.dim;

load('.\results\rec0120Ackley_expduibi2.mat')

rerun_num = 5;  %重复运行10 
% rsl=randperm(1000,rerun_num);
%% 重复运行多次取平均
for j=1:rerun_num  %第二轮
% rng(rs)
% candidate_set+RefX_set+test_set
% model.candidate = model.candidate0;
model = modelmemeroy{j};
rng(model.rs)
% initial MMRGP model training
ytest = obj_fct(model.testset);
model.ytestsample = obj_fct(model.testsample);
model.MMRGP = MMRGP0(model.init_value,model.init_x,model.ClassPos,model.dim);  
% MMRGP0(model.init_value,model.init_x,model.ClassPos,model.dim); 
% [y, s, model.MMRGP]=predict_resp(model.MMRGP,model.init_x);
% model.now_value =model.init_value; model.now_x=model.init_x;

% Comparison of Multiple methods
% modelSUR2wvar{j} = model;
% modelIMSE{j} = model;
% modelmaxMSE{j} = model;
% modelmeanMSE{j} = model;
% modelwmeanMSE{j} = model;
% modelwMSEGrad{j} = model;
% modelSUR{j} = model;
% modelSCF{j} = model;
% modelSUR2{j} = model;
% modelSUR2w{j} = model;
% modelSUR2wvar{j} = model;
% modelSUR2wvarc{j} = model;
% modelSUR2wvarcs{j} = model
% modelSUR2wvarcs01{j} = model;
% modelSUR2wvarcs0{j} = model;
% modelSUR2wvarcs02{j} = model;
modelSUR2wvarcs03{j} = model;
modelROI_SURwvarcs03{j} = model;  %龙志涛方法
% modelSUR2wvarcs03BVD{j} = model;
% modelSUR2wvarc3{j} = model;
% modelSUR2_sum{j} = model;
% modelSUR_ROI{j} = model;
% modelSUR_ROI2{j} = model;
% modelSUR_ROI2wvarc{j} = model;
% modelmKMDT{j} = model;
% modelMVAS{j} = model;
% modelIRS{j} = model;
% modelIRS_SUR2wvarc{j} = model;
% modelROI_SUR{j} = model;  %龙志涛方法
% modelROI_SURwvarc{j} = model;  %龙志涛方法
% modelROI_SURwvar{j} = model;  %龙志涛方法
% modelROI_SURwsum{j} = model;  %龙志涛方法
% modelIWPS{j} = model;
% modelUF{j} = model;
% modelEIER{j} = model;
% modelMELL{j} = model;
% modelMEZL{j} = model;
%
% %Start of computational time measurements for sequential sampling
%%%%%%%%%%%%%%%%%%%%%%%%%%%      多响应采样     %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mROI_SURwvarcs03 method 增加关键区域+加权采样+预测方差+U函数  ！！！要记得改关键区域生成样本的函数！！！
total_time1 =0;
addpath('.\MS-PSO');  
for i = 1:model.total_iter-model.n_init
    tic;
    [x_star, modelROI_SURwvarcs03{j}] = mROI_SUR2w_varcs03(modelROI_SURwvarcs03{j});
    iter_time = toc;
    total_time1 = total_time1 + iter_time;
    f_star = obj_fct(x_star);
    modelROI_SURwvarcs03{j}.now_value=[modelROI_SURwvarcs03{j}.now_value;f_star];
    modelROI_SURwvarcs03{j}.now_x=[modelROI_SURwvarcs03{j}.now_x;x_star];
    modelROI_SURwvarcs03{j}.MMRGP = MMRGP0(modelROI_SURwvarcs03{j}.now_value,modelROI_SURwvarcs03{j}.now_x,model.ClassPos,model.dim);
    [ypred]=predict_resp(modelROI_SURwvarcs03{j}.MMRGP,model.testset);  %计算预测误差 
    errorROI_SURwvarcs03 = error_func(ytest,ypred,model.ClassPos);         
    modelROI_SURwvarcs03{j}.error{i} = errorROI_SURwvarcs03;
end
alltotal_time1(j)=total_time1;
% % mSUR2wvarcs03_ori method  增加了权重和距离,增加样本点本身方差,增加了分类边界U函数偏好   %%%here%%%%
% total_time2 =0;
% for i = 1:model.total_iter-model.n_init
%     tic;
%     [x_star, modelSUR2wvarcs03{j}] = mSUR2w_varcs03(modelSUR2wvarcs03{j});
%     iter_time = toc;
%     total_time2 = total_time2 + iter_time;
%     f_star = obj_fct(x_star);
%     modelSUR2wvarcs03{j}.now_value=[modelSUR2wvarcs03{j}.now_value;f_star];
%     modelSUR2wvarcs03{j}.now_x=[modelSUR2wvarcs03{j}.now_x;x_star];
%     modelSUR2wvarcs03{j}.MMRGP = MMRGP0(modelSUR2wvarcs03{j}.now_value,modelSUR2wvarcs03{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2wvarcs03{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2wvarcs03 = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2wvarcs03{j}.error{i} = errorSUR2wvarcs03;
% end
% alltotal_time2(j)=total_time2;
% % mSUR2wvarcs03BVD method  增加了权重和距离,增加样本点本身方差,增加了分类边界U函数偏好   %%%here%%%%
% for i = 25:model.total_iter-model.n_init
%     [x_star, modelSUR2wvarcs03BVD{j}] = mSUR2w_varcs03BVD(modelSUR2wvarcs03BVD{j});
%     f_star = obj_fct(x_star);
%     modelSUR2wvarcs03BVD{j}.now_value=[modelSUR2wvarcs03BVD{j}.now_value;f_star];
%     modelSUR2wvarcs03BVD{j}.now_x=[modelSUR2wvarcs03BVD{j}.now_x;x_star];
%     modelSUR2wvarcs03BVD{j}.MMRGP = MMRGP0(modelSUR2wvarcs03BVD{j}.now_value,modelSUR2wvarcs03BVD{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2wvarcs03BVD{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2wvarcs03BVD = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2wvarcs03BVD{j}.error{i} = errorSUR2wvarcs03BVD;
% end
% % mSUR2wvarsy method  增加了权重和距离,增加样本点本身方差
% for i = 1:model.total_iter-model.n_init  %可以加个进度条
%     [x_star, modelSUR2wvarc3{j}] = mSUR2w_varc3(modelSUR2wvarc3{j});
%     f_star = obj_fct(x_star);
%     modelSUR2wvarc3{j}.now_value=[modelSUR2wvarc3{j}.now_value;f_star];
%     modelSUR2wvarc3{j}.now_x=[modelSUR2wvarc3{j}.now_x;x_star];
%     modelSUR2wvarc3{j}.MMRGP = MMRGP(modelSUR2wvarc3{j}.now_value,modelSUR2wvarc3{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2wvarc3{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2wvarc3 = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2wvarc3{j}.error{i} = errorSUR2wvarc3;
% end
% % mSUR2wvar method  增加了权重和距离,增加样本点本身方差
% for i = 1:model.total_iter-model.n_init  %可以加个进度条
%     [x_star, modelSUR2wvar{j}] = mSUR2w_var(modelSUR2wvar{j});
%     f_star = obj_fct(x_star);
%     modelSUR2wvar{j}.now_value=[modelSUR2wvar{j}.now_value;f_star];
%     modelSUR2wvar{j}.now_x=[modelSUR2wvar{j}.now_x;x_star];
%     modelSUR2wvar{j}.MMRGP = MMRGP(modelSUR2wvar{j}.now_value,modelSUR2wvar{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2wvar{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2wvar = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2wvar{j}.error{i} = errorSUR2wvar;
% end
% IMSE方法
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelIMSE{j}] = IMSE(modelIMSE{j});
%     f_star = obj_fct(x_star);
%     modelIMSE{j}.now_value=[modelIMSE{j}.now_value;f_star];
%     modelIMSE{j}.now_x=[modelIMSE{j}.now_x;x_star];
%     modelIMSE{j}.MMRGP = MMRGP(modelIMSE{j}.now_value,modelIMSE{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelIMSE{j}.MMRGP,model.testset);  %计算预测误差 
%     errorIMSE = error_func(ytest,ypred,model.ClassPos);         
%     modelIMSE{j}.error{i} = errorIMSE;
% end
% % IWPS方法
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelIWPS{j}] = IWPS(modelIWPS{j});
%     f_star = obj_fct(x_star);
%     modelIWPS{j}.now_value=[modelIWPS{j}.now_value;f_star];
%     modelIWPS{j}.now_x=[modelIWPS{j}.now_x;x_star];
%     modelIWPS{j}.MMRGP = MMRGP(modelIWPS{j}.now_value,modelIWPS{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelIWPS{j}.MMRGP,model.testset);  %计算预测误差 
%     errorIWPS = error_func(ytest,ypred,model.ClassPos);         
%     modelIWPS{j}.error{i} = errorIWPS;
% end
% % IRS_SUR2wvarc方法
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelIRS_SUR2wvarc{j}] = mIRS_SUR2wvarc(modelIRS_SUR2wvarc{j},obj_fct);
%     f_star = obj_fct(x_star);
%     modelIRS_SUR2wvarc{j}.now_value=[modelIRS_SUR2wvarc{j}.now_value;f_star];
%     modelIRS_SUR2wvarc{j}.now_x=[modelIRS_SUR2wvarc{j}.now_x;x_star];
%     modelIRS_SUR2wvarc{j}.MMRGP = MMRGP(modelIRS_SUR2wvarc{j}.now_value,modelIRS_SUR2wvarc{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelIRS_SUR2wvarc{j}.MMRGP,model.testset);  %计算预测误差 
%     errorIRS_SUR2wvarc = error_func(ytest,ypred,model.ClassPos);         
%     modelIRS_SUR2wvarc{j}.error{i} = errorIRS_SUR2wvarc;
% end
% % AK_MCS_IRS方法  %here
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelIRS{j}] = AK_MCS_IRS(modelIRS{j},obj_fct);
%     f_star = obj_fct(x_star);
%     modelIRS{j}.now_value=[modelIRS{j}.now_value;f_star];
%     modelIRS{j}.now_x=[modelIRS{j}.now_x;x_star];
%     modelIRS{j}.MMRGP = MMRGP(modelIRS{j}.now_value,modelIRS{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelIRS{j}.MMRGP,model.testset);  %计算预测误差 
%     errorIRS = error_func(ytest,ypred,model.ClassPos);         
%     modelIRS{j}.error{i} = errorIRS;
% end
% % MVAS topsis方法
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelMVAS{j}] = MVAS(modelMVAS{j});
%     f_star = obj_fct(x_star);
%     modelMVAS{j}.now_value=[modelMVAS{j}.now_value;f_star];
%     modelMVAS{j}.now_x=[modelMVAS{j}.now_x;x_star];
%     modelMVAS{j}.MMRGP = MMRGP(modelMVAS{j}.now_value,modelMVAS{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelMVAS{j}.MMRGP,model.testset);  %计算预测误差 
%     errorMVAS = error_func(ytest,ypred,model.ClassPos);         
%     modelMVAS{j}.error{i} = errorMVAS;
% end
% % mKMDT topsis方法
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelmKMDT{j}] = mKMDT(modelmKMDT{j});
%     f_star = obj_fct(x_star);
%     modelmKMDT{j}.now_value=[modelmKMDT{j}.now_value;f_star];
%     modelmKMDT{j}.now_x=[modelmKMDT{j}.now_x;x_star];
%     modelmKMDT{j}.MMRGP = MMRGP(modelmKMDT{j}.now_value,modelmKMDT{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelmKMDT{j}.MMRGP,model.testset);  %计算预测误差 
%     errormKMDT = error_func(ytest,ypred,model.ClassPos);         
%     modelmKMDT{j}.error{i} = errormKMDT;
% end
% % mSUR2wvarc method  增加了权重和距离,增加样本点本身方差
% for i = 1:model.total_iter-model.n_init  %可以加个进度条
%     [x_star, modelSUR2wvarc{j}] = mSUR2w_varc(modelSUR2wvarc{j});
%     f_star = obj_fct(x_star);
%     modelSUR2wvarc{j}.now_value=[modelSUR2wvarc{j}.now_value;f_star];
%     modelSUR2wvarc{j}.now_x=[modelSUR2wvarc{j}.now_x;x_star];
%     modelSUR2wvarc{j}.MMRGP = MMRGP(modelSUR2wvarc{j}.now_value,modelSUR2wvarc{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2wvarc{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2wvarc = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2wvarc{j}.error{i} = errorSUR2wvarc;
% end
% % mROI_SURwvarc method 增加关键区域+加权采样 改关键区域参数   %%要重跑
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
% % mROI_SURwvar method 增加关键区域+加权采样 改关键区域参数   %%到这里了
% addpath('.\MS-PSO');  
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelROI_SURwvar{j}] = mROI_SUR2w_var(modelROI_SURwvar{j},rs);
%     f_star = obj_fct(x_star);
%     modelROI_SURwvar{j}.now_value=[modelROI_SURwvar{j}.now_value;f_star];
%     modelROI_SURwvar{j}.now_x=[modelROI_SURwvar{j}.now_x;x_star];
%     modelROI_SURwvar{j}.MMRGP = MMRGP(modelROI_SURwvar{j}.now_value,modelROI_SURwvar{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelROI_SURwvar{j}.MMRGP,model.testset);  %计算预测误差 
%     errorROI_SURwvar = error_func(ytest,ypred,model.ClassPos);         
%     modelROI_SURwvar{j}.error{i} = errorROI_SURwvar;
% end
% % maxMSE method
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelmaxMSE{j}] = maxMSE(modelmaxMSE{j});
%     f_star = obj_fct(x_star);
%     modelmaxMSE{j}.now_value=[modelmaxMSE{j}.now_value;f_star];
%     modelmaxMSE{j}.now_x=[modelmaxMSE{j}.now_x;x_star];
%     modelmaxMSE{j}.MMRGP = MMRGP(modelmaxMSE{j}.now_value,modelmaxMSE{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelmaxMSE{j}.MMRGP,model.testset);  %计算预测误差 
%     errormaxMSE = error_func(ytest,ypred,model.ClassPos);         
%     modelmaxMSE{j}.error{i} = errormaxMSE;
% end
% % mMSE method
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelmeanMSE{j}] = meanMSE(modelmeanMSE{j});
%     f_star = obj_fct(x_star);
%     modelmeanMSE{j}.now_value=[modelmeanMSE{j}.now_value;f_star];
%     modelmeanMSE{j}.now_x=[modelmeanMSE{j}.now_x;x_star];
%     modelmeanMSE{j}.MMRGP = MMRGP(modelmeanMSE{j}.now_value,modelmeanMSE{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelmeanMSE{j}.MMRGP,model.testset);  %计算预测误差 
%     errormeanMSE = error_func(ytest,ypred,model.ClassPos);         
%     modelmeanMSE{j}.error{i} = errormeanMSE;
% end
% % wmMSE method
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelwmeanMSE{j}] = wmeanMSE(modelwmeanMSE{j});
%     f_star = obj_fct(x_star);
%     modelwmeanMSE{j}.now_value=[modelwmeanMSE{j}.now_value;f_star];
%     modelwmeanMSE{j}.now_x=[modelwmeanMSE{j}.now_x;x_star];
%     modelwmeanMSE{j}.MMRGP = MMRGP(modelwmeanMSE{j}.now_value,modelwmeanMSE{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelwmeanMSE{j}.MMRGP,model.testset);  %计算预测误差 
%     errorwmeanMSE = error_func(ytest,ypred,model.ClassPos);         
%     modelwmeanMSE{j}.error{i} = errorwmeanMSE;
% end
% % SCF meth4od
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelSCF{j}] = SCF(modelSCF{j});
%     f_star = obj_fct(x_star);
%     modelSCF{j}.now_value=[modelSCF{j}.now_value;f_star];
%     modelSCF{j}.now_x=[modelSCF{j}.now_x;x_star];
%     modelSCF{j}.MMRGP = MMRGP(modelSCF{j}.now_value,modelSCF{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSCF{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSCF = error_func(ytest,ypred,model.ClassPos);         
%     modelSCF{j}.error{i} = errorSCF;
% end
% % wMSEGrad method
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelwMSEGrad{j}] = wMSEGrad(modelwMSEGrad{j});
%     f_star = obj_fct(x_star);
%     modelwMSEGrad{j}.now_value=[modelwMSEGrad{j}.now_value;f_star];
%     modelwMSEGrad{j}.now_x=[modelwMSEGrad{j}.now_x;x_star];
%     modelwMSEGrad{j}.MMRGP = MMRGP(modelwMSEGrad{j}.now_value,modelwMSEGrad{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelwMSEGrad{j}.MMRGP,model.testset);  %计算预测误差 
%     errorwMSEGrad = error_func(ytest,ypred,model.ClassPos);         
%     modelwMSEGrad{j}.error{i} = errorwMSEGrad;
% end
% % mSUR method
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelSUR{j}] = mSUR(modelSUR{j});
%     f_star = obj_fct(x_star);
%     modelSUR{j}.now_value=[modelSUR{j}.now_value;f_star];
%     modelSUR{j}.now_x=[modelSUR{j}.now_x;x_star];
%     modelSUR{j}.MMRGP = MMRGP(modelSUR{j}.now_value,modelSUR{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR{j}.error{i} = errorSUR;
% end
% % mSUR2 method **good** 增加了均值不确定性的计算
% for i = 1:model.total_iter-model.n_init  %可以加个进度条
%     [x_star, modelSUR2{j}] = mSUR2(modelSUR2{j});
%     f_star = obj_fct(x_star);
%     modelSUR2{j}.now_value=[modelSUR2{j}.now_value;f_star];
%     modelSUR2{j}.now_x=[modelSUR2{j}.now_x;x_star];
%     modelSUR2{j}.MMRGP = MMRGP(modelSUR2{j}.now_value,modelSUR2{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2 = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2{j}.error{i} = errorSUR2;
% end
% % mSUR2w method  增加了权重和距离  
% for i = 1:model.total_iter-model.n_init  %可以加个进度条
%     [x_star, modelSUR2w{j}] = mSUR2w(modelSUR2w{j});
%     f_star = obj_fct(x_star);
%     modelSUR2w{j}.now_value=[modelSUR2w{j}.now_value;f_star];
%     modelSUR2w{j}.now_x=[modelSUR2w{j}.now_x;x_star];
%     modelSUR2w{j}.MMRGP = MMRGP(modelSUR2w{j}.now_value,modelSUR2w{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2w{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2w = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2w{j}.error{i} = errorSUR2w;
% end
% % mSUR2_sum method 协方差矩阵求和 %到这了
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelSUR2_sum{j}] = mSUR2_sum(modelSUR2_sum{j});
%     f_star = obj_fct(x_star);
%     modelSUR2_sum{j}.now_value=[modelSUR2_sum{j}.now_value;f_star];
%     modelSUR2_sum{j}.now_x=[modelSUR2_sum{j}.now_x;x_star];
%     modelSUR2_sum{j}.MMRGP = MMRGP(modelSUR2_sum{j}.now_value,modelSUR2_sum{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR2_sum{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR2_sum = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR2_sum{j}.error{i} = errorSUR2_sum;
% end
% % mROI_SURw method 增加关键区域+加权采样
% addpath('.\MS-PSO');  
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelROI_SURw{j}] = mROI_SUR2w(modelROI_SURw{j},rs);
%     f_star = obj_fct(x_star);
%     modelROI_SURw{j}.now_value=[modelROI_SURw{j}.now_value;f_star];
%     modelROI_SURw{j}.now_x=[modelROI_SURw{j}.now_x;x_star];
%     modelROI_SURw{j}.MMRGP = MMRGP(modelROI_SURw{j}.now_value,modelROI_SURw{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelROI_SURw{j}.MMRGP,model.testset);  %计算预测误差 
%     errorROI_SURw = error_func(ytest,ypred,model.ClassPos);         
%     modelROI_SURw{j}.error{i} = errorROI_SURw;
% end
% % mROI_SURwsum method 增加关键区域+加权采样+协方差矩阵求和
% addpath('.\MS-PSO');
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelROI_SURwsum{j}] = mROI_SUR2wsum(modelROI_SURwsum{j},rs);
%     f_star = obj_fct(x_star);
%     modelROI_SURwsum{j}.now_value=[modelROI_SURwsum{j}.now_value;f_star];
%     modelROI_SURwsum{j}.now_x=[modelROI_SURwsum{j}.now_x;x_star];
%     modelROI_SURwsum{j}.MMRGP = MMRGP(modelROI_SURwsum{j}.now_value,modelROI_SURwsum{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelROI_SURwsum{j}.MMRGP,model.testset);  %计算预测误差 
%     errorROI_SURwsum = error_func(ytest,ypred,model.ClassPos);         
%     modelROI_SURwsum{j}.error{i} = errorROI_SURwsum;
% end
% % mROI_SUR method 增加关键区域  
% % modelROI_SUR.candidate=gen_ROI(model,model.ns,rs);  %candidate samples关键区域
% % modelROI_SUR.ROItestset=gen_ROI(model,size(model.testset,1),rs); %x
% addpath('.\MS-PSO');
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelROI_SUR{j}] = mROI_SUR2(modelROI_SUR{j},rs);
%     f_star = obj_fct(x_star);
%     modelROI_SUR{j}.now_value=[modelROI_SUR{j}.now_value;f_star];
%     modelROI_SUR{j}.now_x=[modelROI_SUR{j}.now_x;x_star];
%     modelROI_SUR{j}.MMRGP = MMRGP(modelROI_SUR{j}.now_value,modelROI_SUR{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelROI_SUR{j}.MMRGP,model.testset);  %计算预测误差 
%     errorROI_SUR = error_func(ytest,ypred,model.ClassPos);         
%     modelROI_SUR{j}.error{i} = errorROI_SUR;
% end

% % mSUR_ROI method 增加关键区域  对分类准确率损失太大
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelSUR_ROI{j}] = mSUR_ROI(modelSUR_ROI{j});
%     f_star = obj_fct(x_star);
%     modelSUR_ROI{j}.now_value=[modelSUR_ROI{j}.now_value;f_star];
%     modelSUR_ROI{j}.now_x=[modelSUR_ROI{j}.now_x;x_star];
%     modelSUR_ROI{j}.MMRGP = MMRGP(modelSUR_ROI{j}.now_value,modelSUR_ROI{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR_ROI{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR_ROI = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR_ROI{j}.error{i} = errorSUR_ROI;
% end
% % mSUR_ROI2 method 增加关键区域  对分类准确率损失太大 关键区域误差归一化求和综合
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelSUR_ROI2{j}] = mSUR_ROI2(modelSUR_ROI2{j});
%     f_star = obj_fct(x_star);
%     modelSUR_ROI2{j}.now_value=[modelSUR_ROI2{j}.now_value;f_star];
%     modelSUR_ROI2{j}.now_x=[modelSUR_ROI2{j}.now_x;x_star];
%     modelSUR_ROI2{j}.MMRGP = MMRGP(modelSUR_ROI2{j}.now_value,modelSUR_ROI2{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR_ROI2{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR_ROI2 = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR_ROI2{j}.error{i} = errorSUR_ROI2;
% end
% % mSUR_ROI2wvarc method 增加关键区域  对分类准确率损失太大 关键区域误差归一化求和综合  %%here  3-10重新跑
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelSUR_ROI2wvarc{j}] = mSUR_ROI2wvarc(modelSUR_ROI2wvarc{j});
%     f_star = obj_fct(x_star);
%     modelSUR_ROI2wvarc{j}.now_value=[modelSUR_ROI2wvarc{j}.now_value;f_star];
%     modelSUR_ROI2wvarc{j}.now_x=[modelSUR_ROI2wvarc{j}.now_x;x_star];
%     modelSUR_ROI2wvarc{j}.MMRGP = MMRGP(modelSUR_ROI2wvarc{j}.now_value,modelSUR_ROI2wvarc{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelSUR_ROI2wvarc{j}.MMRGP,model.testset);  %计算预测误差 
%     errorSUR_ROI2wvarc = error_func(ytest,ypred,model.ClassPos);         
%     modelSUR_ROI2wvarc{j}.error{i} = errorSUR_ROI2wvarc;
% end
% 
% % U函数 method
% for i = 1:model.total_iter-model.n_init
%     [x_star, modelUF{j}] = UFunction(modelUF{j});
%     f_star = obj_fct(x_star);
%     modelUF{j}.now_value=[modelUF{j}.now_value;f_star];
%     modelUF{j}.now_x=[modelUF{j}.now_x;x_star];
%     modelUF{j}.MMRGP = MMRGP(modelUF{j}.now_value,modelUF{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelUF{j}.MMRGP,model.testset);  %计算预测误差 
%     errorUF = error_func(ytest,ypred,model.ClassPos);         
%     modelUF{j}.error{i} = errorUF;
% end
% % EIER method
% for i = 1:model.total_iter-model.n_init
%     i
%     [x_star, modelEIER{j}] = EIER(modelEIER{j});
%     f_star = obj_fct(x_star);
%     modelEIER{j}.now_value=[modelEIER{j}.now_value;f_star];
%     modelEIER{j}.now_x=[modelEIER{j}.now_x;x_star];
%     modelEIER{j}.MMRGP = MMRGP(modelEIER{j}.now_value,modelEIER{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelEIER{j}.MMRGP,model.testset);  %计算预测误差 
%     errorEIER = error_func(ytest,ypred,model.ClassPos);         
%     modelEIER{j}.error{i} = errorEIER;
% end
% % MELL method & MEZL method
% addpath('F:\学习工作\搞点研究\混合响应序贯采样\新建文件夹\sampling\baseline');
% for i = 1:model.total_iter-model.n_init
%     i  %该方法直接将所选样本与原样本合并输出
%     [x_star, Y_selected,MELLaccuracy, selectedind,modelMELL{j}] =  MELL_MEZL(modelMELL{j},ytest,obj_fct,'MELL');
%     f_star = obj_fct(x_star);
%     modelMELL{j}.now_value=f_star;
%     modelMELL{j}.now_x = x_star;
%     modelMELL{j}.MMRGP = MMRGP(modelMELL{j}.now_value,modelMELL{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelMELL{j}.MMRGP,model.testset);  %计算预测误差 
%     errorMELL = error_func(ytest,ypred,model.ClassPos);         
%     modelMELL{j}.error{i} = errorMELL;
% end
% for i = 1:model.total_iter-model.n_init
%     i
%     [x_star, Y_selected,MEZLaccuracy, selectedind,modelMEZL{j}] =  MELL_MEZL(modelMEZL{j},ytest,obj_fct,'MEZL');
%     f_star = obj_fct(x_star);
%     modelMEZL{j}.now_value=f_star;
%     modelMEZL{j}.now_x = x_star;
%     modelMEZL{j}.MMRGP = MMRGP(modelMEZL{j}.now_value,modelMEZL{j}.now_x,model.ClassPos,model.dim);
%     [ypred]=predict_resp(modelMEZL{j}.MMRGP,model.testset);  %计算预测误差 
%     errorMEZL = error_func(ytest,ypred,model.ClassPos);         
%     modelMEZL{j}.error{i} = errorMEZL;
% end
end

% % performance comparation
% addpath('./src');
% [ypred]=predict_resp(model.MMRGP,model.testset);
% error = error_func(ytest,ypred,model.ClassPos);         %预测误差
% [ypred]=predict_resp(modelmaxMSE.MMRGP,model.testset);
% errormaxMSE = error_func(ytest,ypred,model.ClassPos);         %预测误差
% [ypred]=predict_resp(modelmeanMSE.MMRGP,model.testset);
% errormeanMSEE = error_func(ytest,ypred,model.ClassPos);         %预测误差
% [ypred]=predict_resp(modelwmeanMSE.MMRGP,model.testset);
% errorwmeanMSE = error_func(ytest,ypred,model.ClassPos);         %预测误差
% [ypred]=predict_resp(modelSCF.MMRGP,model.testset);
% errorSCF = error_func(ytest,ypred,model.ClassPos);         %预测误差
% [ypred]=predict_resp(modelwMSEGrad.MMRGP,model.testset);
% errorwMSEGrad = error_func(ytest,ypred,model.ClassPos);         %预测误差
% [ypred]=predict_resp(modelSUR.MMRGP,model.testset);
% errorSUR = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
% [ypred,s]=predict_resp(modelSUR2.MMRGP,model.testset);
% errorSUR2 = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
% [ypred,s]=predict_resp(modelSUR_ROI.MMRGP,model.testset);
% errorSUR_ROI = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
% [ypred,s]=predict_resp(modelSUR_ROI2.MMRGP,model.testset);
% errorSUR_ROI2 = error_func(ytest,ypred,model.ClassPos); 
% [ypred]=predict_resp(modelEIER.MMRGP,model.testset);
% errorEIER = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
% [ypred]=predict_resp(modelUF.MMRGP,model.testset);
% errorUF = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
% [ypred,s]=predict_resp(modelSUR2_uniq.MMRGP,model.testset);
% errorSUR2_uniq = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
% [ypred,s]=predict_resp(modelSUR2_sum.MMRGP,model.testset);
% errorSUR2_sum = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
% [ypred,s]=predict_resp(modelROI_SUR.MMRGP,model.testset);
% errorROI_SUR = error_func(ytest,ypred,model.ClassPos);         %预测误差 %距离加权且误差加权
%%
% 
% SUR2wmodel = MMRGP(modelSUR2w.now_value(1:24,:),modelSUR2w.now_x(1:24,:),modelSUR2w.ClassPos,modelSUR2w.dim);
% [ypred]=predict_resp(SUR2wmodel,model.testset);  %计算预测误差 
% error = error_func(ytest,ypred,model.ClassPos)  
% SUR2wmodel2 = MMRGP(modelSUR2w.now_value(1:27,:),modelSUR2w.now_x(1:27,:),modelSUR2w.ClassPos,modelSUR2w.dim);
% [ypred]=predict_resp(SUR2wmodel2,model.testset);  %计算预测误差 
% error = error_func(ytest,ypred,model.ClassPos) 
% 
% SUR2_summodel = MMRGP(modelSUR2_sum.now_value,modelSUR2_sum.now_x,modelSUR2_sum.ClassPos,modelSUR2_sum.dim);
% [ypred]=predict_resp(SUR2_summodel,model.testset);  %计算预测误差 
% error = error_func(ytest,ypred,model.ClassPos)
