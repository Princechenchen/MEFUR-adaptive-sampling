%% 清理工作区，设置路径
close all
clc
load('results\recBranin.mat')

% 添加路径（使用统一的路径分隔符）
addpath('./src'); 
addpath('./sampling_Funciton'); 
addpath('./testFunc'); 
addpath('./grid');
addpath('./MRSM_subprograms0');

% 保存路径和函数名
savepath = '.\绘图0119'; % 替换为您想保存的路径
functioname = 'Branin_G'; 
obj_fct = @(x)Branin_G(x); 

% ====================== 学术绘图风格全局设置 ======================
% % 设置为论文级别的绘图参数（调整基础字号）
% set(0, 'DefaultFigurePosition', 0.2*[100, 100, 600, 500]);  % 【修改1】整体图形基础尺寸缩小
set(0, 'DefaultFigureColor', 'white');                 % 背景色为白色
set(0, 'DefaultAxesFontName', 'Times New Roman');      % 字体统一为Times New Roman
set(0, 'DefaultTextFontName', 'Times New Roman');      % 文本字体
set(0, 'DefaultAxesFontSize', 16);                     % 【修改2】基础坐标轴字号增大
set(0, 'DefaultTextFontSize', 16);                     % 【修改3】基础文本字号增大
set(0, 'DefaultLineLineWidth', 2.0);                   % 线条宽度
set(0, 'DefaultFigureVisible', 'on');                  % 显示图形

% ====================== 文件夹创建 ======================
% 创建主文件夹
subFolderPath = fullfile(savepath, functioname);
if ~exist(subFolderPath, 'dir')
    mkdir(subFolderPath);
    fprintf('文件夹创建成功: %s\n', subFolderPath);
else
    fprintf('文件夹已存在: %s\n', subFolderPath);
end

% ====================== 数据准备 ======================
% 请确保model变量已正确定义
% load('zuhui30.mat')
% 【临时测试用】如果没有model变量，先定义基础结构避免报错
n = model.n_init;  % 初始样本数
m = model.total_iter;  % 总迭代次数

% 生成高密度网格（提高分辨率）
resolution = 0.005;  % 提高分辨率，使等高线更平滑
range = 0:resolution:1;
range1 = 0:resolution:1;
X0 = makeEvalGrid({range, range1});  % 生成2D网格
F0 = obj_fct(X0);  % 计算真实函数值

% 模型设置（临时测试用，实际请替换为您的真实模型）
modelset = {modelSUR2wvarcs03, modelROI_SURwvarcs03, modelind, modelEIER};
modelname = {'MEFUR', 'MEFUR-ROI', 'SCF', 'EIER'};

% ====================== 绘图主循环 ======================
for j = 1:length(modelset)
    draw_model = modelset{j};    
    mxmodel = draw_model{1}.MMRGP;
    x = draw_model{1}.now_x;
    
    % 模型预测（临时测试用）
    % 实际请替换为predict_resp(mxmodel, X0)
    Y = predict_resp(mxmodel, X0);
    % 重塑网格数据用于绘图
    X1 = reshape(X0(:,1), length(range1), length(range));
    X2 = reshape(X0(:,2), length(range1), length(range));
    
    % 为每个输出维度绘图
    for k = 1:size(Y, 2)
        % 创建模型专属文件夹
        modelFolder = fullfile(subFolderPath, modelname{j});
        if ~exist(modelFolder, 'dir')
            mkdir(modelFolder);
            fprintf('创建模型文件夹: %s\n', modelFolder);
        end
        
        % ====================== 2. 预测函数等高线图（带采样点） ======================
%         fig2 = figure('Position', [100, 100, 600, 500]);  % 【修改13】预测图整体尺寸缩小
        fig_position = [100, 100, 650, 500]; % [x,y,width,height]（像素）
        fig_width_px = fig_position(3);          % 提取宽度（像素）
        fig_height_px = fig_position(4);         % 提取高度（像素）
        % 像素转英寸（MATLAB默认96DPI）
        dpi_matlab = 96;
        fig_width_in = fig_width_px / dpi_matlab-0.2;
        fig_height_in = fig_height_px / dpi_matlab-0.1;
        % 创建图窗，匹配PaperSize
        fig2 = figure(...
            'Position', fig_position, ...         % 原有像素单位的Position
            'Units', 'pixels', ...                % 明确Position单位为像素
            'PaperUnits', 'inches', ...           % PaperSize单位为英寸
            'PaperSize', [fig_width_in, fig_height_in], ... % 像素转英寸后匹配
            'PaperPositionMode', 'auto', ...
            'Color', 'white');
        ax2 = axes('Parent', fig2);
        
        % 绘制预测等高线
        Y_levels = linspace(min(Y(:,k)), max(Y(:,k)), 30);
        contourf(ax2, X1, X2, reshape(Y(:,k), size(X1)), Y_levels, 'LineStyle', 'none');
        colormap(ax2, parula);
        shading interp;
        
        % 添加采样点
        hold(ax2, 'on');
        % 【修改14】初始样本点尺寸增大（80→120）
        scatter(ax2, x(1:n,1), x(1:n,2), 80, 'r', 'filled', ...
            'MarkerEdgeColor', 'k', 'LineWidth', 1.5);
        % 【修改15】迭代样本点尺寸增大（100→140），线条加粗
        scatter(ax2, x(n+1:end,1), x(n+1:end,2), 100, 'r', 'Marker', '+', ...
            'LineWidth', 3.0);
        
        % 图形美化设置
        xlabel(ax2, '$x_1$', 'Interpreter', 'Latex', 'FontSize', 20);  % 【修改16】X轴标签字号增大（18→24）
        ylabel(ax2, '$x_2$', 'Interpreter', 'Latex', 'FontSize', 20);  % 【修改17】Y轴标签字号增大（18→24）

        % 颜色条设置
        cb2 = colorbar(ax2);
        cb2.Label.FontSize = 16;  % 【修改18】颜色条标签字号增大（18→24）
