function varargout = match_signs_gui(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @match_signs_gui_OpeningFcn, ...
    'gui_OutputFcn',  @match_signs_gui_OutputFcn, ...
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

function match_signs_gui_OpeningFcn(hObject, eventdata, handles, varargin)
movegui(gcf,'center');
handles.output = hObject;
guidata(hObject, handles);

function varargout = match_signs_gui_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function popupmenu1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function start_match_signs_Callback(hObject, eventdata, handles)
% 匹配不同语言中特色的连通区符号
% 选择需要进行语种识别的图像
cla(handles.axes1);
cla(handles.axes2);
set(handles.edit1,'string','');
[fn,pn,fi]=uigetfile('*.png;*.jpg;*.bmp','选择图片');
image=imread([pn fn]);
axes(handles.axes1);imshow(image);
[x,y,c]=ginput(2);
if c==1
    image=imcrop(image,[min(x(1),x(2)),min(y(1),y(2)),abs(x(2)-x(1)),abs(y(2)-y(1))]);
    imwrite(image,'location_pic.jpg');
end
axes(handles.axes2);imshow(image);

%tic;
% 输入RGB图像，转化成灰度图
if size(image,3)==3
    image=rgb2gray(image);
end

% 转化成二值图像
threshold = graythresh(image); %求二值化时的阈值
image =~im2bw(image,threshold);

sign=[ ]; %新建空数组
re_line=image; %re_line为剩余的未识别的字符

% 加载模板
load sign_templates
global sign_templates
% language存储每种语言识别出的连通区数量
lan=[];
% 计算模板中符号的数量
num_signs=size(sign_templates,2);
count=0;
while 1
    % 'segment_lines'函数用于按行分割文本
    [first_line re_line]=segment_lines(re_line);
    img=first_line;
    % bwlabel标记并算连通区,C为连通区的图像,NC为连通区的个数
    [C NC] = bwlabel(img);
    for n=1:NC
        [row,column] = find(C==n);%第几个连通区C就会标记为多少，row为该连通区所在点的列号，column为行号
        % 取出符号
        min_C=img(min(row):max(row),min(column):max(column));% 取出row\column的最小值和最大值，用最小的矩形框框住连通区
        % 统一模板尺寸：36*52
        C_resize=imresize(min_C,[36 52]);
        %imwrite(C_resize,'A.bmp');
        % 用'read_language'函数读出图像所属的语种
        language=read_language(C_resize,num_signs);
        if ~isempty(language)
            count=count+1;
            lan(1,count)=language(1,2);%language（1,2）记录识别出的语种的英文首字母
        end
    end
    % 如果剩余行为空，跳出循环
    if isempty(re_line)
        break
    end
end
%找出lan中出现频率最多的数字，将数字与ASCII码进行对比，即为最有可能的语种
table=tabulate(lan);
[F,]=max(table(:,2));
L=find(table(:,2)==F);
result=table(L,1);
if(result(1,1)==65)
    c='阿拉伯语';
    system('tesseract location_pic.jpg -l ara -psm 3 result');
elseif(result(1,1)==66)
    c='缅甸语';
    msgbox('请用ABBYY识别缅甸语');
elseif(result(1,1)==72)
    c='印地语';
    system('tesseract location_pic.jpg -l hin -psm 3 result');
elseif(result(1,1)==75)
    c='韩语';
    system('tesseract location_pic.jpg -l kor -psm 3 result');
elseif(result(1,1)==76)
    c='老挝语';
    msgbox('请用ABBYY识别老挝语');
elseif(result(1,1)==82)
    c='俄语';
    system('tesseract location_pic.jpg -l rus -psm 3 result');
elseif(result(1,1)==84)
    c='泰语';
    system('tesseract location_pic.jpg -l tha -psm 3 result');
elseif(result(1,1)==90)
    c='藏语';
    msgbox('请用ABBYY识别藏语');
else
    msgbox('系统尚不能识别该语种');
end
set(handles.edit1,'string',c);
%toc
warning off all;

function show_result_Callback(hObject, eventdata, handles)
winopen('result.txt');

function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pushbutton2_Callback(hObject, eventdata, handles)
h=gcf;
main_gui;
close(h)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
