%%%%%%%%%%%%%% 绘制采样曲线（终极兼容版+局部放大图） %%%%%%%%%%%%%%
% clearvars -except modelset model % 清理变量，保留必要的输入变量
% close all; clc;

% LaTeX文档常用页面尺寸：A4(210×297mm) / 美国信纸(8.5×11英寸)
% 单栏图：宽度≤8.5cm(3.35英寸)，双栏图：宽度≤17cm(6.69英寸)
% 黄金比例：宽高比=1.618（或期刊常用4:3/5:3）
fig_width = 6.5;    % 图宽（英寸）- 适配LaTeX双栏（≤6.69英寸）
fig_height = 4.0;   % 图高（英寸）- 宽高比≈1.625（接近黄金比例）
dpi = 300;          % 导出分辨率（LaTeX矢量图+高分辨率兼容）

% ------------- 1. 基础参数设置（加粗/放大版） -------------
rerun_num = 10;  % 重复运行次数
modelset = {modelSUR2wvarcs03,modelROI_SURwvarcs03,modelmeanMSE,modelmaxMSE,modelind,modelIMSE,modelEIER,modelMVAS};%,modelmKMDT
model_names = {'MEFUR','MEFUR-ROI','maxSE','MSE','SCF','IMSE','EIER','MVAS'}; % 模型名称（与modelset对应）,'mKMDT'

% 专业配色（9种distinct颜色）
color_palette = [0.00 0.45 0.74;  % 蓝色
                 0.85 0.33 0.10;  % 橙红色
                 0.47 0.67 0.19;  % 橄榄绿
                 0.49 0.18 0.56;  % 紫红色
                 0.31 0.74 0.61;  % 青绿色
                 0.93 0.69 0.13;  % 金黄色
                 0.82 0.10 0.21;  % 深红色
                 0.92 0.5 0.72;  % 深紫色
                 0.20 0.63 0.79]; % 天蓝色

% 线条样式（避免重复）
line_styles = {'-', '--', '-.', ':', '-', '--', '-.', ':', '-'}; 
% 曲线标记（9种不同标记，增强辨识度）
markers = {'o', 's', '^', 'd', 'v', 'p', '*', 'h', '+'};

% 加粗/放大参数（比原版大一号）
line_width = 3.0;       % 线条宽度（原1.5→2.0）
tick_font_size = 18;    % 刻度字体（原10→12）
label_font_size = 20;   % 坐标轴标签（原12→14）
legend_font_size = 16;  % 图例字体（原9→11）
axis_line_width = 2;  % 坐标轴宽度（原1→1.5）
tick_length = [0.015 0.015]; % 刻度长度（原0.02→0.03）
tick_interval = 5;      % 刻度显示间隔，避免拥挤
%%%%%%%%% 新增：局部放大图参数（统一格式，与主图匹配） %%%%%%%%%
zoom_x1 = 10; zoom_x2 = 20;  % 要放大的X轴范围（核心！20-30）
zoom_tick_font = 12;        % 放大图刻度字体
zoom_label_font = 14;       % 放大图坐标轴标签
zoom_line_width = 2;        % 放大图线条/坐标轴宽度
zoom_marker_size = 4;       % 放大图标记大小
zoom_axes_pos = [0.42, 0.46, 0.45, 0.44]; % 放大图位置[左,下,宽,高]（归一化）
main_highlight_pos = [0.625, 0.12, 0.28, 0.25]; % 主图高亮框位置（归一化）
%%%%%%%%% 结束 %%%%%%%%%

% ------------- 2. 创建图形窗口 -------------
fig_position = 0.9*[100, 100, 900, 700]; % [x,y,width,height]（像素）
fig_width_px = fig_position(3);          % 提取宽度（像素）
fig_height_px = fig_position(4);         % 提取高度（像素）
% 像素转英寸（MATLAB默认96DPI）
dpi_matlab = 96;
fig_width_in = fig_width_px / dpi_matlab-0.55;
fig_height_in = fig_height_px / dpi_matlab;
% 创建图窗，匹配PaperSize
fig = figure(...
    'Position', fig_position, ...         % 原有像素单位的Position
    'Units', 'pixels', ...                % 明确Position单位为像素
    'PaperUnits', 'inches', ...           % PaperSize单位为英寸
    'PaperSize', [fig_width_in, fig_height_in], ... % 像素转英寸后匹配
    'PaperPositionMode', 'auto', ...
    'Color', 'white');

