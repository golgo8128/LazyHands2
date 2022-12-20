function [ coeff_a, center_x, extrem_y ] = ...
    simple_Gaussian_fit1_4(ix, iy)

    % iy = transpose([ 4, 9, 12, 5 ]);
    % ix = transpose([ 0.5, 1, 5.5, 6 ]);
    
    ln_y = log(iy);
    x = horzcat(ix.^2, ix, repelem(1, length(ix), 1));
    
    [ coeff_a ] = LLS_SVD_simple1_1(x, ln_y);
    
    center_x = -0.5 * coeff_a(2) / coeff_a(1);
    extrem_y = exp(coeff_a(3) - 0.25 * coeff_a(2)^2 / coeff_a(1));
    
    % fitted_x = -1:0.1:8;
    % fitted_y = exp(a(1)*fitted_x.^2 + a(2)*fitted_x + a(3));

    % cfit_gauss = fit(ix, iy, 'gauss1');
    % cfit_gauss_y = cfit_gauss(fitted_x);
    % 
    % plot(fitted_x, fitted_y);
    % hold on;
    % plot(fitted_x, cfit_gauss_y);
    % hold on;
    % scatter(ix, iy);
    % hold off;

    % tmpf = @()lsqr(x, ln_y)
    % timeit(tmpf)
    
    % tmpf_gaussian = @()fit(ix, iy,'gauss1')
    % timeit(tmpf_gaussian)

end




