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
[fn,pn,fi]=uigetfile('*.png;*.jpg;*.bmp','选择图片');
I=imread([pn fn]);
axes(handles.axes1);%figure;
imshow(I);%title('原始图像');
%大致定位文本区
[x,y,c]=ginput(2);
if c==1
    I=imcrop(I,[min(x(1),x(2)),min(y(1),y(2)),abs(x(2)-x(1)),abs(y(2)-y(1))]);
end

% 预处理
bw=rgb2gray(I);               % 灰度化
bw=im2bw(I,graythresh(bw));   % 二值化
bw=double(bw);
bw=~bw;
BW=edge(bw,'canny',0.05);          % 提取边缘
%imshow(BW);title('canny 边界图像');

% 得到Hough矩阵和峰值点图像
[H,T,R]=hough(BW);            % H为hough变换矩阵，T为角度，R为距离精度((t,r)构成了hough空间的一个点，相当于（x,y))
%figure,imshow(H,[],'XData',T,'YData',R,'InitialMagnification','fit');
%xlabel('\theta'),ylabel('\rho');
%axis on, axis normal,hold on; % hold on:保持当前的窗口
% 在Hough矩阵图像中寻找前4个大于最大值0.3倍的峰值
P=houghpeaks(H,4,'threshold',ceil(0.3*max(H(:))));
% 由行、列索引转换成实际坐标
%x=T(P(:,2)); y = R(P(:,1));
% 在Hough矩阵中标出峰值位置
%plot(x,y,'s','color','white');
% 合并距离小于30的线段，丢弃所有长度小于20的直线段
lines=houghlines(BW,T,R,P,'FillGap',30,'MinLength',20);%数值可调
%figure,imshow(BW),title('直线标识图像');
max_len = 0;
hold on;

% 找出图像中最长的线段，确定旋转角
for k=1:length(lines)
    xy=[lines(k).point1;lines(k).point2];
    % 标出线段
    %plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    % 标出线段的起始和终端点
    %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
    % 确定最长的线段
    len=norm(lines(k).point1-lines(k).point2);%返回矩阵的最大奇异值
    Len(k)=len;
    if (len>max_len)
        max_len=len;
        xy_long=xy;
    end
end

% 强调最长的部分
%plot(xy_long(:,1),xy_long(:,2),'LineWidth',2,'Color','blue');
[L1 Index1]=max(Len(:));

% 最长线段的起始和终止点
x1=[lines(Index1).point1(1) lines(Index1).point2(1)];
y1=[lines(Index1).point1(2) lines(Index1).point2(2)];

% 求得线段的斜率
K1=-(lines(Index1).point1(2)-lines(Index1).point2(2))/...
    (lines(Index1).point1(1)-lines(Index1).point2(1));
angle=atan(K1)*180/pi;
bw=imrotate(bw,-angle,'bilinear');% imrotate是逆时针的,所以取一个负号
bw=~bw;
axes(handles.axes3);%figure;
imshow(bw);
%imwrite(bw,'倾斜校正图像.jpg');% 保存结果
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
