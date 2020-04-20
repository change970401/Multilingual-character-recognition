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
% ƥ�䲻ͬ��������ɫ����ͨ������
% ѡ����Ҫ��������ʶ���ͼ��
cla(handles.axes1);
cla(handles.axes2);
set(handles.edit1,'string','');
[fn,pn,fi]=uigetfile('*.png;*.jpg;*.bmp','ѡ��ͼƬ');
image=imread([pn fn]);
axes(handles.axes1);imshow(image);
[x,y,c]=ginput(2);
if c==1
    image=imcrop(image,[min(x(1),x(2)),min(y(1),y(2)),abs(x(2)-x(1)),abs(y(2)-y(1))]);
    imwrite(image,'location_pic.jpg');
end
axes(handles.axes2);imshow(image);

%tic;
% ����RGBͼ��ת���ɻҶ�ͼ
if size(image,3)==3
    image=rgb2gray(image);
end

% ת���ɶ�ֵͼ��
threshold = graythresh(image); %���ֵ��ʱ����ֵ
image =~im2bw(image,threshold);

sign=[ ]; %�½�������
re_line=image; %re_lineΪʣ���δʶ����ַ�

% ����ģ��
load sign_templates
global sign_templates
% language�洢ÿ������ʶ�������ͨ������
lan=[];
% ����ģ���з��ŵ�����
num_signs=size(sign_templates,2);
count=0;
while 1
    % 'segment_lines'�������ڰ��зָ��ı�
    [first_line re_line]=segment_lines(re_line);
    img=first_line;
    % bwlabel��ǲ�����ͨ��,CΪ��ͨ����ͼ��,NCΪ��ͨ���ĸ���
    [C NC] = bwlabel(img);
    for n=1:NC
        [row,column] = find(C==n);%�ڼ�����ͨ��C�ͻ���Ϊ���٣�rowΪ����ͨ�����ڵ���кţ�columnΪ�к�
        % ȡ������
        min_C=img(min(row):max(row),min(column):max(column));% ȡ��row\column����Сֵ�����ֵ������С�ľ��ο��ס��ͨ��
        % ͳһģ��ߴ磺36*52
        C_resize=imresize(min_C,[36 52]);
        %imwrite(C_resize,'A.bmp');
        % ��'read_language'��������ͼ������������
        language=read_language(C_resize,num_signs);
        if ~isempty(language)
            count=count+1;
            lan(1,count)=language(1,2);%language��1,2����¼ʶ��������ֵ�Ӣ������ĸ
        end
    end
    % ���ʣ����Ϊ�գ�����ѭ��
    if isempty(re_line)
        break
    end
end
%�ҳ�lan�г���Ƶ���������֣���������ASCII����жԱȣ���Ϊ���п��ܵ�����
table=tabulate(lan);
[F,]=max(table(:,2));
L=find(table(:,2)==F);
result=table(L,1);
if(result(1,1)==65)
    c='��������';
    system('tesseract location_pic.jpg -l ara -psm 3 result');
elseif(result(1,1)==66)
    c='�����';
    msgbox('����ABBYYʶ�������');
elseif(result(1,1)==72)
    c='ӡ����';
    system('tesseract location_pic.jpg -l hin -psm 3 result');
elseif(result(1,1)==75)
    c='����';
    system('tesseract location_pic.jpg -l kor -psm 3 result');
elseif(result(1,1)==76)
    c='������';
    msgbox('����ABBYYʶ��������');
elseif(result(1,1)==82)
    c='����';
    system('tesseract location_pic.jpg -l rus -psm 3 result');
elseif(result(1,1)==84)
    c='̩��';
    system('tesseract location_pic.jpg -l tha -psm 3 result');
elseif(result(1,1)==90)
    c='����';
    msgbox('����ABBYYʶ�����');
else
    msgbox('ϵͳ�в���ʶ�������');
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
