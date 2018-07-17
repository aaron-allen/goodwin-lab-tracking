
function error_handling_wrapper(myfun,varargin)
    try
        f=str2func(myfun);
        f(varargin{:});
    catch ME
          disp(ME.message);
    end
    
end
