function [first_line re_line]=segment_lines(re_image)
% ����
%first_line:��һ��;re_line:ʣ����

re_image=cut(re_image);
num=size(re_image,1);
for s=1:num
    if sum(re_image(s,:))==0
        nm=re_image(1:s-1, :); % ��һ�о���
        rm=re_image(s:end, :); % ʣ���о���
        first_line=cut(nm);
        re_line=cut(rm);
        break
    else
        first_line=re_image; % ֻ��һ��
        re_line=[ ];
    end
end