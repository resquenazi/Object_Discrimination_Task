function [L] = findDichImg(inImg, orig2ElD, n)
% [L] = findDichImg(inImg, orig2ElD)
%   Find the dichopic input image that creates something as close as
%   possible to estim neural responses

[on_L, off_L] = blurBank(inImg.img(:, :, 1), n);
[on_R, off_R] = blurBank(inImg.img(:, :, 2), n);

estElD(:, :, 1) = on_L + on_R;
estElD(:, :, 2) = off_L + off_R;

err = sqrt(sum(sum(sum((estElD-orig2ElD(:, :, 1:2)).^2))));
end