ax = axes('Parent', fig); 
hold(ax, 'on'); 
%%%%%%%%% 新增：创建局部放大图的坐标轴 + 主图高亮框 %%%%%%%%%
% 1. 创建放大图坐标轴（归一化单位，与主图同窗口）
ax_zoom = axes('Parent', fig, 'Position', zoom_axes_pos, 'Units', 'normalized');
hold(ax_zoom, 'on');
% 2. 主图绘制高亮框（标记20-30的放大区域，红色虚线）
annotation(fig, 'rectangle', main_highlight_pos, 'EdgeColor', [1 0 0], ...
    'LineStyle', '--', 'LineWidth', 3, 'Color', [0.8 0 0]);
%%%%%%%%% 结束 %%%%%%%%%

% ------------- 3. 数据处理与绘图（添加标记） -------------
% %%%%%%%%% 新增：预定义存储变量（保存主图线条对象，用于复制到放大图） %%%%%%%%%
h_lines = cell(1, length(modelset)); 
% %%%%%%%%% 结束 %%%%%%%%%
for k = 1:length(modelset)
    bigmodel = modelset{k};
    % 初始化每个模型的存储变量
    yRMAE1 = []; yMRSE1 = []; yMAPE1 = [];
    yRMAE2 = []; yMRSE2 = []; yMAPE2 = [];
    yACC = [];
    
    for j = 1:rerun_num
        curvemodel = bigmodel{j};
        iter_num = model.total_iter - model.n_init-10; % 迭代次数
        % 初始化单次运行的变量
        temp_RMAE = zeros(iter_num, size(curvemodel.error{1}{1},2));
        temp_MRSE = zeros(iter_num, size(curvemodel.error{1}{2},2));
        temp_MAPE = zeros(iter_num, size(curvemodel.error{1}{3},2));
        temp_ACC = zeros(iter_num, 1);
        
        for i = 1:iter_num
            temp_RMAE(i,:) = curvemodel.error{i+10}{1};
            temp_MRSE(i,:) = curvemodel.error{i+10}{2};
            temp_MAPE(i,:) = curvemodel.error{i+10}{3};
            temp_ACC(i) = curvemodel.error{i+10}{4};
        end
        
        % 存储单次运行结果
        yRMAE1(:,j) = temp_RMAE(:,1);
        yMRSE1(:,j) = temp_MRSE(:,1);
        yMAPE1(:,j) = temp_MAPE(:,1);
        yRMAE2(:,j) = temp_RMAE(:,2);
        yMRSE2(:,j) = temp_MRSE(:,2);
        yMAPE2(:,j) = temp_MAPE(:,2);
        yACC(:,j) = temp_ACC;
    end
    
    % 计算多次运行的均值
    yRMAE1 = mean(yRMAE1,2);
    yMRSE1 = mean(yMRSE1,2);
    yMAPE1 = mean(yMAPE1,2);
    yRMAE2 = mean(yRMAE2,2);
    yMRSE2 = mean(yMRSE2,2);
    yMAPE2 = mean(yMAPE2,2);
    yACC = mean(yACC, 2);
    % 生成X轴数据
    x_data = 1:iter_num;

    % 绘制带标记的ACC曲线（完全兼容低版本MATLAB）
    h_lines{k} = plot(ax, x_data, yRMAE1, ...           % 保存线条对象到h_lines
         'Color', color_palette(k,:), ...
         'LineWidth', line_width, ...
         'Marker', markers{k}, ...              % 添加标记
         'MarkerSize', 6, ...                  % 标记大小
         'MarkerFaceColor', color_palette(k,:),...% 标记填充色
         'DisplayName', model_names{k});
    %%%%%%%%% 新增：绘制局部放大图曲线（与主图同配色/标记/样式，匹配20-30范围） %%%%%%%%%
    plot(ax_zoom, x_data, yRMAE1, ...
         'Color', color_palette(k,:), ...
         'LineWidth', zoom_line_width, ...
         'Marker', markers{k}, ...
         'MarkerSize', zoom_marker_size, ...
         'MarkerFaceColor', color_palette(k,:));
    %%%%%%%%% 结束 %%%%%%%%%
end

% ------------- 4. 图形美化（完全兼容版） -------------
% 坐标轴核心设置（刻度朝内）- 仅保留所有版本通用的属性
set(ax, ...
    'FontName', 'Times New Roman', ...    % 学术期刊标准字体
    'FontSize', tick_font_size, ...       % 刻度字体更协调
    'LineWidth', axis_line_width, ...     % 坐标轴宽度更精致
    'Box', 'on', ...                      % 显示边框
    'XMinorTick', 'off', ...              % 关闭次要刻度，更简洁
    'YMinorTick', 'off', ...              % 关闭次要刻度，避免杂乱
    'TickDir', 'in', ...                  % 刻度朝内
    'TickLength', tick_length, ...        % 刻度长度缩短，更美观
    'XTick', 0:tick_interval:iter_num);   % 设置x轴刻度间隔，避免拥挤