%         cb2.TickLabelFontSize = 20;  % 【新增】颜色条刻度字号
        
        % 坐标轴设置
        ax2.LineWidth = 1.5;  % 【修改19】坐标轴线条加粗
        ax2.Box = 'on';
        ax2.TickDir = 'in';
        ax2.TickLength = [0.02, 0.02];  % 【修改20】刻度长度增加
%         ax2.TickLabelFontSize = 22;  % 【修改21】坐标轴刻度字号增大
%         axis(ax2, 'equal');
        grid(ax2, 'off');
        
        % 图例
%         legend(ax2, {'Predicted Surface','Initial Samples', 'Iterative Samples'}, ...
%             'FontSize', 30, 'Box', 'off');  % 【修改22】图例字号增大（10→18）
        
        % 保存图片
        filename2 = sprintf('%s_%d_p.eps', modelname{j}, k);
        savepath2 = fullfile(modelFolder, filename2);
        print(fig2, savepath2, '-dpdf', '-r300');
        fprintf('保存图片: %s\n', savepath2);
        
        % 关闭当前图形以释放内存
        close(fig2);
    end
end
 %% ====================== 1. 原始函数等高线图（带采样点） ======================
%     fig1 = figure('Position', [100, 100, 600, 500]); % 【保持】整体图片缩小
for k = 1:size(Y, 2)    
Y = F0; 
    fig_position = [100, 100, 650, 500]; % [x,y,width,height]（像素）
    fig_width_px = fig_position(3);          % 提取宽度（像素）
    fig_height_px = fig_position(4);         % 提取高度（像素）
    % 像素转英寸（MATLAB默认96DPI）
    dpi_matlab = 96;
    fig_width_in = fig_width_px / dpi_matlab-0.2;
    fig_height_in = fig_height_px / dpi_matlab-0.1;
    % 创建图窗，匹配PaperSize
    fig1 = figure(...
        'Position', fig_position, ...         % 原有像素单位的Position
        'Units', 'pixels', ...                % 明确Position单位为像素
        'PaperUnits', 'inches', ...           % PaperSize单位为英寸
        'PaperSize', [fig_width_in, fig_height_in], ... % 像素转英寸后匹配
        'PaperPositionMode', 'auto', ...
        'Color', 'white');
    ax1 = axes('Parent', fig1);
        
    % 绘制填充等高线（使用专业配色）
    levels = linspace(min(F0(:,k)), max(F0(:,k)), 30);  % 30个等高线层级，更平滑
    contourf(ax1, X1, X2, reshape(F0(:,k), size(X1)), levels, 'LineStyle', 'none');
    colormap(ax1, parula);  % 使用MATLAB专业配色parula（优于jet）
    shading interp;  % 插值着色，更平滑
    
    % 添加采样点
    hold(ax1, 'on');
    % 【修改4】初始样本点尺寸增大（从80→120）
    scatter(ax1, x(1:n,1), x(1:n,2), 80, 'r', 'filled', ...
        'MarkerEdgeColor', 'k', 'LineWidth', 1.5);  % 【修改5】边框宽度增大
    
    % 图形美化设置
    xlabel(ax1, '$x_1$', 'Interpreter', 'Latex', 'FontSize', 20);  % 【修改6】X轴标签字号增大（26→32）
    ylabel(ax1, '$x_2$', 'Interpreter', 'Latex', 'FontSize', 20);  % 【修改7】Y轴标签字号增大（26→32）

    % 调整颜色条
    cb1 = colorbar(ax1);
    cb1.Label.FontSize = 16;  % 【修改8】颜色条标签字号增大（26→32）
%         cb1.TickLabelFontSize = 24;  % 【新增】颜色条刻度字号
    
    % 调整坐标轴
    ax1.LineWidth = 1.5;  % 【修改9】坐标轴线条加粗
    ax1.Box = 'on';  % 显示边框
    ax1.TickDir = 'in';  % 刻度向内
    ax1.TickLength = [0.02, 0.02];  % 【修改10】刻度长度增加
%         ax1.TickLabelFontSize = 28;  % 【修改11】坐标轴刻度字号增大
%     axis(ax1, 'equal');  % 等比例坐标轴
    grid(ax1, 'off');    % 关闭网格
    
    % 添加图例
%     legend(ax1, {'Function Surface','Initial Samples'}, ...
%         'FontSize', 30, 'Box', 'off');  % 【修改12】图例字号增大（24→30）
   % 关键设置：让PDF页面适配图形大小
    set(fig1, 'PaperPositionMode', 'auto');  % 自动匹配图形大小
    set(fig1, 'InvertHardcopy', 'off');     % 避免背景色反转
    % 保存图片（高分辨率）
    filename1 = sprintf('Function_o_%d.eps',k);
    savepath1 = fullfile(modelFolder, filename1);
    print(fig1, savepath1, '-dpdf', '-r300');  % 600DPI高分辨率
    fprintf('保存图片: %s\n', savepath1);
    
    close(fig1);
end
% ====================== 恢复默认设置 ======================
set(0, 'DefaultFigureVisible', 'on');
fprintf('\n所有图形绘制完成并保存！\n');