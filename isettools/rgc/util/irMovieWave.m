function irMovieWave(ir,varargin)
% Generates a movie of the post-synaptic voltage in an inner retina mosaic
% 
% This is an attempt at a new type of visualization of the spiking activity
% of an rgc mosaic. The spikes of each cell are plotted over time so that
% they appear to be moving out of the screen. The spiking information
% conveyed via lateral connections between cells is also shown for each
% spike as it travels to nearby cells.
% 
% Inputs: an ir object (required)
% Optional parameter-value pairs
%   whichMosaic - 
%   
% 
% Outputs: a movie showing the spiking of rgc cells over time.
% 
% Example: 
%    irMovieWave(innerRetina);
% 
% 2/2016 JRG (c) isetbio team

%% Parameter initialization
%
% mosaicNameorNumber
% figureSize
% frameSkip
% outputType (spikes, voltages)
% viewOrientation
% trial
p = inputParser;

vFunc = @(x) isa(x,'ir');
p.addRequired('ir',vFunc);
p.addParameter('whichMosaic',1,@isnumeric);
p.addParameter('outputType','voltage',@ischar);
p.addParameter('trial',1,@isnumeric);

p.addParameter('frameSkip',20,@isnumeric);
vFunc = @(x) isequal(length(x),4);
p.addParameter('figRect',[160 60 1070 740],vFunc);
vFunc = @(x) isequal(length(x),2);
p.addParameter('viewOrientation',[1 1],vFunc);

p.parse(ir,varargin{:});

% Set
ir = p.Results.ir;
whichMosaic = p.Results.whichMosaic;
outputType = p.Results.outputType;
trial = p.Results.trial;

frameSkip = p.Results.frameSkip;
viewOrientation = p.Results.viewOrientation;
figRect = p.Results.figRect;

%% Initialize figure
% vcNewGraphWin([],'upperleftbig');
figure; set(gcf,'position',[160 60 1070 740]);
hold on;

% Gets the size of the cell mosaic
[nX,nY,~] = size(ir.mosaic{whichMosaic}.responseLinear);
% nX = nX + nXi;
% nY = nY = nYi;

% Set expansion factor of spike plots 
zfac = .002;

% Find max positions
allpos = vertcat(ir.mosaic{whichMosaic}.cellLocation{:});
maxx = max(allpos(:,1))/1; maxy = max(allpos(:,2))/10;

spatialRFcontours= plotContours(ir.mosaic{whichMosaic});

% spatialRFcontoursMosaic = spatialRFcontours{:,:,1,cellTypeInd};
% spatialRFcontoursMosaicArr = horzcat(spatialRFcontoursMosaic{:,:,1});

% hold on;
% plot3(spatialRFcontoursMosaicArr(1,:)-maxx/2,(t/10000+1/10000*(length(spPlot)-1))*ones(size(spatialRFcontoursMosaicArr(1,:))), spatialRFcontoursMosaicArr(2,:)-10*maxy/2,'r','linewidth',2)
    
