function [ SNR_sch, SNR_opt, SNR_pro ] = vc_mfh( v_01, f_plot )
%VC_MFH ���̊֐��̊T�v�������ɋL�q
%   �ڍא����������ɋL�q
  
  plot_init;
  clf;
  
  %% �V�X�e���p�����[�^
  
  % �L�����A���g�� [Hz]
  fc = 28e+9;
  
  % ���� [m/s]
  vc = 3e8; %299792458;
  
  % �g�� [m]
  rmd = vc/fc;
    
  % DU �f�q��
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
  
  % �ߑ��J�nSNR [dB]
  snr_cap = 30;
  
  % ���M�d�� - �t�B�[�_����
  Ptx = dbm2real(40-3)/(n_du);  
  % ���M�A���e�i����
  Gtx = 8; % zeros(n_pls,1);
  % ��M�A���e�i����
  Grx = 1; % zeros(n_pls,1);
  % �G���d�͖��x [dBm/Hz]
  Pnd = -174;
  % �ш敝 [Hz]
  BW  = 400e6;
  % �G���w�� [dB]: UE
  Nf  = 9;
  % �G���d��
  Pn = Pnd + real2db(BW) + Nf;
  Np = dbm2real(Pn);
  
  % ��������
%   do = 20.5;
  % �p�x�� (90�����ʁj
%   ang = (-60:1:60).'+90;
  % ����M�ԋ���
%   d = do./cosd(ang-90); % 1:30;
  % �_�f�z���ɂ�錸��
%   Gab = db2real(-15.*d/1000);
          
  %% ���H�p�����[�^
  
  % �Ԑ���
  lw = 3;
  % ������
  pw = 5;
  % ���H�� [m]
  dw = pw+lw+lw+lw+lw+pw;
  
  % �ԗ��ʒu
  vp = pw + lw/2;
  
  % �����ǂ���̋��� [m]
  dl = 2;

  
  % �ϑ����� [s]
  t_sim = 4.5;  % 10
  % ���ԃX�e�b�v [s]
  dt = 0.01;  % 0.001
  t = 0:dt:t_sim-dt;
  
%   dt = 0.01; % �T���v���Ԋu
%   t = [0:dt:100];
    
  % �ϑ��͈� [m]
  st_x = 60; 
  
  % DU�̈ʒu
  x_du = st_x/2;
  y_du = 0;
  z_du = 10;
  
  % VAP�̏����ʒu
  x_ru = 0;
  y_ru = pw+lw+lw+lw+lw/2;
  z_ru = 2;
  
  % known
  dy_k = abs(y_du-y_ru);
  dz_k = abs(z_du-z_ru);
  
  % �����p�x
  phi = (-70:1:70).'+90;  
  the = atand(dz_k/dy_k*abs(sind(180-phi)))+90;
  
  % �ړ����x [km/h]
%   v_01 = 60;
%   v_02 = 45;
  
  v_du = 0;
  v_ru = v_01; 
  
  % [m/s]
  v_du = v_du*1000/3600;  
  v_ru = v_ru*1000/3600;  
    
  
  % ����M�Ǎ\����
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
  
  
%   % DU
%   for ni = 2:ntx
%     DU.ary(ni).x = DU.ary(ni-1).x;
%     DU.ary(ni).y = DU.ary(ni-1).y + rtx;
%     DU.ary(ni).z = DU.ary(ni-1).z;
%   end
%   % VAP(RU)
%   for ni = 2:nrx
%     RU.ary(ni).x = RU.ary(ni-1).x + rrx;
%     RU.ary(ni).y = RU.ary(ni-1).y;
%     RU.ary(ni).z = RU.ary(ni-1).z;
%   end

  % VAP�̈ړ�����  
  motion = 0;
  switch motion
    case 0 % ���i
      RU.dir = zeros(numel(t),1);  % ���n��̔z��
    case 1 % �����_���ɕ����ω�
      RU.dir = randi([-180 180],numel(t),1);
    case 2 % ����Ԃ��Ƃɕ����ω�
      RU.dir = [ repmat(9,floor(numel(t)/4),1); ...
                 repmat(6,floor(numel(t)/4),1); ...
                 repmat(3,floor(numel(t)/4),1); ...
                 zeros(numel(t)-3*floor(numel(t)/4),1) ];
    case 3 % �������ω�
      RU.dir = 2.2906*ones(numel(t),1);  
  end
  
  state = 'wait';
  a_ini = 140;
  p_ini = atand(dz_k/dy_k*abs(sind(180-a_ini)))+90;
  
  a_fin = 40;
  a_est = a_ini;
  p_est = p_ini;
  v_ini = 30*1000/3600;
  v_est = v_ini;
  
  % Fixed
  a_fix = 90;
  p_fix = atand(dz_k/dy_k*abs(sind(180-a_fix)))+90;
  Wt_c   = gen_beam(n_tx, n_tz, fc, a_fix, p_fix);
  
  % Search
  a_div = 7;
  p_div = 10;
  p_fin = 30;
  a_sch = a_ini:-a_div:a_fin;
  p_sch = (0:p_div:p_fin)+90; 

  
  Wt_ini = gen_beam(n_tx, n_tz, fc, a_ini, p_ini);
  
  DU_pos = DU_el +  repmat([x_du, y_du, z_du],[n_du,1]);
  
  ns = 1;
  
  for nt = 1:numel(t)
       
    % VAP�̈ʒu�ړ�
    RU.ary.x = RU.ary.x + RU.v.*cosd(RU.dir(nt))*dt;
    RU.ary.y = RU.ary.y + RU.v.*sind(RU.dir(nt))*dt;

    RU_pos   = RU_el + repmat([RU.ary.x, RU.ary.y, z_ru],[n_ru,1]);
    
    pos_plot = 0;
    % �ʒu�v���b�g
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
    
    % ���x�ύX    
    % if RU.ary.x > 30
    %   RU.v = v_02*1000/3600;
    % end
    
    dx  = RU.ary(1).x - DU.ary(1).x;
    dy  = RU.ary(1).y - DU.ary(1).y;
    dz  = RU.ary(1).z - DU.ary(1).z;    
    d   = sqrt(dx.^2 + dy.^2 + dz.^2);    
    a_i = atand(dx/dy)+90;
    p_i = atand(abs(dz)/abs(dy)*abs(sind(180-a_i)))+90;
    
%     H   = gen_channel(n_tx, n_tz, fc, ang, 1);
    
    H   = gen_channel_los(DU_pos, RU_pos, rmd, 1);
    
    
    Gab = db2real(-15.*d/1000);
%     G   = rmd./(4*pi.*d).*sqrt(Ptx*Gtx*Grx*Gab);
    G   = sqrt(Ptx*Gtx*Grx*Gab);
    if nt == 1, G_  = G*rmd./(4*pi.*d); end;
    HG  = H*G;
    
%     N_rx = wgn(n_du, 1, Np, 'linear', 'complex');
    
    

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
        p_est = atand(dz_k/dy_k*abs(sind(180-a_est)))+90;        
        
        Wt  = gen_beam(n_tx, n_tz, fc, a_est, p_est);
        Wr  = nrmlzm((HG*Wt)','sum');
                
        SNR = real2db(abs(Wr*HG*Wt).^2/Np);
     
        if SNR - SNR_0 < 0
          W_a  = gen_beam(n_tx, n_tz, fc, a_est-7, p_est);
          W_b  = gen_beam(n_tx, n_tz, fc, a_est+7, p_est);
          
          SNR_a = real2db(abs(Wr*HG*W_a).^2/Np);
          SNR_b = real2db(abs(Wr*HG*W_b).^2/Np);
          
          u = db2real(abs(SNR - SNR_0));
%           u = abs(SNR - SNR_0);
%           if SNR_a > SNR_b          
% %           a_est = a_est;
%             v_est = v_est + 3*u;
%           else
%             v_est = v_est - 3*u;
%           end          
          v_est = v_est + sign(SNR_a-SNR_b)*3*u;
        end
        
        a_est = a_est - atand(v_est*dt/dy_k);
        SNR_0 = SNR;
 
        if a_est < a_fin
          state = 'wait';
          Wt_ini = Wt;
        end  
        
        % save SNR
        
        SNR_sch(ns,1) = SNR_s;
        SNR_opt(ns,1) = SNR_o;
        SNR_pro(ns,1) = SNR;        
        ns = ns + 1;
    end
    
    
    if f_plot == 1      
      figure(1)
      subplot(2,1,1);
      switch state
        case 'wait', plot(RU.ary.x, SNR, '.', 'Color', [0.2 0.2 0.2]);
        case 'track',
          plot(RU.ary.x, SNR_o, '.', 'Color', 'blue', 'LineWidth', 1.0);
          hold on;
          % plot(RU.ary.x, SNR_c, '.', 'Color', mycolor('orange'), 'LineWidth', 1.0);
          plot(RU.ary.x, SNR_s, '.', 'Color', 'green', 'LineWidth', 1.0);
          plot(RU.ary.x, SNR, '.', 'Color', 'yellow', 'LineWidth', 1.5);
      end
      xlim([0,st_x]);
      ylim([10 60]);
      xlabel('[m]');
      ylabel('SNR[dB]');
      legend('Proposed', 'Search', 'Optimal');
      grid on;
      hold on;
      
      for nj = 1:numel(phi)
        H_  = gen_channel(n_tx, n_tz, fc, 180-phi(nj), the(nj), 1);
        S(nj,1) = real2db(abs((H_*G_)*Wt).^2/Np);
      end
      subplot(2,1,2);
      plot(phi, S, '-r'); %, 'LineWidth', 0.5);
      hold on;
      plot(a_i, 30, 'bo', 'LineWidth', 1.5);
      hold off;
      grid on;
      xlim([20 160]);
      ylim([0 40]);
      xlabel('[degree]');
      ylabel('SNR[dB]');
      pause(0.1);
      
      fprintf('time = %.2f, phi = %.2f, a_est = %.2f, the = %.2f, p_est = %.2f, v_est = %.1f, SNR = %.2f  \n', t(nt), 180-a_i, a_est, p_i, p_est, v_est*3600/1000, SNR);
      pause(0.001);
    end
  
  end
  
%   plot(th, SNR, 'b-', 'LineWidth', 0.5);
  
end

%% Beamforming: �����E���f���̎�����
function w = gen_beam(el_row, el_col, fc, phi_t, the_t)

  w = gen_channel(el_row, el_col, fc, phi_t, the_t, 0)';
  w = nrmlzm(w,'sum');

end

%% Channel:��M�A���e�i(RS)���~���M�A���e�i(BS)���~�T�u�L�����A���i�����ł̓T�u�L�����A�����͎g��Ȃ��j
function H = gen_channel(el_row, el_col, fc, phi_t, the_t, ant_pat)
  
  N_RS   = 1;
%   Ant_el = 16;
%   Carrier_freq = 28e9; %
  
  Ant_Offset = 0;
  
  n_el = el_row*el_col;
  
  H = zeros(N_RS, n_el, 1);
  
  %SC_f = M.Bandwidth/M.N_FFT; % �T�u�L�����A�Ԋu
  
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
    
  % ���M�A���e�i�̍s�E��ԍ�
  mt = repmat(1:el_row,[el_col,1]);  mt = mt(:).';
  nt = repmat(1:el_col,[1,el_row]);  
%   mt = repmat(1:el_col,[el_row,1]);  mt = mt(:).';
%   nt = repmat(1:el_row,[1,el_col]);  

  % �T�u�L�����A�����Ɋg��
  mt = repmat(mt,[1,1,1]);
  nt = repmat(nt,[1,1,1]);  
  
  % ��M�A���e�i�̍s�E��ԍ�
  mr = 1;
  nr = 1;
  % ��M�A���e�i�̕��ʊp�E�V���p
  the_r = 90;
  phi_r = 90;  
  
  % ���M�A���e�i�̕��ʊp�E�V���p�FRS�ʒu
%   the_t = 105; %90; % rand * 90 + 45;  % 60  + 60;
%   phi_t = 90; % rand *  5 + 90; % 120 + 30;
  
  ni = 0;
  while ni < N_RS

    the_t = repmat(the_t,[1,n_el,1]);
    phi_t = repmat(phi_t,[1,n_el,1]);    
    
    h_vec = exp(2j*pi./l.*(((mt-1)+(nt-1).*offset_r).*dt.*cosd(phi_t).*sind(the_t)+((nt-1)+(mt-1).*offset_c).*dt.*cosd(the_t)+ ... % ����͏c�ɃI�t�Z�b�g�^���Ă�(18/10/27)
                            (mr-1).*dr.*cosd(phi_r).*sind(the_r)+(nr-1).*dr.*cosd(the_r)));  
    if ant_pat == 1
      h_vec = sqrt(antenna_3gpp(the_t, phi_t)).* h_vec;
    end
    
    ni = ni + 1;
    H(ni,:,:) = h_vec;  

  end
  
   H = H;  
  
end


%% LOS Channel: ���ʔg
function H = gen_channel_los(tx_pos, rx_pos, rmd, ant_pat)

  n_tx = size(tx_pos,1);
  n_rx = size(rx_pos,1);  
  H = zeros(n_rx, n_tx);
  
  for ni = 1:n_rx
  
    dt = repmat(rx_pos(ni,:),[n_tx,1]) - tx_pos;
        
    % 3GPP �A���e�i�p�^�[�����l��
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

  % Figure�E�C���h�E�̐F
  set(0, 'defaultFigureColor', [1 1 1]);

  % ���̐F�i�v���b�g�G���A�̐F�j
  set(0, 'defaultAxesColor', [1 1 1]);

end

