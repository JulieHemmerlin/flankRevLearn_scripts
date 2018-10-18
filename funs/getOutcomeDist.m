
function [out] = getOutcomeDist(ind, prob)
    n = length(find(ind));        
    out = NaN(n, 1);
    out(1:round(prob*n)) = 1;
    out(round(prob*n)+1:n) = -1;        
end
