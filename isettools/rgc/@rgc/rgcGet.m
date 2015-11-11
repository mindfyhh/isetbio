function val = rgcGet(obj, varargin)
% rgcGet: a method of @rgc that gets rgc object 
% parameters using the input parser structure.
% 
%       val = rgcGet(rgc, property)
% 
% Inputs: rgc object, property to be gotten
% 
% Outputs: val of property
% 
% Proeprties:
%         name: type of rgc object, e.g., 'macaque RGC'
%         input: 'cone current' or 'scene RGB', depends on type of outer
%           segment object created.
%         temporalEquivEcc: the temporal equivalent eccentricity, used to 
%             determine the size of spatial receptive fields.   
%         mosaic: contains rgcMosaic objects for the five most common types
%           of RGCs: onParasol, offParasol, onMidget, offMidget,
%           smallBistratified.
% 
% Example:
%   val = rgcGet(rgc1, 'name')
%   val = rgcGet(rgc1, 'input')
% 
% 9/2015 JRG 

% Check for the number of arguments and create parser object.
% Parse key-value pairs.
% 

% % % We could do set using the superclass method
% obj = mosaicSet@rgcMosaic(obj, varargin{:});

% Check key names with a case-insensitive string, errors in this code are
% attributed to this function and not the parser object.
error(nargchk(0, Inf, nargin));
p = inputParser; p.CaseSensitive = false; p.FunctionName = mfilename;

% Make key properties that can be set required arguments, and require
% values along with key names.
allowableFieldsToSet = {...         
        'name',...
        'input',...
        'temporalEquivEcc',...       
        'mosaic'...
    };
p.addRequired('what',@(x) any(validatestring(x,allowableFieldsToSet)));

% % Define what units are allowable.
% allowableUnitStrings = {'a', 'ma', 'ua', 'na', 'pa'}; % amps to picoamps
% 
% % Set up key value pairs.
% % Defaults units:
% p.addParameter('units','pa',@(x) any(validatestring(x,allowableUnitStrings)));

% Parse and put results into structure p.
p.parse(varargin{:}); params = p.Results;

% % Old error check on input.
% if ~exist('params','var') || isempty(params)
%     error('Parameter field required.');
% end
% if ~exist('val','var'),   error('Value field required.'); end;

% Set key-value pairs.
switch lower(params.what)    
    case{'name'}
        val = obj.name;
    case{'input'}
        val = obj.input;
    case{'temporalequivecc'}        
        val = obj.temporalEquivEcc;
    case{'mosaic'}        
        val = obj.mosaic;                
end

