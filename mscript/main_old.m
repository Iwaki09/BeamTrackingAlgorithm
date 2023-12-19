
  % v_01からv_02にスピードが変わる
  v_01 = [45]; % 45 50 60 40 50 40 55 45 55 40 60];
  v_02 = [45]; % 60 60 50 50 40 55 40 55 45 60 40];
  
  SNR_sch = [];
  SNR_opt = [];
  SNR_pro = [];
  
  for nn = 1:numel(v_01)
    
    [S, O, P] = vc_mfh(v_01(nn),v_02(nn),1);
    
    SNR_sch = [SNR_sch; S]; % Beam Sweeping: N. Nonaka, K. Muraoka, T. Okuyama, S. Suyama, Y. Okumura, T. Asai, and Y. Matsumura, "28 ghz-band experimental trial at 283 km/h using the shinkansen for 5g evolution," in 2020 IEEE 91st Vehicular Technology Conference (VTC2020-Spring), May 2020, pp. 1–5. 
    SNR_opt = [SNR_opt; O]; % Optimal (SVD)
    SNR_pro = [SNR_pro; P]; % Proposed (Geometry-based)
    
  end
  
statistics_( SNR_pro, 0.01, 1, 'cdf', 'lin', mycolor('r'), '-', 0, 1);
statistics_( SNR_sch, 0.01, 1, 'cdf', 'lin', mycolor('g'), '-', 0, 1);
statistics_( SNR_opt, 0.01, 1, 'cdf', 'lin', mycolor('b'), '-', 0, 1);
legend('Proposed', 'Search', 'Optimal');
xlabel('SNR [dB]');
ylabel('CDF');
hold off;