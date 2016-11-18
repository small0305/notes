function trafficlight = findFeasibleMediumTTS(freesp, wait,ctrlstep)
% freesp = freespace;
% wait = waiting;
% ctrlstep = 1;
%%
% clear
% clc
% load data
tic;
load freespaceMat;
load linkData;
load inputLinkData;
load capacity;
load turnIn;
load capacity0;
load D:\bs\Control\Newinterface_lyy_sNf_medium\mpc_matlab\2016\data_res;
load D:\data_lyy\sNfMedium\data_res;

% 修正capacity
capacity = capacity - capacity0;
miu_l = 0.35;
miu_t = 0.35;
% miu_input = 1000/3600;
freespace = freespaceMat * freesp; % 将读出的数据转化为与linkData相对应的freesp
step = size(forecast_res,2);
pre_forecast = freespace;
prepre_forecast = freespace;
pre_freespace = freespace;
if mod(step,91)>1
    pre_forecast = forecast_res(:,step);
    prepre_forecast = forecast_res(:,step-1);
    pre_freespace = freespace_res(:,step);
end
%%
A = zeros(28, 22); % 28roads, 11nodes*2
c = zeros(28, 1);

for i=1:28
    up = linkData(i, 1);
    dn = linkData(i, 2);
    % left
    flag = 1;
    upLeftRoad = turnIn(i, 2); % 1, 2, 3 -> thru, left, right
    % upLeftDirect 0, 1 ->EW走向, NS走向
    if upLeftRoad >= 100    % 外围输入
        upLeftDirect = inputLinkData(upLeftRoad-100, 5);
    elseif upLeftRoad == 0  % 无左转路口
        flag = 0;
    else
        upLeftDirect = linkData(upLeftRoad, 5);
    end
    if flag
        if upLeftDirect == 0
            A(i, up) = A(i, up) - miu_l;    % ?
            % 在处理上游路段时同时处理了下游路段，却没考虑到输出到
            % 外围的路段需要对矩阵A进行改动
            if upLeftRoad < 100
                A(upLeftRoad, up) = A(upLeftRoad, up) + miu_l;
            end
        else
            A(i, up+11) = A(i, up+11) - miu_l;
            if upLeftRoad < 100
                A(upLeftRoad, up+11) = A(upLeftRoad, up+11) + miu_l;
            end
        end
    end
    
    flag = 1;
    upThruRoad = turnIn(i, 1); % 1, 2, 3 -> thru, left, right
    if upThruRoad >= 100
        upThruDirect = inputLinkData(upThruRoad-100, 5);
    elseif upThruRoad == 0
        flag = 0;
    else
        upThruDirect = linkData(upThruRoad, 5);
    end
    if flag
        if upThruDirect == 0
            A(i, up) = A(i, up) - miu_t;
            if upThruRoad < 100
                A(upThruRoad, up) = A(upThruRoad, up) + miu_t;
            end
        else % 前11个表示相位1，后11个表示相位2
            A(i, up+11) = A(i, up+11) - miu_t;
            if upThruRoad < 100
                A(upThruRoad, up+11) = A(upThruRoad, up+11) + miu_t;
            end
        end
    end
    
    flag = 1;
    upRightRoad = turnIn(i, 3); % 1, 2, 3 -> thru, left, right
    if upRightRoad >= 100
        upRightPos = inputLinkData(upRightRoad-100, 6);
        c(i) = c(i) - (wait(upRightPos, 3) + 10);
    elseif upRightRoad == 0
        flag = 0;
    else
        upRightPos = linkData(upRightRoad, 6);
        c(i) = c(i) - (wait(upRightPos, 3) + 10);
        c(upRightRoad) = c(upRightRoad) + (wait(upRightPos, 3) + 10);
    end
%     upRightPos 
end

