vidObj = VideoReader('shortbus.mp4');
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);


while  hasFrame(vidObj)
     s(k).cdata = readFrame(vidObj); k=k+1;
end

%%
vidObj = VideoReader('Seattle_ America''s Next Top Transit City.mp4');
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;
s = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
k1 = 70;
k2 = 80;
vidObj.CurrentTime = k1;
k=1;
while vidObj.CurrentTime < k2
     s(k).cdata = readFrame(vidObj); k=k+1;
end

for k=1:length(s)
    imagesc(s(k).cdata);
    title(num2str(k));
    drawnow;
end
% 
% hf = figure;
% set(hf,'position',[150 150 vidWidth vidHeight]);
% movie(hf,s,1,vidObj.FrameRate);
v = VideoWriter('shortbus.mp4');
open(v);
writeVideo(v,s)
close(v)