% 坐标轴标签（加粗放大）
xlabel(ax, 'Sample Number', ...
       'FontName', 'Times New Roman', ...
       'FontSize', label_font_size, ...
       'FontWeight', 'bold');
ylabel(ax, 'y1-RMAE', ...   % RMAE  Accuracy
       'FontName', 'Times New Roman', ...
       'FontSize', label_font_size, ...
       'FontWeight', 'bold');

% 图例设置（完全兼容低版本MATLAB）
lgd = legend(ax, model_names, ...  % 显式指定图例标签（元胞数组）
             'Location', 'southwest', ...
             'FontName', 'Times New Roman', ...
             'FontSize', legend_font_size, ...
             'Box', 'off', ...              % 无边框
             'TextColor', [0.1 0.1 0.1]);

% 网格设置（仅保留所有版本通用的属性）
grid(ax, 'on');
grid(ax, 'minor');
set(ax, 'GridLineStyle', ':', ...
    'GridAlpha', 0.4, ...                % 网格透明度（所有版本支持）
    'MinorGridLineStyle', ':', ...
    'MinorGridAlpha', 0.2);

% 背景色（浅灰更专业）
set(ax, 'Color', [0.98 0.98 0.98]);
set(fig, 'Color', 'white');

%%%%%%%%% 核心新增：局部放大图美化+范围限制（关键修改区） %%%%%%%%%
% 1. 限制放大图的X/Y轴范围（X轴强制20-30，Y轴自适应主图该区间数据）
x_zoom_idx = x_data >= zoom_x1 & x_data <= zoom_x2; % 提取20-30的索引
y_zoom_min = 0.165%min(min(cell2mat(arrayfun(@(k) h_lines{k}.YData(x_zoom_idx), 1:length(h_lines), 'UniformOutput', false))));
y_zoom_max = 0.21%max(max(cell2mat(arrayfun(@(k) h_lines{k}.YData(x_zoom_idx), 1:length(h_lines), 'UniformOutput', false))));
y_zoom_margin = (y_zoom_max - y_zoom_min) * 0.1; % 留10%边距，避免贴边
xlim(ax_zoom, [zoom_x1, zoom_x2]);
ylim(ax_zoom, [y_zoom_min - y_zoom_margin, y_zoom_max + y_zoom_margin]);

% 2. 放大图坐标轴核心设置（与主图风格统一，刻度朝内）
set(ax_zoom, ...
    'FontName', 'Times New Roman', ...
    'FontSize', zoom_tick_font, ...
    'LineWidth', zoom_line_width, ...
    'Box', 'on', ...
    'TickDir', 'in', ...
    'XTick', zoom_x1:2:zoom_x2, ... % 放大图X刻度间隔2，更清晰
    'YMinorTick', 'off', ...
    'XMinorTick', 'off');

% 3. 放大图坐标轴标签（加粗，与主图一致）
% xlabel(ax_zoom, 'Sample Number', 'FontName', 'Times New Roman', ...
%        'FontSize', zoom_label_font, 'FontWeight', 'bold');
% ylabel(ax_zoom, 'y1-RMAE', 'FontName', 'Times New Roman', ...
%        'FontSize', zoom_label_font, 'FontWeight', 'bold');

% 4. 放大图网格+背景（与主图同风格，透明度稍高）
grid(ax_zoom, 'on');
set(ax_zoom, 'GridLineStyle', ':', 'GridAlpha', 0.5, 'Color', [0.98 0.98 0.98]);

% 5. 画主图高亮框到放大图的指引线（2条，连接对应区域，红色虚线）
annotation(fig, 'line', [main_highlight_pos(1)+main_highlight_pos(3), zoom_axes_pos(1)+zoom_axes_pos(3)], ...
    [main_highlight_pos(2)+main_highlight_pos(4), zoom_axes_pos(2)], ...
    'LineStyle', '-', 'LineWidth', 2, 'Color', [0.8 0 0]);
annotation(fig, 'line', [main_highlight_pos(1), zoom_axes_pos(1)], ...
    [main_highlight_pos(2)+main_highlight_pos(4), zoom_axes_pos(2)], ...
    'LineStyle', '-', 'LineWidth', 2, 'Color', [0.8 0 0]);
%%%%%%%%% 局部放大图修改结束 %%%%%%%%%

% ------------- 5. 导出高质量图片 -------------
% print(fig, 'Ackely_y1', '-dpdf', '-r300'); % PDF矢量图
% print(fig, 'sampling_curve_ultimate', '-dtiff', '-r600'); % TIFF高分辨率
% print(fig, 'Ackely_y1', '-depsc', '-r300'); % EPS（LaTeX用）