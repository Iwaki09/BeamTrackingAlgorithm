function y = dbm2real(u)
%DBM2REAL [dBm] �� [W]
  y=10.^((u-30)/10);
end
