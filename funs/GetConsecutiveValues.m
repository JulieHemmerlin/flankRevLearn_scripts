function [xcon,ncon] = GetConsecutiveValues(x)

% Annotated by NS, Jan 2017

if nargin < 1
    error('Wrong input argument list.');
end

x = x(:);
d = [1;diff(x)] ~= 0;

ncon = diff([find(d);length(x)+1]); % n of repetitions
xcon = x(d); % value that is being repeated

end