function varargout = OrigamiHP(varargin)
%  	Author: Roger Yeh
%   Copyright 2010 MathWorks, Inc.
%   Version: 1.0  |  Date: 2010.01.13

% OrigamiHP M-file for serial_GUI.fig
%      OrigamiHP, by itself, creates a new SERIAL_GUI or raises the existing
%      singleton*.
%
%      H = OrigamiHP returns the handle to a new SERIAL_GUI or the handle to
%      the existing singleton*.
%
%      OrigamiHP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SERIAL_GUI.M with the given input arguments.
%
%      OrigamiHP('Property','Value',...) creates a new SERIAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before serial_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to serial_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help serial_GUI

% Last Modified by GUIDE v2.5 15-Feb-2018 16:14:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @OrigamiHP_OpeningFcn, ...
    'gui_OutputFcn',  @OrigamiHP_OutputFcn, ...
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
end

% --- Executes just before serial_GUI is made visible.
function OrigamiHP_OpeningFcn(hObject, eventdata, handles, varargin)

serialPorts = instrhwinfo('serial');
nPorts = length(serialPorts.SerialPorts);
set(handles.portList, 'String', ...
    [{'Select a port'} ; serialPorts.SerialPorts ]);
set(handles.portList, 'Value', numel(get(handles.portList, 'String')));
set(handles.history_box, 'String', cell(1));

handles.output = hObject;