% 输出到外围的路段单独进行处理
A(1, 1) = A(1, 1) + miu_t; A(2, 1+11) = A(2, 1+11) + miu_l;
A(3, 2) = A(3, 2) + miu_l; c(4) = c(4) + (wait(linkData(4, 6), 3) + 10); A(5, 2+11) = A(5, 2+11) + miu_t;
A(6, 3) = A(6, 3) + miu_l + miu_t; A(7, 3+11) = A(7, 3+11) + miu_l; c(7) = c(7) + (wait(linkData(7, 6), 3) + 10);
A(8, 4) = A(8, 4) + miu_t; A(9, 4+11) = A(9, 4+11) + miu_l; c(10) = c(10) + (wait(linkData(10, 6), 3) + 10);
A(19, 7) = A(19, 7) + miu_t; c(20) = c(20) + (wait(linkData(20, 6), 3) + 10);
A(21, 8+11) = A(21, 8+11) + miu_t; c(21) = c(21) + (wait(linkData(21, 6), 3) + 10); A(22, 8) = A(22, 8) + miu_t + miu_l;
c(23) = c(23) + (wait(linkData(23, 6), 3) + 10);
A(25, 10+11) = A(25, 10+11) + miu_t; A(26, 10) = A(26, 10) + miu_l;
A(27, 10) = A(27, 10) + miu_l;
% A(19, 7) = miu_t;

%%%%%%%%%%%%%%%%%%%%
b = capacity * (1-0.75);
%%%%%%%%%%%%%%%%%%%
traf_0 = 30 * ones(22, 1);
% if mod(step,91)>0
%     traf_0 = light_res(:,step);
% end
% inHigh = 35;
% inLow = 25;
% inMid = 30;
% traf_0(1) = inHigh;  traf_0(1+11) = 60-traf_0(1);
% traf_0(2) = inLow;   traf_0(2+11) = 60-traf_0(2);
% traf_0(3) = inMid;   traf_0(3+11) = 60-traf_0(3);
% traf_0(4) = inHigh;  traf_0(4+11) = 60-traf_0(4);
% traf_0(5) = inHigh;  traf_0(5+11) = 60-traf_0(5);
% traf_0(6) = inHigh;  traf_0(6+11) = 60-traf_0(6);
% traf_0(7) = inHigh;  traf_0(7+11) = 60-traf_0(7);
% traf_0(8) = inMid;   traf_0(8+11) = 60-traf_0(8);
% traf_0(9) = inLow;   traf_0(9+11) = 60-traf_0(9);
% traf_0(10) = inLow;  traf_0(10+11) = 60-traf_0(10);
% traf_0(11) = inHigh; traf_0(11+11) = 60-traf_0(11);
N = 3; % 预测周期
% % 后面几个周期设定为有利于外围输入
traf_0N = [];
for i = 1:N
    traf_0N = [traf_0N; traf_0];
end

% % 后面几个周期设定为 30 30
% traf_0N = traf_0;
% traf_1 = 30 * ones(22, 1);
% for i = 1:N-1
%     traf_0N = [traf_0N; traf_1];
% end

%% 多部预测部分
Atem = [];
A_ = [];
b_ = [];
Aeq = [];
for i = 1:N
    Atem = [Atem A];
    A_ = [A_ zeros(size(A_,1), size(A, 2))];
    A_ = [A_; Atem];
%     size(A_)
    b_ = [b_; b - c - freespace-0.75*(freespace-pre_forecast)-0.5*(pre_freespace-prepre_forecast)];
end
AeqTem = [diag(diag(ones(11))) diag(diag(ones(11)))];
Aeq = blkdiag(AeqTem, AeqTem, AeqTem);
beq = 60 * ones(11*N, 1);
%%%%%%%%
lb = 15*ones(22*N, 1);
ub = 45*ones(22*N, 1);
%%%%%%%%

% % 单步预测部分
% b_ = b - c - freespace;
% Aeq = [diag(diag(ones(11))) diag(diag(ones(11)))];
% beq = 60 * ones(11, 1);
% lb = 15*ones(22, 1);
% ub = 45*ones(22, 1);

% obj = zeros(22, 1);
% options = optimset('LargeScale', 'off');
% [traf, ~, exitflag] = linprog(obj, -A, -b_, Aeq, beq, lb, ub, traf_0, options);

