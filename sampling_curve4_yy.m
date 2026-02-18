%%%%%%%%%%%%%% 绘制采样曲线 %%%%%%%%%%%%%%
figure()  %这个代码可以画阴影
rerun_num=10;
% modelset={modelSUR2wvarc,modelSCF,modelSUR2wvar,modelSUR2wvarcs,modelROI_SURwvarc,modelIRS,modelIRS_SUR2wvarc}; %modelSUR_ROI2,modelSUR_ROI2wvarc
% modelset={modelSUR2wvarc,modelSCF,modelSUR2wvar,modelSUR2wvarcs,modelSUR2wvarcs2,modelSUR2wvarc2,modelSUR2wvarc3};
% modelmeanMSE{9}=modelIMSE{8};modelmaxMSE{9}=modelIMSE{8};
% modelset={modelSUR2wvarcs03,modelROI_SURwvarcs03,modelmeanMSE,modelmaxMSE,modelind,modelIMSE,modelEIER,modelMVAS}; %,modelmKMDT
% modelset={modelIMSE,modelmeanMSE,modelmaxMSE}; %,modelmKMDT
modelset={modelSUR2wvarcs03,modelSUR2wvarcs03_ori,modelSUR2wvarcs01,modelSUR2wvarcs03BVD};
for k=1:size(modelset,2)
    bigmodel=modelset{k};
for j=1:rerun_num
curvemodel =  bigmodel{j};
    for i=1:model.total_iter-model.n_init
    yRMAE(i,:) = curvemodel.error{i}{1};
    yMRSE(i,:) = curvemodel.error{i}{2};
    yMAPE(i,:) = curvemodel.error{i}{3};
    yACC(i,j) = curvemodel.error{i}{4};
    end
yRMAE1(:,j) = yRMAE(:,1);
yMRSE1(:,j) = yMRSE(:,1);
yMAPE1(:,j) = yMAPE(:,1);
yRMAE2(:,j) = yRMAE(:,2);
yMRSE2(:,j) = yMRSE(:,2);
yMAPE2(:,j) = yMAPE(:,2);
% yRMAE3(:,j) = yRMAE(:,3);
% yMRSE3(:,j) = yMRSE(:,3);
% yMAPE3(:,j) = yMAPE(:,3);
end
stdRMAE1 = std(yRMAE1, 0, 2); stdRMAE2 = std(yRMAE2, 0, 2); stdACC = std(yACC, 0, 2);
yRMAE1 = mean(yRMAE1,2);
yMRSE1 = mean(yMRSE1,2);
yMAPE1 = mean(yMAPE1,2);
yRMAE2 = mean(yRMAE2,2);
yMRSE2 = mean(yMRSE2,2);
yMAPE2 = mean(yMAPE2,2);

% yRMAE3 = mean(yRMAE3,2);
% yMRSE3 = mean(yMRSE3,2);
% yMAPE3 = mean(yMAPE3,2);
yACC = mean(yACC,2);
% result = [yRMAE1,yMRSE1,yRMAE2,yMRSE2,yMAPE1,yACC];
result = [yRMAE1,yRMAE2,yMRSE1,yMRSE2,yACC];
R(k,:)=result(end,:);
% 创建图形窗口，设置合适大小（单位：英寸）
% figure();  % 宽6in，高4.5in（符合多数期刊比例）
% 3. 线型配置（核心新增：为每条曲线分配唯一线型）
curve_linestyles = {'-',    % 实线（MEFUR）
                    '--',   % 虚线（MEFURori）
                    '-.',   % 点划线（MEFURBV）
                    ':'};   % 点线（onlyBVD）
% 绘制曲线，设置线条样式、颜色和宽度
% plot(1:2:i, yRMAE1(1:2:i), 'LineStyle', '-', 'LineWidth', 1.5);  % 蓝色实线
hold on;  % 保持当前图形，继续添加曲线
plot(1:i, yRMAE2, 'Color', curve_colors(k,:),'LineStyle', curve_linestyles{k}, 'LineWidth', 3);   % 红色虚线
% plot(1:i, yACC, 'Color', curve_colors(k,:),'LineStyle', curve_linestyles{k},'LineWidth', 3); % 紫色点划线

%绘制方差阴影
% 定义每条曲线的颜色（匹配图例，建议4种区分度高的颜色）
curve_colors = [0 0.447 0.741;    % 蓝色（MEFUR）
                0.85 0.333 0.1;   % 橙红色（MEFURori）
                0.466 0.674 0.188;  % 绿色（MEFURBV）
                0.494 0.184 0.556];% 紫色（onlyBVD）
 % 构建阴影的x和y坐标
