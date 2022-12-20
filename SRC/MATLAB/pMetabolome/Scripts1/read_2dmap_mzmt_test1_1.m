
ifile = joinpath(getenv("RS_PROJ_DIR"), 'MasterHands', 'Examples', ...
    'kiff_files1', '101-QCE-P-C-5_10000x2400.rs2dm');

fh = fopen(ifile);
dat = uint8(fread(fh, 'uint8'));
fclose(fh);

[ dat2d, range_l_m, range_l_n ] = read_rs2d_binarydat1(dat);
noise_mt_range_bool = 2 <= range_l_n & range_l_n < 4;
noise_dat2d = double(dat2d( :, noise_mt_range_bool ));

dat2d_z = (double(dat2d) - mean(noise_dat2d, 2)) ./ std(noise_dat2d, 0, 2);

% image(range_l_m, range_l_n, log10(double(dat2d)+1), 'CDataMapping','scaled');
% image(range_l_n, range_l_m, log10(double(dat2d)), 'CDataMapping','scaled');
image(range_l_n, range_l_m, dat2d_z, 'CDataMapping','scaled');
set(gca,'YDir','normal');
caxis([0, 1.96]);
colorbar;

% plot(range_l_m, log10(double(dat2d(:, 100))))
% surf(dat2d_z(5000:6000, 1200:1500))

dat2d_z_sel = dat2d_z(range_l_m > 50, 4 <=range_l_n & range_l_n < 25);
dat2d_z_noise = dat2d_z(range_l_m > 50, 2 <= range_l_n & range_l_n < 4);
% image(dat2d_z(range_l_m > 50 , range_l_n < 25))

sum(dat2d_z_sel > 1.96, [1, 2]) / sum(dat2d_z_sel > -inf, [1, 2])
sum(mat_dir_shift_sum1(dat2d_z_sel > 1.96, 2^2 + 2^3) > 0, [1, 2]) / sum(dat2d_z_sel > -inf, [1, 2])