% Set frame subsampling number
frameskip= 20;
for t = 1:frameskip:5750
    hold on;
    cla
    
    % Loop through each cell and plot spikes over time 
    for xc = 1:nX
        for yc = 1:nY
            
            % Get the appropriate spike data
            trial = 1;     % Which of the repeated trials ...
            sigType = 2;   % 1 is spikes, 2 is voltage
            spPlot=ir.mosaic{whichMosaic}.responseSpikes{xc,yc,trial,sigType}(t:t+1000);
            % spPlot=(median(horzcat(obj.mosaic{3}.responseSpikes{xc,yc,:,2})'));
            
            % Get the time values
            t1 = flipud((1:length(spPlot))');
            
            % xv sets x position of cell in spatial array
            % xv = zfac*(xc-ceil(nX/2))*t1+(xc-ceil(nX/2))+zeros(length(spPlot),1);
            pos1 = ir.mosaic{whichMosaic}.cellLocation{xc,yc}; xpos = pos1(1)/1; ypos = pos1(2)/10;
            xv = zfac*(xpos-maxx/2)*t1+(xpos-maxx/2)+zeros(length(spPlot),1);
            % yv sets time position using t
            yv = t/10000+1/10000*(1:length(spPlot));
            % zv sets y position of cell in array and scales size of spike
            % waveform
            spScale = 1;
            % zv = 10*(yc-ceil(nY/2))+10*(yc-ceil(nY/2))*zfac*t1+spScale*spPlot;            
            zv = 10*(ypos-maxy/2)+10*(ypos-maxy/2)*zfac*t1+spScale*spPlot;
            
            % Plot the waveform for this cell
            h1=plot3(xv, yv, zv,'linewidth',2);
            colorval = get(h1,'color');
            
            % Plot the spike activity transmitted by lateral connections
            % Find spikes in this temporal window
            % Get spike times for this cell
            spTimes = 100*ir.mosaic{whichMosaic}.responseSpikes{xc,yc,1,1};
            % Check if any fall in the temporal window
            spFind = find(spTimes >= t+1000 & spTimes < t+1000+frameskip, 1);
            
            % If there are spikes, plot them on lateral connections
            if ~isempty(spFind) %&& isa(ir,'rgcGLM')
                % Check which other cells are connected to the cell of
                % interest
                for xc2 = 1:nX
                    for yc2 = 1:nY
                        % If the coupling weight is > 0 and there is a
                        % spike, plot this
                        if abs(ir.mosaic{whichMosaic}.couplingMatrix{xc,yc}(xc2,yc2))>0
                            pos2 = ir.mosaic{whichMosaic}.cellLocation{xc2,yc2}; 
                            xpos2 = pos2(1)/1; ypos2 = pos2(2)/10;
                            % Calculate spatial positions in array of
                            % starting cell and target cell
                            % x0 = xc-ceil(nX/2); xf = xc2-ceil(nX/2);
                            % z0 = yc-ceil(nY/2); zf = yc2-ceil(nY/2);
                            
                            x0 = xpos-maxx/2; xf = xpos2-maxx/2;
                            z0 = ypos-maxy/2; zf = ypos2-maxy/2;
                            hold on;
                            
                            % plot the line representing the lateral
                            % connection
%                             line(1+zfac*1000*[x0 xf ],[t  t]/10000,1+zfac*1000*10*[z0 zf],'color',colorval,'linewidth',4);
                            line([x0 xf ],[t+1000 t+1000]/10000,10*[z0 zf],'color',colorval,'linewidth',4);
                            
                        end%if
                    end%yc2
                end%xc2
                
            end%if length
            plot3((spatialRFcontours{xc,yc,1}(1,2:end))-maxx/2,...
                (t/10000+1/10000*(length(spPlot)-1))*ones(size(spatialRFcontours{xc,yc,1}(1,2:end))),...
                (spatialRFcontours{xc,yc,1}(2,2:end))-10*maxy/2,'color',colorval);%,...
            
        end
    end
    % Label axes
    xlabel(sprintf('x position (\\mum)')); ylabel('time (sec)'); zlabel(sprintf('y position (\\mum)'));
    set(gca,'fontsize',18);
    
    % Set view angle
    % view(-19,18);
%     view(-2,2)
    view(1,4);
    
    % Shift axis
%     axis([0 70 t/10000 (t+1000)/10000 60 60+70]);
    axis([-100 100 t/10000 (t+1000)/10000 -60 60]);
    grid on;
    drawnow;
    % pause(.01);
    % hold off;
    % clf
    
end

% Alternate method, plot whole waveform and shift axis
% for t = 1:10:6250
%     
% %     axis([-3 3 0+t 500+t -30 30])
%     axis([-4 4 0+t 1000+t -50 50])
%     pause(.005);
% end