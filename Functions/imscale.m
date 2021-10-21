function mat = imscale(mat, newmin, newmax, oldmin, oldmax)

if mod(nargin, 2)==0 || nargin>5% shouldn't have a mean number of input arguments
    errordlg('wrong number of input arguments');
end
if nargin < 4 
    oldmin = min(mat(:)); oldmax = max(mat(:));
end
if nargin < 2
     newmin = 0; newmax = 1; 
end

mat =(mat-oldmin)/(oldmax-oldmin);% Scales to be between 0 and 1
mat =((newmax-newmin).*mat)+newmin;% Scales to be between newmin and newmax
end