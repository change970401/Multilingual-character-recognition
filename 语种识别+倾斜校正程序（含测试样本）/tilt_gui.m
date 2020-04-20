function varargout = tilt_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @tilt_gui_OpeningFcn, ...
    'gui_OutputFcn',  @tilt_gui_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function tilt_gui_OpeningFcn(hObject, eventdata, handles, varargin)
movegui(gcf,'center');
handles.output = hObject;
guidata(hObject, handles);

function varargout = tilt_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


function start_tilt_correct_Callback(hObject, eventdata, handles)
cla(handles.axes1);
cla(handles.axes3);
[fn,pn,fi]=uigetfile('*.png;*.jpg;*.bmp','ѡ��ͼƬ');
I=imread([pn fn]);
axes(handles.axes1);%figure;
imshow(I);%title('ԭʼͼ��');
%���¶�λ�ı���
[x,y,c]=ginput(2);
if c==1
    I=imcrop(I,[min(x(1),x(2)),min(y(1),y(2)),abs(x(2)-x(1)),abs(y(2)-y(1))]);
end

% Ԥ����
bw=rgb2gray(I);               % �ҶȻ�
bw=im2bw(I,graythresh(bw));   % ��ֵ��
bw=double(bw);
bw=~bw;
BW=edge(bw,'canny',0.05);          % ��ȡ��Ե
%imshow(BW);title('canny �߽�ͼ��');

% �õ�Hough����ͷ�ֵ��ͼ��
[H,T,R]=hough(BW);            % HΪhough�任����TΪ�Ƕȣ�RΪ���뾫��((t,r)������hough�ռ��һ���㣬�൱�ڣ�x,y))
%figure,imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
%xlabel('\theta'),ylabel('\rho');
%axis on, axis normal,hold on; % hold on:���ֵ�ǰ�Ĵ���
% ��Hough����ͼ����Ѱ��ǰ4���������ֵ0.3���ķ�ֵ
P=houghpeaks(H,4,'threshold',ceil(0.3*max(H(:))));
% ���С�������ת����ʵ������
%x=T(P(:,2)); y = R(P(:,1));
% ��Hough�����б����ֵλ��
%plot(x,y,'s','color','white');
% �ϲ�����С��30���߶Σ��������г���С��20��ֱ�߶�
lines=houghlines(BW,T,R,P,'FillGap',30,'MinLength',20);%��ֵ�ɵ�
%figure,imshow(BW),title('ֱ�߱�ʶͼ��');
max_len = 0;
hold on;

% �ҳ�ͼ��������߶Σ�ȷ����ת��
for k=1:length(lines)
    xy=[lines(k).point1;lines(k).point2];
    % ����߶�
    %plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    % ����߶ε���ʼ���ն˵�
    %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    % ȷ������߶�
    len=norm(lines(k).point1-lines(k).point2);%���ؾ�����������ֵ
    Len(k)=len;
    if (len>max_len)
        max_len=len;
        xy_long=xy;
    end
end

% ǿ����Ĳ���
%plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue');
[L1 Index1]=max(Len(:));

% ��߶ε���ʼ����ֹ��
x1=[lines(Index1).point1(1) lines(Index1).point2(1)];
y1=[lines(Index1).point1(2) lines(Index1).point2(2)];

% ����߶ε�б��
K1=-(lines(Index1).point1(2)-lines(Index1).point2(2))/...
    (lines(Index1).point1(1)-lines(Index1).point2(1));
angle=atan(K1)*180/pi;
bw=imrotate(bw,-angle,'bilinear');% imrotate����ʱ���,����ȡһ������
bw=~bw;
axes(handles.axes3);%figure;
imshow(bw);
%imwrite(bw,'��бУ��ͼ��.jpg');% ������
[x,y,c]=ginput(2);
if c==1
    bw=imcrop(bw,[min(x(1),x(2)),min(y(1),y(2)),abs(x(2)-x(1)),abs(y(2)-y(1))]);
    imwrite(bw,'location_pic.jpg');
end

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function OCR_chi_Callback(hObject, eventdata, handles)
system('tesseract location_pic.jpg -l chi_sim -psm 3 result');
winopen('result.txt');

function OCR_eng_Callback(hObject, eventdata, handles)
system('tesseract location_pic.jpg -l eng -psm 3 result');
winopen('result.txt');
