
% https://jp.mathworks.com/help/matlab/ref/lsqr.html
% https://jp.mathworks.com/help/curvefit/gaussian.html
% https://jp.mathworks.com/help/curvefit/fit.html
% https://jp.mathworks.com/help/curvefit/fittype.html

ix = transpose([  1,  2,  4,  5 ]);
iy = transpose([  7,  8,  9,  6 ]);
fitres = fit(ix, iy, 'gauss1');

plot(fitres, ix, iy);

% tmpf = @()fit(ix, iy,'gauss1')
% timeit(tmpf)
