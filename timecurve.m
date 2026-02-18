% 数据
sampleSize = [100:100:1000];
T = [196.3297	435.090148	662.7207583	855.8192058	1069.869219	1287.066671	1494.668788	1702.123108	1921.050029	2125.966503;
    147.1802	297.3397924	450.2157802	586.4024575	675.6367233	827.4021351	990.9176364	1080.396982	1232.027154	1284.760221];
% T = T(1:end); % 与 sampleSize 长度对齐

% 绘图
figure('Color','white');
% 1. 三角形标记：Marker设为^，调整大小和颜色
scatter(sampleSize, T(1,:), 50, 'k', 'Marker','^',...
     'MarkerEdgeColor','k','LineWidth',1,'MarkerFaceColor',[0.669 0.306 0.322]);
hold on;
% 2. 加粗虚线：LineWidth调整为2（原1.5）
h1 = plot(sampleSize, T(1,:), '-.','color',[0.8 0.2 0.1], 'LineWidth',2,'DisplayName', 'MEFUR');

hold on
scatter(sampleSize, T(2,:), 50, 'k', 'Marker','v', ...
     'MarkerEdgeColor','k','LineWidth',1,'MarkerFaceColor',[0.298 0.447 0.690]);
h2 = plot(sampleSize, T(2,:), '-.','color',[0.1 0.4 0.7], 'LineWidth',2,'DisplayName', 'MEFUR-ROI');

% 添加数据标签
for i = 1:length(sampleSize)
    text(sampleSize(i)-10, T(1,i)+20, sprintf('%.1f', T(1,i)), ...
        'VerticalAlignment','bottom', 'HorizontalAlignment','right', 'FontSize',10);
    text(sampleSize(i)-10, T(2,i)-40, sprintf('%.1f', T(2,i)), ...
        'VerticalAlignment','middle', 'HorizontalAlignment','right', 'FontSize',10);
end
set(gca, 'TickLength', [0.02, 0.02]);  % [x轴刻度长度, y轴刻度长度]，值为轴长的比例
% 设置坐标轴和标题
xlabel('Sample Size', 'FontWeight','bold', 'FontSize',12,'FontName', 'Times New Roman');
ylabel('T (s)', 'FontWeight','bold', 'FontSize',12,'FontName', 'Times New Roman');
xlim([0, 1000]);
ylim([0, 2500]);
set(gca, 'XTick',0:100:1000, 'YTick',0:250:2500);
grid on;
% 3. 背景网格改为实线：GridLineStyle设为-，调整透明度
set(gca, 'GridLineStyle','-', 'GridColor','k', 'GridAlpha',0.15);
box on;

% 4. 加粗外边框：LineWidth设为1.5（原默认1）
set(gca, 'LineWidth',1.5);

% 调整字体和样式
set(gca, 'FontName','Arial', 'FontSize',10);
% 图例文字颜色同步曲线配色（可选优化）
legend([h1,h2],'Location','northwest', 'Box','off', 'FontSize',12, 'FontName', 'Times New Roman');

% 5. 导出高质量图片（适合论文发表）
print(gcf, '-dpng', '-r600', 'Timecurve.jpg');  % 600dpi高清PNG
% 如需EPS矢量图（期刊常用），取消下面注释
print(gcf, '-depsc', '-r600', 'Timecurve.eps');