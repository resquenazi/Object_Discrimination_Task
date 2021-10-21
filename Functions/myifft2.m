function img = myifft2(Y)
%img = myifft2(Y)
%
%Returns the time-series y, and time vector by taking the ifft based on the
%'real' amplitudes, phases and dc values in Y as calculated by 'myfft'
%
%Inputs:    Structure Y with fields:
%   dc       mean value of y
%   amp      vector of amplitudes (length ceil(length(t)/2))
%   ph       vector of phases (in degrees, cosine phase)
%   nt       length of t (needed for myifft)

%Outputs:
%   img        real-valued vector
%
%SEE ALSO    myfft2 fft2 ifft2 complex2real2 real2complex2

%4/15/09     Written by G.M. Boynton at the University of Washington

F = real2complex2(Y);
img = ifft2(F,'symmetric');
img = img(1:Y.nPix,1:Y.nPix);

