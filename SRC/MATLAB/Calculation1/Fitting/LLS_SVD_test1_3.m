% Solving linear least squares problem with singular value decomposition
% https://www2.math.uconn.edu/~leykekhman/courses/MATH3795/Lectures/Lecture_9_Linear_least_squares_SVD.pdf
% http://www.misojiro.t.u-tokyo.ac.jp/~murota/lect-kisosuri/singularvalue050129.pdf
% https://www2.math.ethz.ch/education/bachelor/lectures/hs2014/other/linalg_INFK/svdneu.pdf

A = [ 3, 2, 1; 7, 6, 4 ; 2, 3, 1; 4, 9, 2; 1, 4, 5 ];
b = [ 10, 20, 5, 5, 10 ]';

% A = [ 3, 2, 1; 7, 6, 4 ] % ; 3, 2, 1; 7, 6, 4 ] % ; 2, 3, 1; 4, 9, 2; 1, 4, 5 ];
% b = [ 10, 20 ]' %, 10, 20 ]' % , 5, 5, 10 ]';

x = LLS_SVD_simple1_1(A, b);


% lsqr(A, b)

% tmp_svd_f = @() LLS_SVD_simple1_1(A, b)
% timeit(tmp_svd_f)

% tmp_lsqr_f = @() lsqr(A, b)
% timeit(tmp_lsqr_f)