% UIWAIT makes serial_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Update handles structure
guidata(hObject, handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = OrigamiHP_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes during object creation, after setting all properties.
function portList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to portList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function history_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to history_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Tx_send_Callback(hObject, eventdata, handles)
TxText = get(handles.Tx_send, 'String');
fprintf(handles.serConn, TxText);

set(hObject, 'String', '');

done=0;
while ~done
    [done, handles] = receive_data(handles, 0);
end
end

% --- Executes during object creation, after setting all properties.
function Tx_send_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tx_send (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in rxButton.
function [done, handles, RxText] = receive_data(handles, doSilent)
wngState = warning();
warning('Off', 'MATLAB:serial:fscanf:unsuccessfulRead');
done = 0;
RxText = [];
try
    RxText = fscanf(handles.serConn);
    currList = get(handles.history_box, 'String');
    if isempty(RxText)
        done = 1;
        return
    else
        if ~doSilent
            set(handles.history_box, 'String', ...
                [currList ; ['< ' RxText ] ]);
        end
    end
    if ~doSilent
        set(handles.history_box, 'Value', length(currList) + 1 );
    end
catch e
    disp(e)
    done=1;
end
warning(wngState);
end

% --- Executes during object creation, after setting all properties.
function baudRateText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baudRateText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in connectButton.
function connectButton_Callback(hObject, eventdata, handles)
isConnect = 0;
isDisconnect = 0;
if strcmp(get(hObject,'String'),'Connect') % currently disconnected
    serPortn = get(handles.portList, 'Value');
    if serPortn == 1
        errordlg('Select valid COM port');
    else
        serList = get(handles.portList,'String');
        serPort = serList{serPortn};
        serConn = serial(serPort, 'TimeOut', 1, ...
            'BaudRate', str2num(get(handles.baudRateText, 'String')));
        
        try
            fopen(serConn);
            
            % assign serial connection to handles
            handles.serConn = serConn;
            
            % send status query
            fprintf(handles.serConn, 's?');
            
            % wait for response
            done = 0;
            resp = {};
            linecount = 1;
            while ~done
                [done, handles, resp{linecount}] = receive_data(handles, 0);
                linecount = linecount + 1;
            end
            
            % verify response to identify device
            isGood = ...
                ~isempty(resp) && ...
                ~isempty(resp{1}) && ...
                regexp(resp{1}, 's?\n') && ...
                regexp(resp{2}, 'Status of the Device:\n');
            
            if ~isGood
                fclose(handles.serConn);
                handles = rmfield(handles, 'serConn');
                error('Device not found on selected COM port.');
            end
            
            % enable Tx text field and Rx button
            set(handles.Tx_send, 'Enable', 'On');
            set(handles.open_push, 'Enable', 'Off');
            
            % check status
            handles.timer = timer(...
                'ExecutionMode', 'fixedRate', ...       % Run timer repeatedly.
                'Period', 1, ...                        % Initial period is 1 sec.
                'TimerFcn', @(~,~)check_status(handles)); % Specify callback function.
            
            % set button string
            set(handles.connectButton, 'String', 'Disconnect')
            set(handles.open_push, 'BackgroundColor', ...
                get(0,'defaultUicontrolBackgroundColor'));
            set(handles.conn_text, 'String', 'Connected')
            
            % switch connect indicator
            axes(handles.connect_indicator);
            rectangle('Curvature',[1 1], 'FaceColor', 'green')
            axis off equal
            
            guidata(hObject, handles);

            start(handles.timer);
            
        catch e
            delete(instrfindall);
            if isfield(handles, 'serConn')
                rmfield(handles, 'serConn');
            end
            errordlg(e.message);
        end
        
    end
else
    
    stop(handles.timer)
    
    pause(2);
    
    % close serial connection
    fclose(handles.serConn);
    
    % disable text field
    set(handles.Tx_send, 'Enable', 'Off');
    
    % diable and re-label open shutter button
    set(handles.open_push, 'Enable', 'Off');
    set(handles.open_push, 'BackgroundColor', ...
        get(0,'defaultUicontrolBackgroundColor'));
    set(handles.open_push, 'String', 'Open Shutter');
    
    % label connect button
    set(hObject, 'String','Connect')
    
    % change indicator colors
    axes(handles.connect_indicator);
    rectangle('Curvature',[1 1], 'FaceColor', 'red');
    axis off equal
    set(handles.conn_text, 'String', 'Disconnected')
    
    axes(handles.status_indicator);
    rectangle('Curvature',[1 1], 'FaceColor', ...
        get(0,'defaultUicontrolBackgroundColor'));
    axis off equal
    set(handles.err_text, 'String', 'Disconnected')
    
    isDisconnect = 1;
    
    guidata(hObject, handles);
    
end

end

function status = check_status(handles)
status = struct();
statArray = {};
count = 1;
done = 0;

% this pause is required to interrupt when stopping the timer
pause(0.2)

if isfield(handles, 'serConn')
    try
        fprintf(handles.serConn, 's?');
        notConnected = 0;
    catch ME
        notConnected = 1;
    end
end

if notConnected
    axes(handles.status_indicator);
    rectangle('Curvature',[1 1], 'FaceColor', ...
        get(0, 'defaultUicontrolBackgroundColor'));
    axis off equal
    set(handles.err_text, 'String', 'Disconnected')
    set(handles.open_push, 'Enable', 'Off');
    
    return
end
while ~done
    [done, ~, statArray{count}] = receive_data(handles, 1);
    count = count + 1;
end

% Check laser emission
fprintf(handles.serConn, 'le?');
done = 0;
count = 1;
while ~done
    [done, ~, emResp{count}] = receive_data(handles, 1);
    count = count + 1;
end
status.emissionOn = isempty(strfind(emResp{2}, 'le=0'));

% Omit first line (prompt repeat)
statArray = statArray(3:end);

status.keyOff = isempty(strfind(statArray{1}, 'Key switch=0'));
status.interlockOn = isempty(strfind(statArray{2}, 'Interlock switch=0'));
status.preamp1Err = isempty(strfind(statArray{4}, 'PREAMP1 =1'));
status.guard1Err = isempty(strfind(statArray{5}, ' circuit 1 = 1'));
status.errState = any([status.preamp1Err, status.guard1Err, ...
    status.interlockOn, status.keyOff]);

statusLight = 'g';
errText = 'No Errors';
openCol = 'y';
openPush = 'On';

if status.keyOff
    statusLight = 'y';
    errText = 'Key Locked';
    openCol = get(0, 'defaultUiControlBackgroundColor');
    openPush = 'Off';
elseif status.interlockOn
    statusLight = 'y';
    errText = 'Interlock Active';
    openCol = get(0, 'defaultUiControlBackgroundColor');
    openPush = 'Off';
elseif status.preamp1Err
    statusLight = 'r';
    errText = 'Preamp Error';
    openCol = get(0, 'defaultUiControlBackgroundColor');
    openPush = 'Off';
elseif status.errState
    statusLight = 'y';
    errText = 'Error';
    openCol = get(0, 'defaultUiControlBackgroundColor');
    openPush = 'Off';
end

pause(.2)

isDisconnected = strcmp(get(handles.connectButton,'String'),'Connect');

if status.emissionOn
    set(handles.open_push,'Value', 1, ...
        'String','Shutter open!')
    openCol = 'r';
    
    axes(handles.emission_indicator);
    rectangle('Curvature',[1 1], 'FaceColor', 'green')
    axis off equal
    
    set(handles.emission_text, 'String', 'Emission')
else
    if ~status.errState && ~isDisconnected
        axes(handles.emission_indicator);
        rectangle('Curvature',[1 1], 'FaceColor', ...
            get(0, 'defaultUiControlBackgroundColor'))
        axis off equal
        set(handles.emission_text, 'String', 'No Emission')
        set(handles.open_push,...
            'Value', 0, ...
            'String','Open shutter');
            openCol = 'y';
    end
end

if ~isDisconnected
    % Set status lights and texts
    axes(handles.status_indicator);
    rectangle('Curvature',[1 1], 'FaceColor', statusLight);
    axis off equal
    set(handles.err_text, 'String', errText);
    
    set(handles.open_push, 'Enable', openPush, ...
        'BackgroundColor', openCol);
end
end % end of check_status

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles, 'serConn')
    try
        fclose(handles.serConn);
    catch ME
        warning(ME.message);
    end
end
% Hint: delete(hObject) closes the figure
delete(hObject);
end

function open_push_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to open_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
end

% --- Executes on button press in open_push.
function open_push_Callback(hObject, eventdata, handles)
% hObject    handle to open_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    if get(hObject,'Value')
        set(hObject,'Value', 0)
        if isfield(handles, 'serConn')
            
            TxText = 'le=1';
            fprintf(handles.serConn, TxText);
            
            done=0;
            while ~done
                [done, handles] = receive_data(handles, 1);
            end
            
            set(hObject,'Value', 1)
            set(hObject, 'String','Shutter open!');
            set(hObject, 'BackgroundColor', 'red');
            axes(handles.emission_indicator);
            rectangle('Curvature',[1 1], 'FaceColor', 'green')
            axis off equal
            
            set(handles.emission_text, 'String', 'Emission')
            
        else
            error('Not Connected. Please connect first');
        end
        
    else
        if isfield(handles, 'serConn')
            TxText = 'le=0';
            fprintf(handles.serConn, TxText);
            
            done=0;
            while ~done
                [done, handles] = receive_data(handles, 1);
            end
            set(hObject,'Value', 0);
            set(hObject, 'String', 'Open shutter');
            set(hObject, 'BackgroundColor', 'yellow');
            
            axes(handles.emission_indicator);
            rectangle('Curvature',[1 1], 'FaceColor', ...
                get(0,'defaultUicontrolBackgroundColor'))
            axis off equal
            
            set(handles.emission_text, 'String', 'No Emission')
        else
            error(['Not connected or connection lost.', ...
                'Check shutter state on Driver.']);
        end
    end
catch ME
    errordlg(ME.message);
end
% Hint: get(hObject,'Value') returns toggle state of open_push
end

function portList_Callback(hObject, eventdata, handles)

end

% --- Executes during object creation, after setting all properties.
function open_push_CreateFcn(hObject, eventdata, handles)
set(hObject,'Value', 0);
set(hObject, 'String', 'Open shutter');
set(hObject, 'Enable', 'Off');

% hObject    handle to open_push (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
end


% --- Executes during object creation, after setting all properties.
function connect_indicator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to connect_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
rectangle('Curvature',[1 1], 'FaceColor', 'red')
axis off equal

% Hint: place code in OpeningFcn to populate connect_indicator
end

% --- Executes during object creation, after setting all properties.
function status_indicator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.statusAx = rectangle('Curvature',[1 1]);
axis off equal

% Hint: place code in OpeningFcn to populate status_indicator
end

% --- Executes during object creation, after setting all properties.
function emission_indicator_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emission_indicator (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
rectangle('Curvature',[1 1])
axis off equal

% Hint: place code in OpeningFcn to populate emission_indicator
end

%dummy line
