% AUTHOR:	Jan Winter, Sandy Buschmann, TU Berlin, FG Lichttechnik,
% 			j.winter@tu-berlin.de, www.li.tu-berlin.de
% LICENSE: 	free to use at your own risk. Kudos appreciated.



function [text, measurements] = CS2000_readStoredMeasurement()
% Reads measurement data stored in memory from the instrument.
    % Instrument must be connected (see CS2000_initConnection).
    % Trys to read data from number 00 to 99 and breaks if there are no
    % data.
    

global s

% edit:
comments = ' '; 
lightSource = ' '; 
% end edit

data_format = '0'; % input parameter for the instrument, data format will be alphanumeric

meas = cell(100, 1);
colorimetricData = cell(24,1);

% read all 100 data stores from the instrument
for n = 0 : 99 
    % read spectral data:
    data_mode = 1;   % input parameter for the instrument, spectral data will be read 
    p = 1;
    for datablock_number = 1 : 4  % spectral data are divided in 4 blocks
       
        % read data block from data store n
        fprintf(s, ['STDR,', num2str(n),',', num2str(data_mode), ...
        ',', num2str(data_format), ',', num2str(datablock_number)]);
    
        % Get instrument answer into file:
        answer = fscanf(s); 
        fid = fopen('Temp\answers.tmp', 'w');
        fprintf(fid, answer);
        fclose(fid);
    
        % Get instrument error-check code:
        fid = fopen('Temp\answers.tmp','r');
        ErrorCheckCode = fscanf(fid,'%c',4);        
        [tf, errOutput] = CS2000_errMessage(ErrorCheckCode);
        if tf ~= 1 % an error occured 
            stopped  = n; % get the data store where reading stops
            assignin('base', 'stopped', stopped);            
            if n == 0
                text = errOutput;
                disp(text);
            end
            break % stop reading from instrument        
        else % no error
            if datablock_number == 4 % block 4 has 101 pieces of data
                l = 101;
            else
                l = 100;             % blocks 1..3 have 100 pieces of data
            end
            for m = p:((p+l)-1)
                garbage = fscanf(fid,'%c',1); % the pieces of data are seperated with a comma
                spectralData{m} = fscanf(fid,'%e',8);
            end   
        end    
        fclose(fid);     
        p = p+100;        
    end
    

    % read colorimetric data from data store n:
    data_mode = '2'; % input parameter for the instrument, colorimetric data will be read
    datablock_number = '00'; % input parameter for the instrument, all colorimetric data will be read    
    
    fprintf(s, ['STDR,', num2str(n),',', num2str(data_mode), ...
        ',', num2str(data_format), ',', num2str(datablock_number)]);  

        % Get instrument answer into file:
        answer = fscanf(s);
        fid = fopen('Temp\answers.tmp', 'w');
        fprintf(fid, answer);
        fclose(fid);

        % Get instrument error-check code:
        fid = fopen('Temp\answers.tmp','r');
        ErrorCheckCode = fscanf(fid,'%c',4);
        [tf, errOutput] = CS2000_errMessage(ErrorCheckCode);
        if tf ~= 1 % an error occured
            if n == 0
                text = errOutput;
                disp(text);
            end
            break % stop reading      
        else %no error, get spectral data:
            for k = 1:24
                garbage = fscanf(fid,'%c',1); % the pieces of data are seperated with a comma
                colorimetricData{k} = fscanf(fid,'%e');
            end              
        end
        fclose(fid); 
    
    % read measurement conditions from the instrument
    data_mode = '0';   % input parameter for the instrument, measurement conditions will be read
    datablock_number = '01';
    
    fprintf(s, ['STDR,', num2str(n),',', num2str(data_mode), ...
        ',', num2str(data_format), ',', datablock_number]);
    
        % Get instrument answer into file:
        answer = fscanf(s);    
        fid = fopen('Temp\answers.tmp', 'w');
        fprintf(fid, answer);
        fclose(fid);
        
        % Get instrument error-check code:
        fid = fopen('Temp\answers.tmp','r');
        ErrorCheckCode = fscanf(fid,'%c',4);
        [tf, errOutput] = CS2000_errMessage(ErrorCheckCode);
        if tf ~= 1 % an error occured
            disp(errOutput);
            aperture = 'error';
            break % stop reading      
        else %no error, get spectral data:
            for v = 1:24
                garbage = fscanf(fid,'%c',1); % the pieces of data are seperated with a comma
                measConditions{v} = fscanf(fid,'%e');
            end  
            apertureNum = measConditions{7};
            switch apertureNum
                case 0
                    aperture = '1�';
                case 1
                    aperture = '0.2�';
                case 2
                    aperture = '0.1�';
            end            
        end
        fclose(fid);       
    
    
    % create CS2000Measurement object:    
    measuredData = CS2000Measurement(clock, spectralData, colorimetricData);
    colorimetricNames = properties(measuredData.colorimetricData);  
    measuredData.aperture = aperture;
    measuredData.comments = comments;
    measuredData.lightSource = lightSource;
    meas{n+1} = measuredData;
    
    text = 'All data have been read.';
end 

% delete empty cells:
ant = evalin('base', 'exist(''stopped'', ''var'')');
if ant == 1    
    stopped = evalin('base', 'stopped');
    measurements = cell(stopped, 1);
    for z = 1 : stopped  
        measurements{z,1} = meas{z};
    end
else
    measurements = cell(100, 1);
    for z = 1 : 100  
        measurements{z,1} = meas{z};
    end
end
evalin('base', 'clear stopped');

end





