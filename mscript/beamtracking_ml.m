% beamtracking_ml_('curve_r60_ml_2dim')
% 引数の仕様：prefix: scenario名, suffix: ml, 4wayなど

function beamtracking_ml(output_name)
  clc

  scenarioPath = '../datasource/curve_r60.sumocfg';
  [traciVersion,sumoVersion] = traci.start(['sumo -c ' '"' scenarioPath '"']);

  % 特に重要なパラメータ
  
  % グラフプロットの有無。0ならなし。1ならあり。
  f_plot = 0;

  % 1なら実際の速度を、2なら予測速度をプロットする。
  speed_plot = 1;

  % ファイルに書き出しを行うかどうか。0なら書かない。11なら結果モードで、12ならデータセットモードで、13ならガイドデータモードで書く。
  % 13の時は書き出す先とファイル名に注意。あとでrenameすれば良い
  file_write = 11;

  % 上記のファイルを書き出す先。..にすること
  output_dir = '../ml_result';

  % グラフを保存するかどうか
  graph_save = 0;

  % 速度更新のパラメータ
  alpha = 3;

  % noguideモード(yを自前で用意する。distはガイドを使う(結局ガイド使ってる))
  no_guide = 1;

  % angle_diffモード　2ならangleとangle_diffだけ
  angle_diff_mode = 2;

  % svm_modelの名前
  model_basename = 'xgb_noacc_ad';
  if strcmp(model_basename(5:9), 'nodir')
    model_type = 1;
  elseif strcmp(model_basename(5:9), 'noacc')
    model_type = 2;
  elseif strcmp(model_basename(4:8), 'noacc')
    model_type = 2;
  % elseif strcmp(model_basename(end-5:end), 'noacc2')
  %   保留
  %   model_type = 3;
  end

  if no_guide == 1
    model_type = 4;
  end

  if angle_diff_mode == 1
    model_type = 5;
  elseif angle_diff_mode == 2
    model_type = 6;
  end

  if strcmp(model_basename, 'xgb_noacc_ad')
    model_type = 7;
  elseif strcmp(model_basename, 'xgb_noacc_ad2')
    model_type = 8;
  end
  % シナリオの座標を0基準にする
  % 左向きに進むならturn_x = -1, 上に基地局があるならturn_y = -1
  offset_x = 0;
  turn_x = 1;
  offset_y = 0;
  turn_y = 1;
  % 右上に傾いているなら-をつける。ただし、turn_xかturn_yが-1なら逆になる。
  tilt = 0;
  % 新しいシナリオを使う時はここを編集
  if strcmp(output_name(1:6), 'direct')
    scenario = 'direct';
  elseif strcmp(output_name(1:9), 'curve_r30')
    scenario = 'curve_r30';
  elseif strcmp(output_name(1:9), 'curve_r40')
    scenario = 'curve_r40';
  elseif strcmp(output_name(1:9), 'curve_r60')
    scenario = 'curve_r60';
  elseif strcmp(output_name(1:10), 'curve_r150')
    scenario = 'curve_r150';
  elseif strcmp(output_name(1:7), 'okutama')
    scenario = 'okutama';
    offset_x = 180;
    offset_y = 130;
    turn_y = -1;
  elseif strcmp(output_name(1:9), 'shinobazu')
    scenario = 'shinobazu';
    % offset_x = 269;
    % offset_y = 348;
    % turn_y = -1;
    offset_x = 325;
    turn_x = -1;
    offset_y = 347;
    turn_y = -1;
  elseif strcmp(output_name(1:8), 'korakuen')
    scenario = 'korakuen';
    offset_x = 1123;
    offset_y = 1462;
    turn_y = -1;
    tilt = -0.5;
  elseif strcmp(output_name(1:7), 'yomiuri')
    scenario = 'yomiuri';
    offset_x = 320;
    offset_y = 508;
    turn_y = -1;
  elseif strcmp(output_name(1:6), 'paris_')
    scenario = 'paris';
    offset_x = 3459;
    offset_y = 2481;
    turn_y = -1;
    tilt = -26;
  elseif strcmp(output_name(1:6), 'paris2')
    scenario = 'paris2';
    offset_x = 4420;
    offset_y = 3569;
    turn_y = -1;
    tilt = 4.08;
  elseif strcmp(output_name(1:7), 'charles')
    scenario = 'charles';
    offset_x = 660.82;
    offset_y = 253;
    turn_x = -1;
    tilt = 4.31;
  end

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

  RU.dir = zeros(numel(t),1);  % 時系列の配列

  state = 'wait';
  a_ini = 140;
  p_ini = atand(dz_k/dy_k*abs(sind(180-a_ini)))+90;

  a_fin = 40;
  a_est = a_ini;
  p_est = p_ini;
  v_ini = 0;
  v_est = v_ini;
  vy_est = v_ini;
  v_prev = 0;
  vy_prev = 0;
  y_est = 0;
  x_est = 0;

  % Search
  a_div = 7;
  p_div = 10;
  p_fin = 30;
  a_sch = a_ini:-a_div:a_fin;
  p_sch = (0:p_div:p_fin)+90; 

  Wt_ini = gen_beam(n_tx, n_tz, fc, a_ini, p_ini);

  DU_pos = DU_el +  repmat([x_du, y_du, z_du],[n_du,1]);

  ns = 1;

  output_file = strcat(output_dir, '/', output_name, '.csv');
  output_file2 = strcat(output_dir, '/', output_name, '2.csv');
  ml_mode = 0;

  if strcmp(output_name(end-3:end), '2way')
    search_way = 2;
  elseif strcmp(output_name(end-3:end), '2dim')
    search_way = 22;
  elseif strcmp(output_name(end-3:end), '4way')
    search_way = 4;
  elseif strcmp(output_name(end-6:end), '2dim_44')
    search_way = 44;
  elseif strcmp(output_name(end-1:end), 'ml') | strcmp(output_name(end-6:end-5), 'ml')
    search_way = 22;
    ml_mode = 1;
  end

  % if strcmp(output_name(1:6), 'direct')
  %     direct_or_not = 1;
  % else
  %     direct_or_not = 0;
  % end


  % 車速用
  speed_list = [];
  pos_list = [];
  result_list = [];
  result_list2 = [];
  speed = 0; % 初速
  RU.ary.x = 5; % 車の長さ分のoffset
  angle_ml = 90;
  % main loop.
  for nt = 1:numel(t)
      traci.simulation.step(); % sumoの1ステップを進める
      RU.v = speed;
      try
        speed = traci.vehicle.getSpeed('t_0');
      catch
        break
      end
      if speed_plot == 1
        speed_list(end+1) = speed * 3600 / 1000;
      elseif speed_plot == 2
        % Notice that v_est dose not include y_direction speed.
        speed_list(end+1) = v_est * 3600 / 1000;
      end

      vehicleID = 't_0'; % 取得したい車両のIDに置き換える
      position = traci.vehicle.getPosition(vehicleID);
      tmp_x = turn_x * (position(1) - offset_x);
      tmp_y = turn_y * (position(2) - offset_y);
      % 回転
      position(1) = tmp_x * cosd(tilt) - tmp_y * sind(tilt);
      position(2) = tmp_x * sind(tilt) + tmp_y * cosd(tilt);

      accel = traci.vehicle.getPosition(vehicleID);
      direction = traci.vehicle.getAngle(vehicleID);
      if turn_x == -1
        direction = 360 - direction;
      end
      if turn_y == -1
        direction = 180 - direction;
      end
      direction = direction - tilt;
      

      % if direct_or_not == 1
      %   % カーブ
      %   RU.ary.x = position(1);
      %   RU.ary.y = y_ru + position(2);
      %   position(2)
      % else %勅選
      %   RU.ary.x = RU.ary.x + RU.v.*cosd(RU.dir(nt))*dt;
      %   RU.ary.y = RU.ary.y + RU.v.*sind(RU.dir(nt))*dt;
      % end
      RU.ary.x = position(1);
      RU.ary.y = y_ru + position(2);

      pos_list(end+1) = RU.ary.x;
      if RU.ary.x >= 60
        break;
      end

      RU_pos   = RU_el + repmat([RU.ary.x, RU.ary.y, z_ru],[n_ru,1]);
      
      dx  = RU.ary(1).x - DU.ary(1).x;
      dy  = RU.ary(1).y - DU.ary(1).y;
      dz  = RU.ary(1).z - DU.ary(1).z; 
      d   = sqrt(dx.^2 + dy.^2 + dz.^2);
      d_2dim = sqrt(dx.^2 + dy.^2);
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

          accel_x = (v_est - v_prev) / 0.01;
          accel_y = (vy_est - vy_prev) / 0.01;

          speed_abs = sqrt(v_est^2 + vy_est^2);
          accel_abs = sqrt(accel_x^2 + accel_y^2);

          if ml_mode == 1
            if model_type == 1
              pyres = pyrunfile("svm_for_matlab_nodir.py", "res", model_basename=model_basename, dist=d_2dim, speed=speed_abs, accel=accel_abs);
              items = [d, speed, accel_abs]
              search_way = int16(pyres(1))
            elseif model_type == 2
              pyres = pyrunfile("svm_for_matlab_noacc.py", "res", model_basename=model_basename, scenario=scenario, x=x_est, speed=speed)
              search_way = int16(pyres(1))
            elseif model_type == 3
              pyres = pyrunfile("svm_for_matlab_noacc2.py", "res", model_basename=model_basename, scenario=scenario, x=x_est, speed=speed);
              search_way = int16(pyres(1))
            elseif model_type == 4
              pyres = pyrunfile("svm_for_matlab_noacc_noguide.py", "res", model_basename=model_basename, scenario=scenario, x=x_est, y=y_est, speed=speed);
              search_way = int16(pyres(1))
            elseif model_type == 5
              pyres = pyrunfile("svm_for_matlab_anglediff.py", "res", model_basename=model_basename, scenario=scenario, x=x_est, y=y_est, speed=speed, angle_prev=angle_ml);
              angle_ml = double(pyres(2))
              items = pyres(3)
              search_way = int16(pyres(1))
            elseif model_type == 6
              pyres = pyrunfile("svm_for_matlab_anglediff2.py", "res", model_basename=model_basename, scenario=scenario, x=x_est, y=y_est, speed=speed, angle_prev=angle_ml);
              angle_ml = double(pyres(2))
              items = pyres(3)
              search_way = int16(pyres(1))
            elseif model_type == 7
              python_cmd = 'python';
              script_name = 'xgb_for_matlab_ad.py';
              command_str = sprintf('%s %s %s %s %d %d %d %d', python_cmd, script_name, model_basename, scenario, x_est, y_est, speed, angle_ml);
              [status, result] = system(command_str);
              result = strsplit(result, ' ');
              % pyres = pyrunfile("xgb_for_matlab_ad2.py", "res", model_basename=model_basename, scenario=scenario, x=x_est, y=y_est, speed=speed, angle_prev=angle_ml);
              search_way = str2num(result{1});
              angle_ml = str2double(result{2});
              angle_diff = str2double(result{3});
              [RU.ary.x, direction, angle_ml, angle_diff, search_way]
            elseif model_type == 8
              python_cmd = 'python';
              script_name = 'xgb_for_matlab_ad2_new.py';
              command_str = sprintf('%s %s %s %s %d %d %d %d', python_cmd, script_name, model_basename, scenario, x_est, y_est, speed, angle_ml);
              [status, result] = system(command_str);
              result = strsplit(result, ' ');
              % pyres = pyrunfile("xgb_for_matlab_ad2.py", "res", model_basename=model_basename, scenario=scenario, x=x_est, y=y_est, speed=speed, angle_prev=angle_ml);
              search_way = str2num(result{1});
              angle_ml = str2double(result{2});
              angle_diff = str2double(result{3});
              [RU.ary.x, direction, angle_ml, angle_diff, search_way]
            end
          end

          v_prev = v_est;
          vy_prev = vy_est;
          
          % Proposed
          %% 二次元の時は下を消す
          if (search_way == 2) || (search_way == 4)
            p_est = atand(dz_k/dy_k*abs(sind(180-a_est)))+90; 
          end       
          
          Wt  = gen_beam(n_tx, n_tz, fc, a_est, p_est);
          Wr  = nrmlzm((HG*Wt)','sum');
                  
          SNR = real2db(abs(Wr*HG*Wt).^2/Np);

          if (search_way == 4) || (search_way == 44)
            angle = 1;
          else
            angle = 7;
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
            
              v_est = v_est + sign(SNR_a-SNR_b)*alpha*u;
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
              % W_a  = gen_beam(n_tx, n_tz, fc, a_est-7, p_est);
              % W_b  = gen_beam(n_tx, n_tz, fc, a_est-angle, p_est);
              % W_c  = gen_beam(n_tx, n_tz, fc, a_est+angle, p_est);
              % W_d  = gen_beam(n_tx, n_tz, fc, a_est+7, p_est);

              SNR_a = real2db(abs(Wr*HG*W_a).^2/Np);
              SNR_b = real2db(abs(Wr*HG*W_b).^2/Np);
              SNR_c = real2db(abs(Wr*HG*W_c).^2/Np);
              SNR_d = real2db(abs(Wr*HG*W_d).^2/Np);

              u = db2real(abs(SNR - SNR_0));

              SNR_max = max([SNR_a, SNR_b, SNR_c, SNR_d]);
              if SNR_max == SNR_a
                  v_est = v_est + 2*alpha*u;
              elseif SNR_max == SNR_b
                  v_est = v_est + alpha*u;
              elseif SNR_max == SNR_c
                  v_est = v_est - alpha*u;
              else
                  v_est = v_est - 2*alpha*u;
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
                  v_est = v_est - alpha*u;
              elseif SNR_max == SNR_b
                  v_est = v_est + alpha*u;
              elseif SNR_max == SNR_c
                  vy_est = vy_est - alpha*u;
              else
                  vy_est = vy_est + alpha*u;
              end
            end
          % 2次元4方向ビームサーチ
          % elseif search_way == 44
          %   if SNR - SNR_0 < 0
          %     W_a  = gen_beam(n_tx, n_tz, fc, a_est+angle, p_est);
          %     W_b  = gen_beam(n_tx, n_tz, fc, a_est-angle, p_est);
          %     W_c  = gen_beam(n_tx, n_tz, fc, a_est, p_est+angle);
          %     W_d  = gen_beam(n_tx, n_tz, fc, a_est, p_est-angle);
          %     W_a2  = gen_beam(n_tx, n_tz, fc, a_est+2*angle, p_est);
          %     W_b2  = gen_beam(n_tx, n_tz, fc, a_est-2*angle, p_est);
          %     W_c2  = gen_beam(n_tx, n_tz, fc, a_est, p_est+2*angle);
          %     W_d2  = gen_beam(n_tx, n_tz, fc, a_est, p_est-2*angle);

          %     SNR_a = real2db(abs(Wr*HG*W_a).^2/Np);
          %     SNR_b = real2db(abs(Wr*HG*W_b).^2/Np);
          %     SNR_c = real2db(abs(Wr*HG*W_c).^2/Np);
          %     SNR_d = real2db(abs(Wr*HG*W_d).^2/Np);
          %     SNR_a2 = real2db(abs(Wr*HG*W_a2).^2/Np);
          %     SNR_b2 = real2db(abs(Wr*HG*W_b2).^2/Np);
          %     SNR_c2 = real2db(abs(Wr*HG*W_c2).^2/Np);
          %     SNR_d2 = real2db(abs(Wr*HG*W_d2).^2/Np);

          %     u = db2real(abs(SNR - SNR_0));

          %     SNR_max = max([SNR_a, SNR_b, SNR_c, SNR_d, SNR_a2, SNR_b2, SNR_c2, SNR_d2]);
          %     if SNR_max == SNR_a
          %         v_est = v_est - alpha*u;
          %     elseif SNR_max == SNR_b
          %         v_est = v_est + alpha*u;
          %     elseif SNR_max == SNR_c
          %         vy_est = vy_est - alpha*u;
          %     elseif SNR_max == SNR_d
          %         vy_est = vy_est + alpha*u;
          %     elseif SNR_max == SNR_a2
          %         v_est = v_est - 2*alpha*u;
          %     elseif SNR_max == SNR_b2
          %         v_est = v_est + 2*alpha*u;
          %     elseif SNR_max == SNR_c2
          %         vy_est = vy_est - 2*alpha*u;
          %     else
          %         vy_est = vy_est + 2*alpha*u;
          %     end
          %   end
          end
          
          if (search_way == 22) || (search_way == 44)
            y_est = y_est + vy_est * dt;
            a_est = a_est - atand(v_est*dt/(dy_k + y_est));
            p_est = atand(dz_k/(dy_k + y_est)*abs(sind(180-a_est)))+90;
          else
            a_est = a_est - atand(v_est*dt/dy_k);
          end

          % x_estはmlモードの時のみ使われる。
          x_est = (dy_k+y_est) / tand(a_est) + 30;

          SNR_0 = SNR;

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
          case 'wait'
            if file_write == 11
              result_list2 = [result_list2; [RU.ary.x, SNR]];
              writematrix(result_list2, output_file2);
            elseif file_write == 13
              result_list = [result_list; [RU.ary.x, RU.ary.y, direction]];
              writematrix(result_list, output_file);
            end
          case 'track'
            if file_write == 11
              result_list = [result_list; [RU.ary.x, SNR, SNR_o, SNR_s]];
              writematrix(result_list, output_file);
            elseif file_write == 12
              result_list = [result_list; [RU.ary.x, RU.ary.y, d_2dim, speed, accel, direction, SNR]];
              writematrix(result_list, output_file);
            elseif file_write == 13
              result_list = [result_list; [RU.ary.x, RU.ary.y, direction]];
              writematrix(result_list, output_file);
            end
        end
      end

      if f_plot == 1      
        figure(1)
        subplot(2,1,1);
        switch state
          case 'wait', plot(RU.ary.x, SNR, '.', 'Color', [0.2 0.2 0.2]);
            if file_write == 11
              result_list2 = [result_list2; [RU.ary.x, SNR]];
              writematrix(result_list2, output_file2);
            elseif file_write == 13
              result_list = [result_list; [RU.ary.x, RU.ary.y, direction]];
              writematrix(result_list, output_file);
            end
          case 'track',
            plot(RU.ary.x, SNR_o, '.', 'Color', 'blue', 'LineWidth', 1.0);
            hold on;
            % plot(RU.ary.x, SNR_c, '.', 'Color', mycolor('orange'), 'LineWidth', 1.0);
            plot(RU.ary.x, SNR_s, '.', 'Color', 'green', 'LineWidth', 1.0);
            plot(RU.ary.x, SNR, '.', 'Color', 'red', 'LineWidth', 1.0);
            if file_write == 11
              result_list = [result_list; [RU.ary.x, SNR, SNR_o, SNR_s]];
              writematrix(result_list, output_file);
            elseif file_write == 12
              result_list = [result_list; [RU.ary.x, RU.ary.y, d_2dim, speed, accel, direction, SNR]];
              writematrix(result_list, output_file);
            elseif file_write == 13
              result_list = [result_list; [RU.ary.x, RU.ary.y, direction]];
              writematrix(result_list, output_file);
            end
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
        
        % for nj = 1:numel(phi)
        %   H_  = gen_channel(n_tx, n_tz, fc, 180-phi(nj), the(nj), 1);
        %   S(nj,1) = real2db(abs((H_*G_)*Wt).^2/Np);
        % end
        subplot(2,1,2);
        plot(pos_list,speed_list);
        xlim([0,60]);
        ylim([0 90]);
        xlabel('position[m]');
        ylabel('speed[km/h]');
        grid on;
      end
    
  end

  if graph_save == 1
    graph_filename = strcat(output_dir, '/', output_name, '.png');
    saveas(gcf, graph_filename);
  end

  % hold off;

  traci.close();

end



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

