function img_out=cut(img_in)
[r c]=find(img_in);
img_out=img_in(min(r):max(r),min(c):max(c)); % �ָ�ͼ��
end