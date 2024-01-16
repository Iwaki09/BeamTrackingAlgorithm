output_name = 'curve_r60_test_2dim';
clc

scenarioPath = '../curve_r40_2.sumocfg';
[traciVersion,sumoVersion] = traci.start(['sumo -c ' '"' scenarioPath '"']);

f_plot = 0;
  
%% システムパラメータ

% キャリア周波数 [Hz]
fc = 28e+9;

% 光速 [m/s]
vc = 3e8;

% 波長 [m]
rmd = vc/fc;

% DU 素子数
n_tx = 16;
n_tz = 16;
n_du = n_tx*n_tz;

dtx  = rmd/2;
dtz  = rmd/2;  
otx  = 0;
otz  = 0;

% RU
n_rx = 10;
n_rz = 1;
n_ru  = n_rx*n_rz;

drx  = rmd/2;
drz  = rmd/2;  
orx  = 0;
orz  = 0;

% 捕捉開始SNR [dB]
snr_cap = 15;

% 送信電力 - フィーダ損失
Ptx = dbm2real(40-3)/(n_du);  
% 送信アンテナ利得
Gtx = 8; % zeros(n_pls,1);
% 受信アンテナ利得
Grx = 1; % zeros(n_pls,1);
% 雑音電力密度 [dBm/Hz]
Pnd = -174;
% 帯域幅 [Hz]
BW  = 400e6;
% 雑音指数 [dB]: UE
Nf  = 9;
% 雑音電力
Pn = Pnd + real2db(BW) + Nf;
Np = dbm2real(Pn);
        
%% 道路パラメータ

% 車線幅
lw = 3;
% 歩道幅
pw = 5;

% 左側壁からの距離 [m]
dl = 2;

% 観測時間 [s] 
t_sim = 100.00;
% 時間ステップ [s]
dt = 0.01;  % 0.001
t = 0:dt:t_sim-dt;

% 観測範囲 [m]
st_x = 60; 

% DUの位置
x_du = st_x/2;
y_du = -5;
z_du = 10;

% VAPの初期位置
x_ru = 0;
y_ru = 15.5;
z_ru = 2;

% known
dy_k = abs(y_du-y_ru);
dz_k = abs(z_du-z_ru);

% 走査角度
phi = (-70:1:70).'+90;  
the = atand(dz_k/dy_k*abs(sind(180-phi)))+90;

v_du = 0;
v_ru = 0; 

% 送受信局構造体
DU = struct('ary', repmat(struct('x', x_du, 'y', y_du, 'z', z_du), 1,1), 'v', v_du, 'dir', 0);
RU = struct('ary', repmat(struct('x', x_ru, 'y', y_ru, 'z', z_ru), 1,1), 'v', v_ru, 'dir', 0);  

DU_el = zeros(n_du,3);
na = 1;
for nx = 1:n_tx

  for ny = 1:1
    for nz = 1:n_tz
      px = dtx*(nx-1) + otx*(nx-1);
      py = 0;
      pz = dtz*(nz-1) + otz*(nz-1);
      DU_el(na,:) = [px, py, pz];
      na = na + 1;
    end
  end
end

RU_el = zeros(n_ru,3);
na = 1;
for nz = 1:n_rz
  for ny = 1:1
    for nx = 1:n_rx
      px = drx*(nx-1) + orx*(nx-1);
      py = 0;
      pz = drz*(nz-1) + orz*(nz-1);
      RU_el(na,:) = [px, py, pz];
      na = na + 1;
    end
  end
end

% VAPの移動方向  
motion = 0;
switch motion
  case 0 % 直進
    RU.dir = zeros(numel(t),1);  % 時系列の配列
  case 1 % ランダムに方向変化
    RU.dir = randi([-180 180],numel(t),1);
  case 2 % 一定区間ごとに方向変化
    RU.dir = [ repmat(9,floor(numel(t)/4),1); ...
                repmat(6,floor(numel(t)/4),1); ...
                repmat(3,floor(numel(t)/4),1); ...
                zeros(numel(t)-3*floor(numel(t)/4),1) ];
  case 3 % 一定方向変化
    RU.dir = 2.2906*ones(numel(t),1);  
