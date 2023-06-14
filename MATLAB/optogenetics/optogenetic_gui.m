%Annika Rings March 2018
%graphical user interface for controlling optogenetic lights

function varargout = optogenetic_gui(varargin)
% OPTOGENETIC_GUI MATLAB code for optogenetic_gui.fig
%      OPTOGENETIC_GUI, by itself, creates a new OPTOGENETIC_GUI or raises the existing
%      singleton*.
%
%      H = OPTOGENETIC_GUI returns the handle to a new OPTOGENETIC_GUI or the handle to
%      the existing singleton*.
%
%      OPTOGENETIC_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTOGENETIC_GUI.M with the given input arguments.
%
%      OPTOGENETIC_GUI('Property','Value',...) creates a new OPTOGENETIC_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before optogenetic_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to optogenetic_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help optogenetic_gui

% Last Modified by GUIDE v2.5 03-Aug-2021 11:15:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @optogenetic_gui_OpeningFcn, ...
    'gui_OutputFcn',  @optogenetic_gui_OutputFcn, ...
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


% --- Executes just before optogenetic_gui is made visible.
function optogenetic_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to optogenetic_gui (see VARARGIN)

% Choose default command line output for optogenetic_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes optogenetic_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = optogenetic_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
num_reps = str2double(get(hObject,'String'));
hObject.UserData=num_reps;
if isnan(num_reps)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return

end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end







% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
stimpingreen=str{val};

hObject.UserData=stimpingreen;


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end








% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Determine the selected data set.
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
lamp=str{val};

hObject.UserData=lamp;

% Save the handles structure.



% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
comport = get(hObject,'String');
hObject.UserData=comport;



% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
light_on = str2double(get(hObject,'String'));
hObject.UserData=light_on;
if isnan(light_on)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return

end


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
light_off = str2double(get(hObject,'String'));
hObject.UserData=light_off;
if isnan(light_off)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return

end


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
stimpinred=str{val};

hObject.UserData=stimpinred;


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
%frequency=str2double(get(hObject,'String'));
frequency = str2double(get(hObject,'String'));
hObject.UserData=frequency;
if isnan(frequency)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return

end






% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
on_time = str2double(get(hObject,'String'));
hObject.UserData=on_time;
if isnan(on_time)
    errordlg('You must enter a numeric value','Invalid Input','modal')
    uicontrol(hObject)
    return

end



% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
hObject.UserData = get(hObject,'Value');



% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setdefaults(handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

disp('run button pressed')
disp('Did you turn the backlight on?')
IRonbutton=findobj('Tag','IR_on');
if get(IRonbutton,'userdata')

set(gcbo,'userdata',1);
else

   default_comport = '/dev/ttyACM0';
    com = findobj('Tag','edit2');


if isempty(com.UserData)
    comport = default_comport;
    set(handles.edit2, 'String', default_comport);
else
    comport = com.UserData;
end
disp 'com port set to:';
disp (comport);
arduino = serial(comport, 'BaudRate', 115200);
fopen(arduino);
pause(1);
mainfunction(handles,arduino);
fclose(arduino);
end

function setdefaults(handles)

default_stimpin_green = 24;
default_stimpin_red =28;
default_stimpin_opto = 22;
default_stimpin_IR = 4;
default_comport = '/dev/ttyACM0';
default_freq = 50;
default_onTime = 10;
default_lighton = 30;
default_lightoff = 30;
default_nreps = 1;
default_lamp = 'optogenetic backlight';

set(handles.edit1, 'String', default_nreps);
set(handles.edit1, 'UserData', default_nreps);
set(handles.edit2, 'String', default_comport);
set(handles.edit2, 'UserData', default_comport);
set(handles.edit3, 'String', default_lighton);
set(handles.edit3, 'UserData', default_lighton);
set(handles.edit4, 'String', default_lightoff);
set(handles.edit4, 'UserData', default_lightoff);
set(handles.edit5, 'String', default_freq);
set(handles.edit5, 'UserData', default_freq);
set(handles.edit6, 'String', default_onTime);
set(handles.edit6, 'UserData', default_onTime);
%set(handles.popupmenu2, 'String', default_lamp);
set(handles.popupmenu2, 'UserData', default_lamp);
% set(handles.popupmenu1, 'String', default_stimpin_green);
set(handles.popupmenu1, 'UserData', default_stimpin_green);
%set(handles.popupmenu3, 'String', default_stimpin_red);
set(handles.popupmenu3, 'UserData', default_stimpin_red);
set(handles.opto_backlight_pin, 'UserData', default_stimpin_opto);
set(handles.IR_backlight_pin, 'UserData', default_stimpin_IR);

function mainfunction(handles,arduino)

oldpointer = get(handles.figure1, 'pointer');
set(handles.figure1, 'pointer', 'watch')
drawnow;
default_stimpin_green = 24;
default_stimpin_red =28;
default_stimpin_opto = 22;
default_stimpin_IR = 4;

f = findobj('Tag','edit5');
freq1 = f.UserData;
ont = findobj('Tag','edit6');
onTime1 = ont.UserData;

on = findobj('Tag','edit3');
lighton = on.UserData;
off = findobj('Tag','edit4');
lightoff = off.UserData;
cyc = findobj('Tag','edit1');
numcycl = cyc.UserData;
lamp = findobj('Tag','popupmenu2');
lamp = lamp.UserData;
st = findobj('Tag','popupmenu1');
stimpingreen = st.UserData;
stred = findobj('Tag','popupmenu3');
stimpinred = stred.UserData;
stopto = findobj('Tag','opto_backlight_pin');
stimpinoptobacklight = stopto.UserData;
stIR = findobj('Tag','IR_backlight_pin');
stimpinIRbacklight = str2double(stIR.UserData);
first = findobj('Tag','checkbox2');
off_first = first.UserData;
lightonrounds=floor(lighton);
lightonrest=lighton-lightonrounds;
lightoffrounds=floor(lightoff);
lightoffrest=lightoff-lightoffrounds;



switch lamp;
    case 'green' % User selects green lamp.
        stimpin=str2double(stimpingreen);
        if isnan (stimpin)
            stimpin = default_stimpin_green;

        end
    case 'red' % User selects red lamp.
        stimpin = str2double(stimpinred);
        if isnan (stimpin)
            stimpin = default_stimpin_red;


        end
    case 'optogenetic backlight' % User selects red lamp.
        stimpin = str2double(stimpinoptobacklight);
        if isnan (stimpin)
            stimpin = default_stimpin_opto;


        end

end
if isnan(stimpinIRbacklight)
    stimpinIRbacklight = default_stimpin_IR;
end
disp 'selected lamp:';
disp (lamp);
disp 'frequency (Hz) set to:';
disp (freq1);
disp 'on Time (ms) set to:';
disp (onTime1);

disp 'light will be on for (s):';
disp (lighton);
disp 'light will be off for (s):';
disp (lightoff);
disp 'number of cycles:';
disp (numcycl);
disp 'StimPin:';
disp (stimpin);

%original arduino script from  Kay
% arduino = serial(comport, 'BaudRate', 115200);
% fopen(arduino);
%pause(1);
% enable pausing
%oldPauseState = pause('on');
% all IR illumination off
pin=2; state=false; fwrite(arduino, [132, pin, state], 'uint8');

% set continuous pulses, with 'onTime' ms on time @ 'freq' Hz
% nPulses = 0; fwrite(arduino, [131, typecast(uint32(nPulses), 'uint8')], 'uint8');
onTime  = onTime1; fwrite(arduino, [130, typecast(uint32(onTime/0.1), 'uint8')], 'uint8');
freq    = freq1; fwrite(arduino, [129, typecast(uint32(freq/0.1), 'uint8')], 'uint8');



stopbutton=findobj('Tag','stopbutton');
set(stopbutton,'userdata',0);

%turning the light on
% turn on TTL 2 (arduino pin 2)

%This is pin2 on the arduino board and is connected to the infrared
%indicator LED
if off_first

    disp 'light will be off first';


    for n=1:numcycl
        set(handles.edit8, 'String', n);

        %turn light off
        stimPin=stimpin-21; fwrite(arduino, stimPin+24, 'uint8');
        %turn infrared off
        pin=2; state=false; fwrite(arduino, [132, pin, state], 'uint8');
        %wait for specified off time - leave light off
        offround=0;
        while offround<lightoffrounds
            if get(stopbutton,'userdata') % stop condition
                break;
            end
            pause(1);
            offround=offround+1;
        end
        pause (lightoffrest);
        pin=2; state=true; fwrite(arduino, [132, pin, state], 'uint8');
        %this turns the selected light on
        stimPin=stimpin-21; fwrite(arduino, stimPin, 'uint8');
        %wait for the specified on time - leave light on
        onround=0;
        while onround<lightonrounds
            if get(stopbutton,'userdata') % stop condition
                break;
            end
            pause(1);
            onround=onround+1;
        end
        pause (lightonrest);
    end
else
    disp 'light will be on first';

    for n=1:numcycl
        set(handles.edit8, 'String', n);
        pin=2; state=true; fwrite(arduino, [132, pin, state], 'uint8');
        %this turns the selected light on
        stimPin=stimpin-21; fwrite(arduino, stimPin, 'uint8');
        %wait for the specified on time - leave light on
        onround=0;
        while onround<lightonrounds
            if get(stopbutton,'userdata') % stop condition
                break;
            end
            pause(1);
            onround=onround+1;
        end
        pause (lightonrest);
        %turn light off
        stimPin=stimpin-21; fwrite(arduino, stimPin+24, 'uint8');
        %turn infrared off
        pin=2; state=false; fwrite(arduino, [132, pin, state], 'uint8');
        %wait for specified off time - leave light off
        offround=0;

        while offround<lightoffrounds
            if get(stopbutton,'userdata') % stop condition
                break;
            end
            pause(1);
            offround=offround+1;
        end
        pause (lightoffrest);

    end
    runbutton=findobj('Tag','pushbutton1');
    set(runbutton,'userdata',0);

end
%turn everything off
%is this necessary? if not, delete
fwrite(arduino, 127, 'uint8');

% turn off illumination LED 2
pin=2; state=false; fwrite(arduino, [132, pin, state], 'uint8');

% quit
%fclose(arduino);
%pause(oldPauseState);
set(handles.figure1, 'pointer', oldpointer)

%this is a test function
function waitsignal(handles)
oldpointer = get(handles.figure1, 'pointer');
set(handles.figure1, 'pointer', 'watch')
drawnow;


for n=1:10
    disp 'now you are on cycle number:';
    disp (n);
    set(handles.edit8, 'String', n);
    pause(1);

end

set(handles.figure1, 'pointer', oldpointer)




% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(gcbo,'userdata',1)
runbutton=findobj('Tag','pushbutton1');
set(runbutton,'userdata',0);



% --- Executes on button press in IR_on.
function IR_on_Callback(hObject, eventdata, handles)
% hObject    handle to IR_on (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set (gcbo,'userdata',1);
IRlight_on(handles);

function  IRlight_on(handles)
stopbuttonIR=findobj('Tag','IR_off');
set(stopbuttonIR,'userdata',0);
runbutton=findobj('Tag','pushbutton1');
set(runbutton,'userdata',0);



disp('IR light on')
default_comport = '/dev/ttyACM0';
com = findobj('Tag','edit2');
if isempty(com.UserData)
    comport = default_comport;
    set(handles.edit2, 'String', default_comport);
else
    comport = com.UserData;
end
default_stimpin_IR = 3;
stIR = findobj('Tag','IR_backlight_pin');

stimpinIRbacklight = str2double(stIR.UserData);
%stimpinIRbacklight = 3;
if isnan(stimpinIRbacklight)
    stimpinIRbacklight = default_stimpin_IR;
end
disp(stimpinIRbacklight);

arduino = serial(comport, 'BaudRate', 115200);
fopen(arduino);
pause(1);
%onTime  = 20; fwrite(arduino, [130, typecast(uint32(onTime/0.1), 'uint8')], 'uint8');
%freq    = 50; fwrite(arduino, [129, typecast(uint32(freq/0.1), 'uint8')], 'uint8');

oldPauseState = pause('on');
%stimPin=stimpinIRbacklight-21; fwrite(arduino, stimPin, 'uint8');
fwrite(arduino, [132,stimpinIRbacklight, true], 'uint8');
%fclose(arduino);
while 1
    if get(stopbuttonIR,'userdata') % stop condition
        break;
    end
    if get(runbutton, 'userdata')%runbutten
        mainfunction(handles,arduino);
    end
    pause(1)
end

%fwrite(arduino, stimpinIRbacklight+3, 'uint8');
%fwrite(arduino, 127, 'uint8');
%fwrite(arduino,[132,stimpinIRbacklight,false],'unit8');
% pause(oldPauseState);
fclose(arduino);
%arduino = serial(comport, 'BaudRate', 115200);
fopen(arduino);
fclose(arduino);
%IRonbutton=findobj('Tag','IR_on');
%set(IRonbutton,'userdata',0);





% --- Executes on button press in IR_off.
function IR_off_Callback(hObject, eventdata, handles)
% hObject    handle to IR_off (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp('IR light off')

IRonbutton=findobj('Tag','IR_on');
set(IRonbutton,'userdata',0);

set(gcbo, 'userdata',1);



%pause(oldPauseState);
% --- Executes on selection change in opto_backlight_pin.
function opto_backlight_pin_Callback(hObject, eventdata, handles)
% hObject    handle to opto_backlight_pin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns opto_backlight_pin contents as cell array
%        contents{get(hObject,'Value')} returns selected item from opto_backlight_pin
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
stimpinoptobacklight=str{val};

hObject.UserData=stimpinoptobacklight;



% --- Executes during object creation, after setting all properties.
function opto_backlight_pin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to opto_backlight_pin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in IR_backlight_pin.
function IR_backlight_pin_Callback(hObject, eventdata, handles)
% hObject    handle to IR_backlight_pin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns IR_backlight_pin contents as cell array
%        contents{get(hObject,'Value')} returns selected item from IR_backlight_pin
str = get(hObject, 'String');
val = get(hObject,'Value');
% Set current data to the selected data set.
stimpinIRbacklight=str{val};

hObject.UserData=stimpinIRbacklight;



% --- Executes during object creation, after setting all properties.
function IR_backlight_pin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IR_backlight_pin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
