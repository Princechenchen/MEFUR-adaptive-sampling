function z_mn = define_covmatrix0(model, X1, X2)
% 优化后的多输出高斯过程协方差矩阵计算
% 使用 Kronecker积 替代双重循环，大幅提升计算速度

    % 获取维度信息
    A = model.hyper.A;
    [num_output, m] = size(A); % num_output: 输出维度, m: 潜函数个数
    N1 = size(X1, 1);
    N2 = size(X2, 1);
    
    % 初始化最终的大协方差矩阵
    z_mn = zeros(N1 * num_output, N2 * num_output);
    
    % LMC 核心逻辑: Z = Sum_k ( L_k (kron) (a_k * a_k') )
    % 其中 L_k 是第 k 个潜函数的协方差矩阵，a_k 是混合矩阵 A 的第 k 列
    for k = 1:m
        % 1. 计算第 k 个潜函数的空间/时间协方差矩阵 (N1 x N2)
        Lk = model.cov_model(model.hyper.teta(k,:), X1, X2);
        
        % 2. 计算第 k 个潜函数的共区域化矩阵 (Coregionalization Matrix) B_k
        % B_k = a_k * a_k' (大小为 num_output x num_output)
        ak = A(:, k);
        Bk = ak * ak';
        
        % 3. 利用 Kronecker 积累加到总矩阵中
        % kron(Lk, Bk) 会生成块矩阵，这也符合原始代码的排列顺序
        z_mn = z_mn + kron(Lk, Bk);
    end

    % 如果是自协方差矩阵 (X1 == X2)，进行对称化和正则化处理
    if isequal(X1, X2)
        % 强制对称 (比 triu 方法更快且同样有效)
        z_mn = (z_mn + z_mn') / 2;
        
        % 特征值分解与重构 (用于保证正定性 PSD)
        % 注意: eig 对于大矩阵非常耗时。
        % 如果矩阵规模很大且不需要严格截断，建议直接使用 z_mn = z_mn + eye(size(z_mn))*1e-6;
        
        [V, D] = eig(z_mn); % 'vector' 标志直接返回特征值向量 (Matlab R2015b+)
        D = diag(D);
        % 设定阈值
        d = max(D, 0.001); 
        
        % 优化重构过程: 把矩阵乘法 V*diag(d)*V' 转化为基于广播的乘法
        % 计算 V * (d .* V') 能够减少稀疏矩阵乘法的开销
        z_mn = V * (d .* V'); 
        
        % 再次确保实数性 (防止 eig 产生微小的虚部)
        z_mn = real(z_mn);
    end

end
% function z_mn = define_covmatrix0(model, X1, X2)
% % 进阶优化版：无显式i/j循环，完全向量化，效率最优
% % 输入输出与基础优化版一致
% 
% n1 = size(X1, 1);
% n2 = size(X2, 1);
% m = model.m;
% A = model.hyper.A;
% A_T = A';
% 
% % 步骤1：预计算核张量L
% L = zeros(n1, n2, m);
% for i = 1:m
%     L(:, :, i) = model.cov_model(model.hyper.teta(i, :), X1, X2);
% end
% 
% % 步骤2：张量重塑与向量化构造分块协方差
% % 将L重塑为 (n1*n2) × m 矩阵，每行对应L(i,j,:)
% L_reshaped = reshape(permute(L, [1,2,3]), n1*n2, m);
% 
% % 构造每个(i,j)对应的m×m协方差矩阵，存储为 (m,m,n1,n2) 张量
% cov_tensor = zeros(m, m, n1, n2);
% for k = 1:n1*n2
%     [i, j] = ind2sub([n1, n2], k); % 索引转换：线性索引→二维索引
%     cov_tensor(:, :, i, j) = A * diag(L_reshaped(k, :)) * A_T;
% end
% 
% % 步骤3：将4维协方差张量重塑为最终的(n1*m)×(n2*m)矩阵
% z_mn = reshape(permute(cov_tensor, [1,3,2,4]), n1*m, n2*m);
% 
% % 步骤4：对称矩阵修正
% if isequal(X1, X2)
%     z_mn = triu(z_mn) + triu(z_mn)' - diag(diag(z_mn));
%     [V, D] = eig(z_mn);
%     d = diag(D);
%     d(d <= 1e-3) = 1e-3;
%     z_mn = V * diag(d) * V';
% end
% 
% end