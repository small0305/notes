function trafficlight = findFeasibleMediumTTS(freesp, wait, ctrlstep)

links_num = 28;
nodes_num = 11;

green_linear = adaptive(freesp,wait);
trafficlight = green_linear;

x = green_linear(1,:)';
lb = 15*ones(nodes_num,1);
ub = 45*ones(nodes_num,1);
x = [x;x;x];
lb = [lb;lb;lb];
ub = [ub;ub;ub];
res = fmincon(@(x)objective(x,freesp,wait),x,[],[],[],[],lb,ub);
res = res(1:11);

trafficlight(1:2, :) = [res'; (60.-res)'];

end



function res = objective(greenlight,freesp,wait)
    greenlight = [greenlight;60.-greenlight];
    % greenlight = 30 * ones(22, 1);
    % load data;

    load F:\taoran\TTS\freespaceMat;
    load F:\taoran\TTS\linkData;
    load F:\taoran\TTS\inputLinkData;
    load F:\taoran\TTS\capacity;
    load F:\taoran\TTS\turnIn;

    freespace = freespaceMat * freesp; % 将读出的数据转化为与linkData相对应的freesp
    waiting = freespaceMat * wait;
    kk = 1; %车辆通过速率
    n = capacity - freespace;
    % 增加源节点信息
    freespace = [freespace;9999];
    % 路段路口对应矩阵
    transform = zeros(11,11);
    for i = 1:28
       transform(linkData(i,1),linkData(i,2))=i; 
    end
    % 生成转弯矩阵beta ,greenlight矩阵(右转为60),排队长度矩阵queue
    queue = zeros(29,29);
    green_1 = zeros(29,29);
    green_2 = zeros(29,29);
    green_3 = zeros(29,29);
    miu = zeros(29,29);
    for i = 1:28
        link_from = i;
        lane_num = linkData(i,4);
        greentime_1 = greenlight(linkData(i,2)+(1-linkData(i,5))*11*3);
        greentime_2 = greenlight(11+linkData(i,2)+(1-linkData(i,5))*11*3);
        greentime_3 = greenlight(22+linkData(i,2)+(1-linkData(i,5))*11*3);
        if linkData(i,7)>0 % 左转
            if linkData(i,7)>11
                link_to = 29;
                miu(link_to,link_from) = 1/lane_num;
            else
                link_to = transform(linkData(i,2),linkData(i,7));
            end        
            miu(link_from,link_to)=1/lane_num;
            green_1(link_from,link_to)=greentime_1;
            green_2(link_from,link_to)=greentime_2;
            green_3(link_from,link_to)=greentime_3;
            queue(link_from,link_to)=waiting(link_from,1);
        end
        if linkData(i,8)>0 % 直行
            if linkData(i,8)>11
                link_to = 29;
                miu(link_to,link_from) = 1/lane_num;
            else
                link_to = transform(linkData(i,2),linkData(i,8));
            end
            miu(link_from,link_to)=1/lane_num;
            green_1(link_from,link_to)=greentime_1;
            green_2(link_from,link_to)=greentime_2;
            green_3(link_from,link_to)=greentime_3;
            queue(link_from,link_to)=waiting(link_from,2);
        end
        if linkData(i,9)>0 % 右转
            if linkData(i,9)>11
                link_to = 29;
                miu(link_to,link_from) = 1/lane_num;
            else
                link_to = transform(linkData(i,2),linkData(i,9));
            end
            miu(link_from,link_to)=1/lane_num;
            green_1(link_from,link_to)=60;
            green_2(link_from,link_to)=60;
            green_3(link_from,link_to)=60;
            queue(link_from,link_to)=waiting(link_from,3);
        end
    end
    % 计算下一时刻离开车辆数
    leavemat = zeros(29,29);
    n_leave = zeros(29,1);
    n_enter = zeros(29,1);
    for i = 1:29
        for j = 1:29
            if miu(i,j)>0
                if(i>28)
                    b = 9999;
                    a = miu(i,j)*30*kk;
                else
                    b = queue(i,j);
                    a = miu(i,j)*green_1(i,j)*kk;
                end
                c = miu(i,j)*freespace(j);
                leavemat(i,j) = min(min(a,b),c);
                n_leave(i) = n_leave(i)+leavemat(i,j);
                n_enter(j) = n_enter(j)+leavemat(i,j);
            end
        end
    end
    % 更新queue矩阵
    for i = 1:28
        for j = 1:29
            if miu(i,j)>0
                queue(i,j)=queue(i,j)+n_enter(i)*miu(i,j)-leavemat(i,j);
            end
        end
    end
    % 更新车辆数
    n_1_forecast = n + n_enter(1:28) - n_leave(1:28);
    freespace = [capacity-n_1_forecast;9999];

    % 计算下一时刻离开车辆数
    leavemat = zeros(29,29);
    n_leave = zeros(29,1);
    n_enter = zeros(29,1);
    for i = 1:29
        for j = 1:29
            if miu(i,j)>0
                if(i>28)
                    b = 9999;
                    a = miu(i,j)*30*kk;
                else
                    b = queue(i,j);
                    a = miu(i,j)*green_2(i,j)*kk;
                end
                c = miu(i,j)*freespace(j);
                leavemat(i,j) = min(min(a,b),c);
                n_leave(i) = n_leave(i)+leavemat(i,j);
                n_enter(j) = n_enter(j)+leavemat(i,j);
            end
        end
    end
    % 更新queue矩阵
    for i = 1:28
        for j = 1:29
            if miu(i,j)>0
                queue(i,j)=queue(i,j)+n_enter(i)*miu(i,j)-leavemat(i,j);
            end
        end
    end
    % 更新车辆数
    n_2_forecast = n_1_forecast + n_enter(1:28) - n_leave(1:28);
    freespace = [capacity-n_2_forecast;9999];

    
    leavemat = zeros(29,29);
    n_leave = zeros(29,1);
    n_enter = zeros(29,1);
    for i = 1:29
        for j = 1:29
            if miu(i,j)>0
                if(i>28)
                    b = 9999;
                    a = miu(i,j)*30*kk;
                else
                    b = queue(i,j);
                    a = miu(i,j)*green_3(i,j)*kk;
                end
                c = miu(i,j)*freespace(j);
                leavemat(i,j) = min(min(a,b),c);
                n_leave(i) = n_leave(i)+leavemat(i,j);
                n_enter(j) = n_enter(j)+leavemat(i,j);
            end
        end
    end
    % 更新queue矩阵
    for i = 1:28
        for j = 1:29
            if miu(i,j)>0
                queue(i,j)=queue(i,j)+n_enter(i)*miu(i,j)-leavemat(i,j);
            end
        end
    end
    % 更新车辆数
    n_3_forecast = n_2_forecast + n_enter(1:28) - n_leave(1:28);
    res = sum(n_1_forecast+n_2_forecast+n_3_forecast);

end