end

state = 'wait';
a_ini = 140;
p_ini = atand(dz_k/dy_k*abs(sind(180-a_ini)))+90;

a_fin = 40;
a_est = a_ini;
p_est = p_ini;
v_ini = 0;
v_est = v_ini;
vy_est = v_ini;
y_est = -1.6;

% Fixed
a_fix = 90;
p_fix = atand(dz_k/dy_k*abs(sind(180-a_fix)))+90;
Wt_c = gen_beam(n_tx, n_tz, fc, a_fix, p_fix);

% Search
a_div = 7;
p_div = 10;
p_fin = 30;
a_sch = a_ini:-a_div:a_fin;
p_sch = (0:p_div:p_fin)+90; 

Wt_ini = gen_beam(n_tx, n_tz, fc, a_ini, p_ini);

DU_pos = DU_el +  repmat([x_du, y_du, z_du],[n_du,1]);

ns = 1;

% output_name = 'curve_r60_75to90_2dim_44';
output_file = strcat('../result/', output_name, '.csv');
output_file2 = strcat('../result/', output_name, '2.csv');
if strcmp(output_name(end-3:end), '2way')
    search_way = 2;
elseif strcmp(output_name(end-3:end), '2dim')
    search_way = 22;
elseif strcmp(output_name(end-3:end), '4way')
    search_way = 4;
elseif strcmp(output_name(end-6:end), '2dim_44')
    search_way = 44;
end

if strcmp(output_name(1:6), 'direct')
    direct_or_not = 1;
else
    direct_or_not = 0;
end

% 車速用
speed_list = [];
pos_list = [];
distance_list = [];
result_list = [];
result_list2 = [];
speed = 0; % 初速
RU.ary.x = 5; % 車の長さ分のoffset
% main loop.
for nt = 1:numel(t)
    traci.simulation.step(); % sumoの1ステップを進める
    RU.v = speed;
    speed = traci.vehicle.getSpeed('t_0');
    speed_list(end+1) = speed * 3600 / 1000;

    vehicleID = 't_0'; % 取得したい車両のIDに置き換える
    position = traci.vehicle.getPosition(vehicleID);
    % disp(['車両位置 (x, y): ', num2str(position)]);

    accel = traci.vehicle.getPosition(vehicleID);
    direction = traci.vehicle.getAngle(vehicleID);

    if direct_or_not == 0
      RU.ary.x = position(1);
      RU.ary.y = y_ru + position(2);
    else
      RU.ary.x = RU.ary.x + RU.v.*cosd(RU.dir(nt))*dt;
      RU.ary.y = RU.ary.y + RU.v.*sind(RU.dir(nt))*dt;
    end

    pos_list(end+1) = RU.ary.x;
    % if RU.ary.x >= 58
    %   writematrix(result_list, output_file);
    %   break;
    % end

    RU_pos   = RU_el + repmat([RU.ary.x, RU.ary.y, z_ru],[n_ru,1]);
    
    pos_plot = 0;
    % 位置プロット
    if pos_plot == 1
      figure(2);
      hold on;
      plot3(DU_pos(:,1),DU_pos(:,2),DU_pos(:,3), 'bs', 'LineWidth', 1);
      hold on;
      grid on;
      stem3(RU_pos(:,1),RU_pos(:,2),RU_pos(:,3), 'rv', 'LineWidth', 1);
      xlabel('x [m]');
      ylabel('y [m]');
      zlabel('z [m]');
      hold off;
    end
    
    dx  = RU.ary(1).x - DU.ary(1).x;
    dy  = RU.ary(1).y - DU.ary(1).y;
    dz  = RU.ary(1).z - DU.ary(1).z;    
    d   = sqrt(dx.^2 + dy.^2 + dz.^2);
    distance_list(end+1) = d;
    a_i = atand(dx/dy)+90;
    p_i = atand(abs(dz)/abs(dy)*abs(sind(180-a_i)))+90;
    