rmae_mean= yRMAE2; rmae_std=stdRMAE2;
x_shade = [1:i, fliplr(1:i)]; % x轴坐标（往返）
y_shade = [[rmae_mean - rmae_std]', fliplr([rmae_mean + rmae_std]')]; % y轴坐标（下边界+上边界）
% 填充阴影区域
patch(x_shade, y_shade, curve_colors(k,:), ...
      'FaceAlpha', 0.2, ...  % 透明度（0-1，0.2既明显又不遮挡）
      'EdgeColor', 'none', ...
      'HandleVisibility', 'off');  % 无边界线
end
% plot(1:i, yMRSE1, 'LineStyle', '-', 'Color', [0 0.447 0.741], 'LineWidth', 1.5);  % 蓝色实线
% hold on;  % 保持当前图形，继续添加曲线
% plot(1:i, yMRSE2, 'LineStyle', '--', 'Color', [0.85 0.333 0.1], 'LineWidth', 1.5);   % 红色虚线
% % plot(1:i, yMAPE2, 'LineStyle', '-.', 'Color', [0.494 0.84 0.556], 'LineWidth', 1.5); % 紫色点划线
% plot(1:i, yACC, 'LineStyle', '-.', 'Color', [0.9 0.184 0.556], 'LineWidth', 1.5); % 紫色点划线

% plot(1:i, yMAPE1, 'LineStyle', '-', 'Color', [0 0.447 0.741], 'LineWidth', 1.5);  % 蓝色实线
% hold on;  % 保持当前图形，继续添加曲线
% plot(1:i, yMAPE2, 'LineStyle', '--', 'Color', [0.85 0.333 0.1], 'LineWidth', 1.5);   % 红色虚线
% % plot(1:i, yMAPE2, 'LineStyle', '-.', 'Color', [0.494 0.184 0.556], 'LineWidth', 1.5); % 紫色点划线
% plot(1:i, yACC, 'LineStyle', '-.', 'Color', [0.9 0.184 0.556], 'LineWidth', 1.5); % 紫色点划线

% 设置坐标轴范围（根据数据调整）
xlim([1 i]);
% ylim([-1.2 1.2]);

% 设置坐标轴刻度和标签，使用Times New Roman字体（学术常用）
set(gca, ...
    'FontName', 'Times New Roman', ...  % 字体
    'FontSize', 10, ...                 % 刻度字体大小
    'XTick', 1:1:i, ...                % x轴刻度
    'LineWidth', 1, ...                 % 坐标轴线条宽度
    'Box', 'on');                       % 显示坐标轴边框

% 坐标轴标签（加粗放大）
label_font_size=14;
xlabel('Sample Number', ...
       'FontName', 'Times New Roman', ...
       'FontSize', label_font_size, ...
       'FontWeight', 'bold');
ylabel('y2-RMAE', ...   % y1-RMAE  Accuracy
       'FontName', 'Times New Roman', ...
       'FontSize', label_font_size, ...
       'FontWeight', 'bold');
% xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');
% ylabel('Amplitude', 'FontName', 'Times New Roman', 'FontSize', 12, 'FontWeight', 'bold');

% 添加图例（位置在右上角，无边框，字体匹配）modelROI_SURwvarc,modelSUR2wvarcs2,modelSUR2wvarc2,modelSUR2wvarc3
modelSUR2wvarcs03,modelSUR2wvarcs03_ori,modelSUR2wvarcs01,modelSUR2wvarcs03BVD
% legend({'MEFUR','MEFUR-ROI','maxSE','MSE','SCF','IMSE','EIER','MVAS','mKMDT'}, ...
%     'Location', 'northwest', ...  % 位置：左上角
%     'FontName', 'Times New Roman', ...
%     'FontSize', 10, ...
%     'Box', 'off');  % 去除图例边框
legend({'MEFUR','MEFUR-nBVD','MEFUR-sBVD','onlyBVD'}, ...
    'Location', 'northwest', ...  % 位置：左上角
    'FontName', 'Times New Roman', ...
    'FontSize', 14, ...
    'Box', 'off');  % 去除图例边框


% 添加网格线（可选，视期刊要求）
grid on;
grid minor;  % 显示次要网格线
set(gca, 'GridLineStyle', ':');  % 网格线为虚线

