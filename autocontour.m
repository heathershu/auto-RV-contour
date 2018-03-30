function varargout = autocontour(varargin)
% AUTOCONTOUR MATLAB code for autocontour.fig
%      AUTOCONTOUR, by itself, creates a new AUTOCONTOUR or raises the existing
%      singleton*.
%
%      H = AUTOCONTOUR returns the handle to a new AUTOCONTOUR or the handle to
%      the existing singleton*.
%
%      AUTOCONTOUR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AUTOCONTOUR.M with the given input arguments.
%
%      AUTOCONTOUR('Property','Value',...) creates a new AUTOCONTOUR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before autocontour_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to autocontour_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help autocontour

% Last Modified by GUIDE v2.5 13-Mar-2018 11:18:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @autocontour_OpeningFcn, ...
                   'gui_OutputFcn',  @autocontour_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before autocontour is made visible.
function autocontour_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to autocontour (see VARARGIN)

% Choose default command line output for autocontour
handles.output = hObject;
handles.axes1.XTick = '';
handles.axes1.YTick = '';


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes autocontour wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = autocontour_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function menu_file_import_Callback(hObject, eventdata, handles)
% Open image folder
folder = uigetdir('Select a folder with images');
if ~folder
    return
end
% Call load images to load image stack & increase resolution if res_tf = 1 
[images, hires_images, info] = loadimages(folder);
% Sort image stack so images are in order of acquisition number
handles.images = sortImages(images, info);
handles.originalImages = handles.images;
handles.hires_images = sortImages(hires_images, info);
% Get mm per square pixel
handles.pixelmm = info(1).data.PixelSpacing(1)^2;
% Plot first slice
imagesc(handles.axes1, handles.images(:,:,1)); colormap(gray); axis off;
handles.currentImg = 1;
handles.NumImages = size(handles.images,3);
handles.displayedImg.String = strcat(num2str(1), '/', num2str(handles.NumImages));
handles.ROIs = zeros(size(handles.images));
handles.areas = zeros(size(handles.images,3));
% Initialize slider to go through images
initializeSlider(handles)
% Make options visibile
handles.menu_edit.Enable = 'on';
handles.menu_image.Enable = 'on';
handles.imgslider.Visible = 'on';
handles.region_grow.Visible = 'on';
guidata(hObject,handles);


%--- Executes on slider movement.
function imgslider_Callback(hObject, eventdata, handles)
img = round(hObject.Value);

imagesc(handles.axes1, handles.images(:,:,img)); colormap(gray); axis off;
handles.currentImg = img;
handles.displayedImg.String = strcat(num2str(img), '/', num2str(handles.NumImages));
% Get ROI
roi = handles.ROIs(:,:,handles.currentImg);
boundary = bwboundaries(roi);
hold on
visboundaries(boundary)
hold off
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function imgslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --------------------------------------------------------------------
function menu_edit_Callback(hObject, eventdata, handles)
% hObject    handle to menu_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_edit_crop_Callback(hObject, eventdata, handles)
% Get user selected rectangle for cropping
r = round(getrect(handles.axes1));
xmin = r(1); ymin = r(2); width = r(3); height = r(4);
% Initialize cropped images variable
handles.cropped_images = zeros(height+1, width+1, handles.NumImages);
handles.ROIs = zeros(height+1, width+1, handles.NumImages);

% Crop images
for i = 1:handles.NumImages
   handles.cropped_images(:,:,i) = handles.images(ymin:ymin+height, ...
       xmin:xmin+width, i);
end
% Plot cropped image
imagesc(handles.cropped_images(:,:,handles.currentImg)); axis off;
% Confirm the crop
choice = questdlg('Confirm crop?', 'Crop', 'Yes', 'No','Yes');
switch choice
    case 'Yes'
        handles.images = handles.cropped_images;
        imagesc(handles.images(:,:,handles.currentImg)); axis off;
    case 'No'
        imagesc(handles.images(:,:,handles.currentImg)); axis off;
end
guidata(hObject,handles);

% --------------------------------------------------------------------
function menu_image_resolution_Callback(hObject, eventdata, handles)
if strcmp(handles.menu_image_resolution.Label, '2x Resolution')
    handles.menu_image_resolution.Label = 'Original Resolution';
    handles.images = handles.hires_images;
    handles.pixelmm = handles.pixelmm / 2;
    imagesc(handles.images(:,:,handles.currentImg)); axis off;

else
    handles.menu_image_resolution.Label = '2x Resolution';
    handles.images = handles.originalImages;
    handles.pixelmm = handles.pixelmm * 2;  
    imagesc(handles.images(:,:,handles.currentImg)); axis off;       
end
guidata(hObject,handles);
% --------------------------------------------------------------------
function menu_image_Callback(hObject, eventdata, handles)
% hObject    handle to menu_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_image_enhance_contrast_Callback(hObject, eventdata, handles)
h = imellipse(handles.axes1);
mask = h.createMask;
h.delete;
[x,y] = find(mask);
vals = handles.images(x,y,handles.currentImg);
avg = mean(vals(:));
stdev = std(vals(:))*5;
m = max(max(handles.images(:,:,handles.currentImg)));

for i = 1:handles.NumImages
    tmp = handles.images(:,:,i);
    tmp = m./(1 + exp(-(tmp - avg)/stdev));
    handles.images(:,:,i) = tmp;
end
for i = 1:handles.NumImages
    tmp = handles.originalImages(:,:,i);
    tmp = m./(1 + exp(-(tmp - avg)/stdev));
    handles.originalImages(:,:,i) = tmp;
end
for i = 1:handles.NumImages
    tmp = handles.hires_images(:,:,i);
    tmp = m./(1 + exp(-(tmp - avg)/stdev));
    handles.hires_images(:,:,i) = tmp;
end

imagesc(handles.axes1, handles.images(:,:,handles.currentImg)); colormap(gray); axis off;
guidata(hObject,handles);


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_file_exportROIs_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_exportROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_edit_drawROI_Callback(hObject, eventdata, handles)
[mask, xi, yi] = roipoly();
hold on
fill(xi,yi,[0.69 0 0])
hold off
% Confirm the crop
choice = questdlg('Confirm ROI?', 'ROI', 'Yes', 'No','Yes');
switch choice
    case 'Yes'
        handles.images(:,:,handles.currentImg) = getimage(handles.axes1);
        handles.ROIs(:,:,handles.currentImg) = mask;
        handles.areas(handles.currentImg) = sum(mask(:))*handles.pixelmm(1);
        imagesc(handles.images(:,:,handles.currentImg)); axis off;
        boundary = bwboundaries(mask);
        hold on
        visboundaries(boundary)
        hold off
    case 'No'
        imagesc(handles.images(:,:,handles.currentImg)); axis off;
end
% Check if all ROIs are done
ROIs_done = 0;
for i = 1:handles.NumImages
    roi = handles.ROIs(:,:,i);
   if sum(roi(:)) > 0
       ROIs_done = ROIs_done + 1;
   end
end
if ROIs_done == handles.NumImages
    handles.menu_file_exportROIs.Enable = 'on';
end
guidata(hObject,handles);


% --------------------------------------------------------------------
function edit_menu_region_grow_Callback(hObject, eventdata, handles)
h = imellipse(handles.axes1);
mask = h.createMask;
h.delete;
[x,y] = find(mask);
vals = handles.images(x,y,handles.currentImg);

guidata(hObject,handles);
