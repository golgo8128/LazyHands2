
% https://jp.mathworks.com/help/matlab/ref/lsqr.html

rng default
A = sprand(400,300,.5);
b = rand(400,1);

[ x, flag ] = lsqr(A,b);

% tmpf = @()lsqr(A,b)
% timeit(tmpf)

% https://jp.mathworks.com/help/curvefit/gaussian.html
% https://jp.mathworks.com/help/curvefit/fit.html
% https://jp.mathworks.com/help/curvefit/fittype.html

