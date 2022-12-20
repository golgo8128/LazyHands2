% Solving linear least squares problem with singular value decomposition
% https://www2.math.uconn.edu/~leykekhman/courses/MATH3795/Lectures/Lecture_9_Linear_least_squares_SVD.pdf
% http://www.misojiro.t.u-tokyo.ac.jp/~murota/lect-kisosuri/singularvalue050129.pdf
% https://www2.math.ethz.ch/education/bachelor/lectures/hs2014/other/linalg_INFK/svdneu.pdf

function [ x ] = LLS_SVD_simple1_1(A, b) %#codegen
    
    % disp('LLS_SVD_simple1_1');

    % compute the SVD:
    
    [ U, S, V ] = svd(A);
    s           = diag(S);
        
    d = U' * b;
    z_pre = d(1:length(s)) ./ s;
    almost_zero_bool = s < max(size(A) * eps * s(1));
    almost_zero_bool(1) = false;
    z_pre(almost_zero_bool) = 0;
    
    z = zeros(size(A, 2), 1);
    if length(z_pre) > length(z)
        z = z_pre(1:length(z));
    else
        z(1:length(z_pre)) = z_pre;
    end 
    
    x = V * z;

end

% A = [ 3, 2, 1; 7, 6, 4 ; 2, 3, 1; 4, 9, 2; 1, 4, 5 ];
% b = [ 10, 20, 5, 5, 10 ]';
    
% A = [ 3, 2, 1; 7, 6, 4 ] % ; 3, 2, 1; 7, 6, 4 ] % ; 2, 3, 1; 4, 9, 2; 1, 4, 5 ];
% b = [ 10, 20 ]' %, 10, 20 ]' % , 5, 5, 10 ]';

% lsqr(A, b)

% tmp_svd_f = @() svd(A)
% timeit(tmp_svd_f)

% tmp_lsqr_f = @() lsqr(A, b)
% timeit(tmp_lsqr_f)
