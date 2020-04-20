function language = read_language( image, num_signs )
% ����ģ�������ͼ����������
% imageΪԭͼ�ָ������ͨ�� ��num_signsΪ���еķ���ģ������

global sign_templates
sum_sim=[ ];% ������

% ���㵱ǰ��ͨ����ģ�����ÿһ��ģ������Ƴ̶�
for n=1:num_signs
    similarity=corr2(sign_templates{1,n},image);
    sum_sim=[sum_sim similarity];
end

% �����ƶ�����ģ����ֵ����No
if(abs(max(sum_sim))>0.6)
    No=find(sum_sim==max(sum_sim));
else
    No=0;
end

% �������������
if No>=1&&No<=13
    language=' Arabic ';
elseif No>=14&&No<=23
    language=' Burma ';
elseif No>=24&&No<=43
    language=' Hindi ';
elseif No>=44&&No<=55
    language=' Korea ';
elseif No>=56&&No<=77
    language=' Laos ';
elseif No>=78&&No<=90
    language=' Russia ';
elseif No>=91&&No<=116
    language=' Thailand ';
elseif No>=117&&No<=141
    language=' Zang ';
elseif No==0
    language='';
end