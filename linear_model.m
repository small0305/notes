function trafficlight = findFeasibleMediumTTS(freesp, wait, ctrlstep)

%% load data;
load F:\taoran\TTS\freespaceMat;
load F:\taoran\TTS\linkData;
load F:\taoran\TTS\capacity;
load D:\data_lyy\sNfMedium\data_res;
tic;
freespace = freespaceMat * freesp; % 将读出的数据转化为与linkData相对应的freesp


n = capacity - freespace; %车辆数


%% calculate A m
load D:\data_lyy\sNfMedium\m_A

% kk = 0.33; %车辆通过速率
% td = 3; %延时
% A = zeros(28,11);
% m = zeros(28,1);
% % n_next = A*greentime_1 + n + (others)
% % n_nextnext = A*greentime_2 + n_next + (others_2) = A*greentime_2 + A*greentime_1 + n + 2*(others_1) 
% for i = 1:28
%     node_from = linkData(i,1);
%     node_to = linkData(i,2);
%     is_NW = linkData(i,5);
% 
%     % upstream
%     if linkData(i,12)>0 %right-turn
%         m(i) = m(i) + kk*30;
%     end
%     if linkData(i,11)>0 %thru (g-td)*kk 
%         if is_NW % (60-green(node_from))-td)*kk
%             A(i,node_from) = -kk;
%             m(i) = m(i) + kk*(60-td);
%         else % (green(node_from))-td)*kk
%             A(i,node_from) = kk;
%             m(i) = m(i) - kk*td;
%         end
%     end
%     if linkData(i,10)>0 %left-turn (g-td)*kk
%         if is_NW
%             A(i,node_from) = A(i,node_from)+kk;
%             m(i) = m(i) - kk*td;
%         else
%             A(i,node_from) = A(i,node_from)-kk;
%             m(i) = m(i) + kk*(60-td);
%         end
%     end
% 
%     %downstream
%     if linkData(i,9)>0
%         m(i) = m(i)-kk*30;
%     end
%     if linkData(i,8)>0 %thru (g-td)*kk 
%         if is_NW % (60-green(node_from))-td)*kk
%             A(i,node_to) = kk;
%             m(i) = m(i) - kk*(60-td);
%         else % (green(node_from))-td)*kk
%             A(i,node_to) = -kk;
%             m(i) = m(i) + kk*td;
%         end
%     end
%     if linkData(i,7)>0 %left-turn (g-td)*kk
%         if is_NW
%             A(i,node_to) = A(i,node_to)+kk;
%             m(i) = m(i) - kk*(60-td);
%         else
%             A(i,node_to) = A(i,node_to)-kk;
%             m(i) = m(i) + kk*td;
%         end
%     end
% end
% save D:\data_lyy\sNfMedium\m_A m A

%% multi-step control
alpha = 0.8;
% index = [8 12 14 17 18 19];
index = [7,13,16,18,25,27];


A_ = [A,zeros(28,11),zeros(28,11);
    A,A,zeros(28,11);
    A,A,A];
b_ = alpha*[capacity;capacity;capacity]-[m+n;m*2+n;m*3+n];

lb = 15*ones(11*3, 1);
ub = 45*ones(11*3, 1);
Aeq = [];
beq = [];
obj = -ones(1, 28*3)*A_;
traf_0N = 30 * ones(33, 1);
% 
options = optimset('LargeScale', 'off');


% 所有3个周期 正常0.8



[traf, ~, exitflag] = linprog(obj, A_, b_, Aeq, beq, lb, ub, traf_0N, options); % A*x<=b
exit = 1;
for i=1:11
    if traf(i)>45
        traf(i) = 45;
    end
    if traf(i)<15
        traf(i) = 15;
    end
end


% 主干道3个周期，一般路段1个周期
if exitflag == -2
    A_2 = A_([1:28, index+28, index+56], :);
    b_2 = b_([1:28, index+28, index+56]);
    [traf_2, ~, exitflag] = linprog(obj, A_2, b_2, Aeq, beq, lb, ub, traf, options);
    exit=2;
    for i=1:11
        if traf_2(i)>45
            traf_2(i) = 45;
        end
        if traf_2(i)<15
            traf_2(i) = 15;
        end
    end
    traf = traf_2;
end


% 所有1个周期
if exitflag == -2
    A_3 = A_(1:28, :);
    b_3 = b_(1:28);
    [traf_3, ~, exitflag] = linprog(obj, A_3, b_3, Aeq, beq, lb, ub, traf_2, options);
    exit=3;
    for i=1:11
        if traf_3(i)>45
            traf_3(i) = 45;
        end
        if traf_3(i)<15
            traf_3(i) = 15;
        end
    end
    traf = traf_3;
end

% 主干道1个周期
if exitflag == -2
    exit = 4;
    A_4 = A_(index, :);
    b_4 = b_(index);
    [traf_4, ~, exitflag] = linprog(obj, A_4, b_4, Aeq, beq, lb, ub, traf_3, options);
    for i=1:11
        if traf_4(i)>45
            traf_4(i) = 45;
        end
        if traf_4(i)<15
            traf_4(i) = 15;
        end
    end
    traf = traf_4;
end

% 放松约束 
if exitflag == -2
    A_5 = A_;
    b_5 = 0.9*[capacity;capacity;capacity]-[m+n;m*2+n;m*3+n];
    [traf_5, ~, exitflag] = linprog(obj, A_5, b_5, Aeq, beq, lb, ub, traf, options);
    traf_5 = fmincon(@(x)size(find(A_*x-b_>0),1),traf_5,A_5,b_5,Aeq,beq,lb,ub);
    exit=5;
    for i=1:11
        if traf_5(i)>45
            traf_5(i) = 45;
        end
        if traf_5(i)<15
            traf_5(i) = 15;
        end
    end
    traf = traf_5;
end

if exitflag == -2
    exit = 6;
end

trafficlight = zeros(12, 11);
trafficlight(1:2, :) = [ 60-traf(1:11)';traf(1:11)'];
b = traf(1:11);

%% save the data

forecast = A*traf(1:11)+m+n;


% forecast = A*traf(1:11)+m+n+0.75*(freespace-pre_forecast)+0.5*(pre_freespace-prepre_forecast);
% 
% forecast_res = [forecast_res,forecast];
% freespace_res = [freespace_res,freespace];
% save D:\bs\Control\Newinterface_lyy_sNf_medium\mpc_matlab\2016\data_res freespace_res forecast_res;

a = toc;

% 
content_res = [content_res, (-freespace+capacity)./capacity];
time_res = [time_res,a];
light_res = [light_res,b];
freesp_res = [freesp_res,freesp];
TTS_res = [TTS_res,sum(n)];
save D:\data_lyy\sNfMedium\data_res content_res time_res light_res freesp_res TTS_res;

end