% % 多步预测部分
index = [8 12 14 17 18 19];
% obj = zeros(22*N, 1);
obj = -ones(1, 28*N)*A_;

% control_index = [4 5 6 7];
% ones_index = zeros(1, 28*N);
% for i = 0:2*N-1
%     ones_index(control_index + i*11) = 1;
% end
% obj = -ones_index * A_;

options = optimset('LargeScale', 'off');
[traf, ~, exitflag] = linprog(obj, -A_, -b_, Aeq, beq, lb, ub, traf_0N, options);
exit=1;
% 主干道3个周期，一般路段1个周期
if exitflag == -2
    A_2 = A_([1:28, index+28, index+56], :);
    b_2 = b_([1:28, index+28, index+56]);
    [traf_2, ~, exitflag] = linprog(obj, -A_2, -b_2, Aeq, beq, lb, ub, traf, options);
    exit=2;
    traf = traf_2;
end
% 所有1个周期
if exitflag == -2
    A_3 = A_(1:28, :);
    b_3 = b_(1:28);
    [traf_3, ~, exitflag] = linprog(obj, -A_3, -b_3, Aeq, beq, lb, ub, traf, options);
    exit=3;
    traf = traf_3;
end

% 主干道1个周期
if exitflag == -2
    exit = 4;
    A_4 = A_(index, :);
    b_4 = b_(index);
    [traf_4, ~, exitflag] = linprog(obj, -A_4, -b_4, Aeq, beq, lb, ub, traf, options);
    traf = traf_4;
end

if exitflag == -2
    exit = 5;
end
% % 放松约束
% if exitflag == -2
%     A_5 = A_(1:28, :);
%     b_5 = capacity - i*c - freespace;
%     b_5 = b_5(1:28);
%     [traf_5, ~, exitflag] = linprog(obj, -A_5, -b_5, Aeq, beq, lb, ub, traf_3, options);
%     for i=1:11
%         if traf_5(i)>45
%             traf_5(i) = 45;
%             traf_5(i+11) = 15;
%         end
%         if traf_5(i)<15
%             traf_5(i) = 15;
%             traf_5(i+11) = 45;
%         end
%     end
%     traf = traf_5;
% end
% 加强约束


if exit==1
    non_index = [1 2 3 4 5 6 7 9 10 11 13 15 16 20 21 22 23 24 25 26 27 28];
    obj = -ones(1, 22)*A_(non_index,:);
    [traf_0, ~, exitflag] = linprog(obj, -A_, -b_, Aeq, beq, lb, ub, traf, options);
    if exitflag ~= -2
        exit = 0;
        traf = traf_0;
    end
end
trafficlight = zeros(12, 11);
trafficlight(1:2, :) = [traf(1:11)'; traf(12:22)'];
b = traf(1:11);
% satisfy_un = (A_*traf>=b_);
% satisfy_un_N = [satisfy_un(1:28) satisfy_un(29:56) satisfy_un(57:end)];
% satisfy_ = [Aeq*traf, beq];
%% save the data
forecast = A*traf(1:22)+freespace+0.75*(freespace-pre_forecast)+0.5*(pre_freespace-prepre_forecast)+c;
% forecast = A*traf(1:22)+freespace+c;

% forecast = A*traf(1:22)+freespace+0.5*(freespace-pre_forecast)+0.25*(pre_freespace-prepre_forecast)+c;
forecast_res = [forecast_res,forecast];
freespace_res = [freespace_res,freespace];
save D:\bs\Control\Newinterface_lyy_sNf_medium\mpc_matlab\2016\data_res freespace_res forecast_res;

a = toc;


content_res = [content_res, (-freespace+capacity)./capacity];
time_res = [time_res,a];
light_res = [light_res,trafficlight(1:11)];
freesp_res = [freesp_res,freesp];
wait_res = [wait_res,wait];
% 
save D:\data_lyy\sNfMedium\data_res content_res time_res light_res freesp_res wait_res;
% save D:\data_lyy\sNfMedium\data_res light_res
end
