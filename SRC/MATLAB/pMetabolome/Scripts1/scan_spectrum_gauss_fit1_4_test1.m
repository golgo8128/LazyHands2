

% imzs   =  [ 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, ...
%             200, 210, 220, 230, 240, 250, 260, 270, 280, 290];
% iintsts = [   7,   8,   7,   8,  20,  40,  60,  20,   7,   9, ...
%               7,   8,   7,   8,  20,  60,  60,  20,   7,   9 ];

% imzs =    [ 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, ...
%             21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ];
% iintsts = [ 15, 10, 15, 15, 10, 10, 20, 10, 10, 10, ...
%             12, 15, 16, 17, 18, 19, 18, 20, 21, 11 ];

imzs    = [ 13, 14, 15, 16, 17, 18, 19, 20, ...
            21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ];
iintsts = [ 21, 22, 22, 21, 10  31, 32, 30, 29, 10, ...
            50, 49, 48, 47, 46, 45, 44, 43, 42, 41 ];

% imzs = [
%   298.0180
%   298.0380
%   298.0580
%   298.0780
%   298.0980
%   298.1180
%   298.1380
%   298.1570
%   298.1770
%   298.1970
%   298.2170
%   298.2370
%   298.2570
% ]';
% 
% iintsts = [
%     30
%     51
%     31
%     32
%     60
%     57
%     69
%    123
%     29
%     79
%     61
%     32
%     92
% ]';


 [ omzs, ointsts, dat_length, not_peak_top_flag ] ...
    = scan_spectrum_gauss_fit1_4(imzs, iintsts);

disp(horzcat(omzs(1:dat_length)', ointsts(1:dat_length)'));


% scatter(omzs, ointsts);

