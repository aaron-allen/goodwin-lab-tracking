
function error_handling_wrapper(errorlogfile,myfun,varargin)
    errorlogfile=string(errorlogfile);
    currentdir=pwd;
    try
        f=str2func(myfun);
        f(varargin{:});
    catch ME
           errorMessage= ME.message;
           disp(errorMessage);
           cd(currentdir);
           fidd = fopen(errorlogfile, 'a');
           fprintf(fidd,'could not execute function %s on %s: ', myfun,varargin{:}); % To file
           fprintf(fidd, '%s\n', errorMessage); % To file
           fclose(fidd);
    end
    
end
