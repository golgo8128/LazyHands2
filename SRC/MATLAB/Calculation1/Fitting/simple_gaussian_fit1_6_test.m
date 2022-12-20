
% test_y = transpose([ 40, 90, 100, 50, 20 ]); % [ 5, 11, 12, 6 ]); % ([ 40, 90, 100, 50, 20 ]);
% test_x = transpose([ 1, 2, 4, 7, 9 ]); % [ 6, 7, 8, 9]); % [ 1, 2, 4, 7, 9 ]);

% test_y = transpose([ 40, 90, 100, 50]);
% test_x = transpose([ 1, 2, 4, 7 ]);

% test_y = transpose([ 40, 90, 100, 50 ]);
% test_x = transpose([ 15, 16, 17, 18 ]*100);

% test_y = transpose([  20,  40,  50,  20 ]);
% test_x = transpose([ 100.001, 100.002, 100.003, 100.004 ]);

test_x =  [ ...
  298.0580
  298.0780
  298.0980
  298.1180
  ];

test_y = [ ...
  31
  32
  60
  57
];


[ coeffz_a, center_x, extrem_y, ox, oy, iz, centr, factr ] = ...
    simple_Gaussian_fit_insert_peaktop1_3(test_x, test_y)

cfit_gauss = fit(iz, test_y, 'gauss1');

fitted_z = -1:0.01:1;
fitted_y = exp(coeffz_a(1)*fitted_z.^2 + coeffz_a(2)*fitted_z + coeffz_a(3));
cfit_gauss_y = cfit_gauss(fitted_z);

plot(fitted_z, fitted_y);
hold on;
plot(fitted_z, cfit_gauss_y);
hold on;
scatter(iz, test_y);
hold off; 

legend('Simple fit', 'Toolbox', 'Original data');

figure;
scatter(ox, oy);

% tmpf = @()simple_Gaussian_fit1_3(test_x, test_y)
% timeit(tmpf)

% tmpf_gaussian = @()fit(test_x, test_y,'gauss1')
% timeit(tmpf_gaussian)