%     H   = gen_channel(n_tx, n_tz, fc, ang, 1);
    
    H   = gen_channel_los(DU_pos, RU_pos, rmd, 1);
    
    
    Gab = db2real(-15.*d/1000);
%     G   = rmd./(4*pi.*d).*sqrt(Ptx*Gtx*Grx*Gab);
    G   = sqrt(Ptx*Gtx*Grx*Gab);
    if nt == 1, G_  = G*rmd./(4*pi.*d); end;
    HG  = H*G;

    switch state
      
      case 'wait'
        Wt  = Wt_ini;
        Wr  = nrmlzm((HG*Wt)','sum');
        
        SNR = real2db(abs(Wr*HG*Wt).^2/Np);
        
        if (SNR > snr_cap) && (a_est >= a_fin)
          state = 'track';
          SNR_0 = SNR;
          SNR_o = SNR;
          SNR_c = SNR;
          SNR_s = SNR; 
        end
        
      case 'track'        

        % Optimal: SVD
        [~, ~, V] = svd(H);
        Wt_i  = nrmlzm(V(:,1),'sum');
        Wr_i  = nrmlzm((HG*Wt_i)','sum');        
        SNR_o = real2db(abs(Wr_i*HG*Wt_i).^2/Np);
        
        % Fixed beam
        Wr_c  = nrmlzm((HG*Wt_c)','sum');
        SNR_c = real2db(abs(Wr_c*HG*Wt_c).^2/Np);
        
        % Search
        for ni = 1:numel(a_sch)
          for nj = 1:numel(p_sch)           
            Wt_s          = gen_beam(n_tx, n_tz, fc, a_sch(ni), p_sch(nj));
            SNR_s(ni,nj) = real2db(abs(ones(1,n_rx)*HG*Wt_s).^2/Np);             
          end
        end
        [SNR_x, r] = max(SNR_s,[],1);
        [SNR_y, c] = max(SNR_x,[],2);
        Wt_s  = gen_beam(n_tx, n_tz, fc, a_sch(r(c)), p_sch(c));
        Wr_s  = nrmlzm((HG*Wt_s)','sum');
        SNR_s = real2db(abs(Wr_s*HG*Wt_s).^2/Np);
        
        % Proposed
        %% 二次元の時は下を消す
        if (search_way == 2) || (search_way == 4)
          p_est = atand(dz_k/dy_k*abs(sind(180-a_est)))+90; 
        end       
        
        Wt  = gen_beam(n_tx, n_tz, fc, a_est, p_est);
        Wr  = nrmlzm((HG*Wt)','sum');
                
        SNR = real2db(abs(Wr*HG*Wt).^2/Np);

        if (search_way == 4) || (search_way == 44)
          angle = 2;
        else
          angle = 7;
        end
        
        % 使われていない変数
        if search_way == 44
          angle_p = 2;
        else
          angle_p = 7;
        end

        % 2方向ビームサーチ
        if search_way == 2
          %------------------------------------------%
          if SNR - SNR_0 < 0
            W_a  = gen_beam(n_tx, n_tz, fc, a_est-angle, p_est);
            W_b  = gen_beam(n_tx, n_tz, fc, a_est+angle, p_est);
          
            SNR_a = real2db(abs(Wr*HG*W_a).^2/Np);
            SNR_b = real2db(abs(Wr*HG*W_b).^2/Np);
          
            u = db2real(abs(SNR - SNR_0));
          
            v_est = v_est + sign(SNR_a-SNR_b)*3*u;
          end
          %------------------------------------------%
        % 4方向ビームサーチ
        elseif search_way == 4
          %------------------------------------------%
          if SNR - SNR_0 < 0
            W_a  = gen_beam(n_tx, n_tz, fc, a_est-2*angle, p_est);
            W_b  = gen_beam(n_tx, n_tz, fc, a_est-angle, p_est);
            W_c  = gen_beam(n_tx, n_tz, fc, a_est+angle, p_est);
            W_d  = gen_beam(n_tx, n_tz, fc, a_est+2*angle, p_est);

            SNR_a = real2db(abs(Wr*HG*W_a).^2/Np);
            SNR_b = real2db(abs(Wr*HG*W_b).^2/Np);
            SNR_c = real2db(abs(Wr*HG*W_c).^2/Np);
            SNR_d = real2db(abs(Wr*HG*W_d).^2/Np);

            u = db2real(abs(SNR - SNR_0));

            SNR_max = max([SNR_a, SNR_b, SNR_c, SNR_d]);
            if SNR_max == SNR_a
                v_est = v_est + 2*3*u;
            elseif SNR_max == SNR_b
                v_est = v_est + 3*u;
            elseif SNR_max == SNR_c
                v_est = v_est - 3*u;
            else
                v_est = v_est - 2*3*u;
            end
          end
        % 二次元ビームサーチ
        elseif search_way == 22
          if SNR - SNR_0 < 0
            W_a  = gen_beam(n_tx, n_tz, fc, a_est+angle, p_est);
            W_b  = gen_beam(n_tx, n_tz, fc, a_est-angle, p_est);
            W_c  = gen_beam(n_tx, n_tz, fc, a_est, p_est+angle);
            W_d  = gen_beam(n_tx, n_tz, fc, a_est, p_est-angle);

            SNR_a = real2db(abs(Wr*HG*W_a).^2/Np);
            SNR_b = real2db(abs(Wr*HG*W_b).^2/Np);
            SNR_c = real2db(abs(Wr*HG*W_c).^2/Np);
            SNR_d = real2db(abs(Wr*HG*W_d).^2/Np);

            u = db2real(abs(SNR - SNR_0));

            SNR_max = max([SNR_a, SNR_b, SNR_c, SNR_d]);
            if SNR_max == SNR_a
                v_est = v_est - 3*u;
            elseif SNR_max == SNR_b
                v_est = v_est + 3*u;
            elseif SNR_max == SNR_c
                vy_est = vy_est - 3*u;
            else
                vy_est = vy_est + 3*u;
            end
          end
        % 2次元4方向ビームサーチ
        elseif search_way == 44
          if SNR - SNR_0 < 0
            W_a  = gen_beam(n_tx, n_tz, fc, a_est+angle, p_est);
            W_b  = gen_beam(n_tx, n_tz, fc, a_est-angle, p_est);
            W_c  = gen_beam(n_tx, n_tz, fc, a_est, p_est+angle);
            W_d  = gen_beam(n_tx, n_tz, fc, a_est, p_est-angle);
            W_a2  = gen_beam(n_tx, n_tz, fc, a_est+2*angle, p_est);
            W_b2  = gen_beam(n_tx, n_tz, fc, a_est-2*angle, p_est);
            W_c2  = gen_beam(n_tx, n_tz, fc, a_est, p_est+2*angle);
            W_d2  = gen_beam(n_tx, n_tz, fc, a_est, p_est-2*angle);

            SNR_a = real2db(abs(Wr*HG*W_a).^2/Np);
            SNR_b = real2db(abs(Wr*HG*W_b).^2/Np);
            SNR_c = real2db(abs(Wr*HG*W_c).^2/Np);
            SNR_d = real2db(abs(Wr*HG*W_d).^2/Np);
            SNR_a2 = real2db(abs(Wr*HG*W_a2).^2/Np);
            SNR_b2 = real2db(abs(Wr*HG*W_b2).^2/Np);
            SNR_c2 = real2db(abs(Wr*HG*W_c2).^2/Np);
            SNR_d2 = real2db(abs(Wr*HG*W_d2).^2/Np);

            u = db2real(abs(SNR - SNR_0));

            SNR_max = max([SNR_a, SNR_b, SNR_c, SNR_d, SNR_a2, SNR_b2, SNR_c2, SNR_d2]);
            if SNR_max == SNR_a
                v_est = v_est - 3*u;
            elseif SNR_max == SNR_b
                v_est = v_est + 3*u;
            elseif SNR_max == SNR_c
                vy_est = vy_est - 3*u;
            elseif SNR_max == SNR_d
                vy_est = vy_est + 3*u;
            elseif SNR_max == SNR_a2
                v_est = v_est - 2*3*u;
            elseif SNR_max == SNR_b2
                v_est = v_est + 2*3*u;
            elseif SNR_max == SNR_c2
                vy_est = vy_est - 2*3*u;
            else
                vy_est = vy_est + 2*3*u;
            end
          end
        end
        
        a_est = a_est - atand(v_est*dt/dy_k);

        if (search_way == 22) || (search_way == 44)
          y_est = y_est + vy_est * dt;
          p_est = atand(dz_k/(dy_k + y_est)*abs(sind(180-a_est)))+90;
        end
        SNR_0 = SNR;

        % disp(SNR);
  
        if a_est < a_fin
          state = 'wait';
          Wt_ini = Wt;
        end  
        
        SNR_sch(ns,1) = SNR_s;
        SNR_opt(ns,1) = SNR_o;
        SNR_pro(ns,1) = SNR;        
        ns = ns + 1;
    end

    if f_plot == 0
      switch state
        case 'track'
          result_list = [result_list; [d, speed, accel, direction, SNR]];
          writematrix(result_list, output_file);
      end
    end

    if f_plot == 1      
      figure(1)
      subplot(2,1,1);
      switch state
        case 'wait', plot(RU.ary.x, SNR, '.', 'Color', [0.2 0.2 0.2]);
          result_list2 = [result_list2; [RU.ary.x, SNR]];
          % csvwrite(output_file2, result_list2);
        case 'track',
          plot(RU.ary.x, SNR_o, '.', 'Color', 'blue', 'LineWidth', 1.0);
          hold on;
          % plot(RU.ary.x, SNR_c, '.', 'Color', mycolor('orange'), 'LineWidth', 1.0);
          plot(RU.ary.x, SNR_s, '.', 'Color', 'green', 'LineWidth', 1.0);
          plot(RU.ary.x, SNR, '.', 'Color', 'red', 'LineWidth', 1.0);
          result_list = [result_list; [d, speed, accel, direction, SNR]]
          % csvwrite('kaka.csv', result_list);
      end
      fig = gcf; % 現在のフィギュアを取得
      fig.Position(3) = 500; % 幅を800ポイントに設定
      fig.Position(4) = 1000; % 高さを600ポイントに設定
      hold on;

      xlim([0,st_x]);
      ylim([0 60]);
      xlabel('position[m]');
      ylabel('SNR[dB]');
      grid on;
      hold on;
      
      for nj = 1:numel(phi)
        H_  = gen_channel(n_tx, n_tz, fc, 180-phi(nj), the(nj), 1);
        S(nj,1) = real2db(abs((H_*G_)*Wt).^2/Np);
      end
      subplot(2,1,2);
      plot(pos_list,speed_list);
      xlim([0,60]);
      ylim([0 90]);
      xlabel('position[m]');
      ylabel('speed[km/h]');
      grid on;
    end
  
end

% saveas(gcf, 'result.png');

% hold off;

traci.close();



%% Beamforming: 遠方界モデルの式から
function w = gen_beam(el_row, el_col, fc, phi_t, the_t)

w = gen_channel(el_row, el_col, fc, phi_t, the_t, 0)';
w = nrmlzm(w,'sum');

end

%% Channel:受信アンテナ(RS)数×送信アンテナ(BS)数×サブキャリア数（ここではサブキャリア方向は使わない）
function H = gen_channel(el_row, el_col, fc, phi_t, the_t, ant_pat)

N_RS   = 1;
%   Ant_el = 16;
%   Carrier_freq = 28e9; %

Ant_Offset = 0;

n_el = el_row*el_col;

H = zeros(N_RS, n_el, 1);

%SC_f = M.Bandwidth/M.N_FFT; % サブキャリア間隔

l = 3e8./fc;
l = reshape(l,[1,1,1]);
l = repmat(l,[1,el_row*el_col,1]);

offset_c = 0;
offset_r = 0;
if Ant_Offset == 1
  offset_c = 1/el_col;
  offset_r = 1/el_row;
end

dt = l/2; 
dr = l/2;
  
% 送信アンテナの行・列番号
mt = repmat(1:el_row,[el_col,1]);  mt = mt(:).';
nt = repmat(1:el_col,[1,el_row]);  
%   mt = repmat(1:el_col,[el_row,1]);  mt = mt(:).';
%   nt = repmat(1:el_row,[1,el_col]);  

% サブキャリア方向に拡張
mt = repmat(mt,[1,1,1]);
nt = repmat(nt,[1,1,1]);  

% 受信アンテナの行・列番号
mr = 1;
nr = 1;
% 受信アンテナの方位角・天頂角
the_r = 90;
phi_r = 90;  

% 送信アンテナの方位角・天頂角：RS位置
%   the_t = 105; %90; % rand * 90 + 45;  % 60  + 60;
%   phi_t = 90; % rand *  5 + 90; % 120 + 30;

ni = 0;
while ni < N_RS

  the_t = repmat(the_t,[1,n_el,1]);
  phi_t = repmat(phi_t,[1,n_el,1]);    
  
  h_vec = exp(2j*pi./l.*(((mt-1)+(nt-1).*offset_r).*dt.*cosd(phi_t).*sind(the_t)+((nt-1)+(mt-1).*offset_c).*dt.*cosd(the_t)+ ... % これは縦にオフセット与えてる(18/10/27)
                          (mr-1).*dr.*cosd(phi_r).*sind(the_r)+(nr-1).*dr.*cosd(the_r)));  
  if ant_pat == 1
    h_vec = sqrt(antenna_3gpp(the_t, phi_t)).* h_vec;
  end
  
  ni = ni + 1;
  H(ni,:,:) = h_vec;  

end

 H = H;  

end


%% LOS Channel: 球面波
function H = gen_channel_los(tx_pos, rx_pos, rmd, ant_pat)

n_tx = size(tx_pos,1);
n_rx = size(rx_pos,1);  
H = zeros(n_rx, n_tx);

for ni = 1:n_rx

  dt = repmat(rx_pos(ni,:),[n_tx,1]) - tx_pos;
      
  % 3GPP アンテナパターンも考慮
  ph = atand(dt(:,1)./dt(:,2))+90;
  th = abs(atand(dt(:,3)./dt(:,2)).*sind(ph))+90;
  ag = antenna_3gpp(mean(th), ph);
  
  dd = sqrt(sum(abs(dt).^2,2));
  
  h_ = 1 .* rmd./(4*pi.*dd) .* exp(-2j*pi.*dd/rmd);
  
  if ant_pat == 1
    h_ = sqrt(ag) .* h_;
  end
  
  H(ni,:) = h_.';
end


end


function gain = antenna_3gpp(the_d, phi_d)

hpbw   = deg2rad(65);
the_r  = deg2rad(the_d);  
phi_r  = deg2rad(phi_d);  

gain_t = -min(12*((the_r - deg2rad(the_d))./hpbw).^2, 30);
gain_p = -min(12*((phi_r - pi/2)./hpbw).^2, 30);

gain   = db2real(-min(-(gain_t+gain_p) ,30));

end

% normalize
function [y, n] = nrmlzm( x, method )

switch method
  case 'sum'
    n = sqrt(sum(sum(abs(x).^2)));
    y = x/n;
  case 'mean'
    n = sqrt(mean(mean(abs(x).^2)));
    y = x/n;
  case 'max'
    n = max(max(abs(x)));
    y = x/n;
  case 'maxa'
    n = max(max(abs(x)))*2;
    y = x/n;
  case 'rowmean'
    n = diag(1./sqrt(mean(abs(x).^2,2)));
    y = n*x;
end

end

%% plot setting
function plot_init

set(0,'defaultAxesFontSize',11);
set(0,'defaultAxesFontName','Segoe UI');
set(0,'defaultTextFontSize',11);
set(0,'defaultTextFontName','Segoe UI');

% Figureウインドウの色
set(0, 'defaultFigureColor', [1 1 1]);

% 軸の色（プロットエリアの色）
set(0, 'defaultAxesColor', [1 1 1]);

end
