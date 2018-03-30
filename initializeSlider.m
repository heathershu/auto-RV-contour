function initializeSlider(handles)
numImages = handles.NumImages;
handles.imgslider.Value =  1;
handles.imgslider.Max = numImages;
handles.imgslider.Min = 1;
handles.imgslider.SliderStep = [1/(numImages-1) , 10/(numImages-1)];
end
