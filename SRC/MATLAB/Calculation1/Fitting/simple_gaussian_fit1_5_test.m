
% test_y = transpose([ 40, 90, 100, 50, 20 ]); % [ 5, 11, 12, 6 ]); % ([ 40, 90, 100, 50, 20 ]);
% test_x = transpose([ 1, 2, 4, 7, 9 ]); % [ 6, 7, 8, 9]); % [ 1, 2, 4, 7, 9 ]);

% test_y = transpose([ 40, 90, 100, 50]);
% test_x = transpose([ 1, 2, 4, 7 ]);

test_y = transpose([ 40, 90, 100, 50 ]);
test_x = transpose([ 15, 16, 17, 18 ]*100);

% test_y = transpose([  20,  40,  60,  20 ]);
% test_x = transpose([ 100.001, 100.002, 100.003, 100.004 ]);


[ coeff_a, center_x, extrem_y ] = ...
    simple_Gaussian_fit1_4(test_x, test_y);

cfit_gauss = fit(test_x, test_y, 'gauss1');

fitted_x = (13:0.1:21)*100; % 99.995:0.001:100.007; %(100:200)*100; % -1:0.1:10;
fitted_y = exp(coeff_a(1)*fitted_x.^2 + coeff_a(2)*fitted_x + coeff_a(3));
cfit_gauss_y = cfit_gauss(fitted_x);

plot(fitted_x, fitted_y);
hold on;
plot(fitted_x, cfit_gauss_y);
hold on;
scatter(test_x, test_y);
hold off; 

legend('Simple fit', 'Toolbox', 'Original data');

% tmpf = @()simple_Gaussian_fit1_3(test_x, test_y)
% timeit(tmpf)

% tmpf_gaussian = @()fit(test_x, test_y,'gauss1')
% timeit(tmpf_gaussian)

%%

test_y = [ 40, 90, 100, 50 ];
test_x = [ 1, 2, 4, 7 ];

[ coeff_a_2, center_x_2, extrem_y_2, flag_2, test_x_ins, test_y_ins ] = ...
    simple_Gaussian_fit_insert_peaktop1_1(test_x, test_y);
