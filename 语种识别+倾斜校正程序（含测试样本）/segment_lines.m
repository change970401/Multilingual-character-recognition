function [first_line re_line]=segment_lines(re_image)
% 分行
%first_line:第一行;re_line:剩余行

re_image=cut(re_image);
num=size(re_image,1);
for s=1:num
    if sum(re_image(s,:))==0
        nm=re_image(1:s-1, :); % 第一行矩阵
        rm=re_image(s:end, :); % 剩余行矩阵
        first_line=cut(nm);
        re_line=cut(rm);
        break
    else
        first_line=re_image; % 只有一行
        re_line=[ ];
    end
end