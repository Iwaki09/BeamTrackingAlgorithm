function [ color ] = mycolor( name )
%MYCOLOR 自作カラーマップ
%   red
%   green
%   blue
%   orange
%   magenta
%   black
%   gray

  name = num2str(name);
  
  color = [0 0 0]/255;
%   if strcmp(name, 'black')   || strcmp(name, 'k'),  color = [10 10 10]/255;      return;	end
%   if strcmp(name, 'red')     || strcmp(name, 'r'),  color = [255,   0,   0]/255;	return;	end
%   if strcmp(name, 'green')   || strcmp(name, 'g'),  color = [102, 204,   0]/255;	return;	end
%   if strcmp(name, 'blue')    || strcmp(name, 'b'),  color = [  0, 102, 255]/255;	return;	end
%   if strcmp(name, 'orange')  || strcmp(name, 'o'),  color = [255, 164,  28]/255;	return;	end
%   if strcmp(name, 'magenta') || strcmp(name, 'm'),  color = [255,   0, 255]/255;	return;	end  
%   if strcmp(name, 'gray')    || strcmp(name, 'a'),  color = [140 140 140]/255;      return;	end  
  
%   if strcmp(name, 'black')   || strcmp(name, 'k') || name==1,  color = [10 10 10]/255;      return;	end
%   if strcmp(name, 'red')     || strcmp(name, 'r') || name==2,  color = [255,   0,   0]/255;	return;	end
%   if strcmp(name, 'green')   || strcmp(name, 'g') || name==3,  color = [102, 204,   0]/255;	return;	end
%   if strcmp(name, 'blue')    || strcmp(name, 'b') || name==4,  color = [  0, 102, 255]/255;	return;	end
%   if strcmp(name, 'orange')  || strcmp(name, 'o') || name==5,  color = [255, 164,  28]/255;	return;	end
%   if strcmp(name, 'magenta') || strcmp(name, 'm') || name==6,  color = [255,   0, 255]/255;	return;	end  
%   if strcmp(name, 'gray')    || strcmp(name, 'a') || name==7,  color = [70 70 70]/255;      return;	end  

  if strcmp(name, 'black')   || strcmp(name, 'k') || strcmp(name, '1'),  color = [10 10 10]/255;      return;	end
  if strcmp(name, 'red')     || strcmp(name, 'r') || strcmp(name, '2'),  color = [255,   0,   0]/255;	return;	end
  if strcmp(name, 'green')   || strcmp(name, 'g') || strcmp(name, '3'),  color = [102, 204,   0]/255;	return;	end
  if strcmp(name, 'blue')    || strcmp(name, 'b') || strcmp(name, '4'),  color = [  0, 102, 255]/255;	return;	end
  if strcmp(name, 'orange')  || strcmp(name, 'o') || strcmp(name, '5'),  color = [255, 164,  28]/255;	return;	end
  if strcmp(name, 'magenta') || strcmp(name, 'm') || strcmp(name, '6'),  color = [255,   0, 255]/255;	return;	end  
  if strcmp(name, 'gray')    || strcmp(name, 'a') || strcmp(name, '7'),  color = [ 70,  70,  70]/255; return;	end
  if strcmp(name, 'wgray')   || strcmp(name, 'a') || strcmp(name, '8'),  color = [200, 200, 200]/255; return;	end
  if strcmp(name, 'white')   || strcmp(name, 'w') || strcmp(name, '9'),  color = [255, 255, 255]/255; return;	end

end

