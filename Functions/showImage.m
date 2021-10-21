function showImage(img,x,y)
% showImage(img,[x],[y])
%
% x and y are either [x,y] matrices as from meshgrid, or are vectors.
% Default is 1:m and 1:n for an n x m image

if ~exist('x','var');
    x = 1:size(img,2);
end

if isempty(x)
    x = 1:size(img,2);
end

if ndims(x)==2
    x = x(1,:);
end

if ~exist('y','var');
    y = 1:size(img,1);
end

if isempty(y)
    y = 1:size(img,1);
end


if ndims(y) ==2 
    y = y(:,1)';
end


imagesc(x,y,img)
axis equal
axis tight
colormap(gray);
set(gca,'YDir','normal');

