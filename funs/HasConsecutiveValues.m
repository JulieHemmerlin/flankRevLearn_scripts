function [noccurences] = HasConsecutiveValues(x,nconsecutive,xexcluded)

% xexclude - any value of x that should be excluded?
% Annotated by NS, Jan 2017

if nargin < 3
    xexcluded = [];
end
if nargin < 2
    nconsecutive = 2;
end
if nargin < 1
    error('Wrong input argument list.');
end

[y,n] = GetConsecutiveValues(x);

if ~isempty(xexcluded)
    if length(xexcluded) == 1
        i = (y ~= xexcluded);
    else
        i = ~ismember(y,xexcluded);
    end
    n = n(i);
end

% nnz: Number of nonzero matrix elements
noccurences = nnz(n >= nconsecutive);

end