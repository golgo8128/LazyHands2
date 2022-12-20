

imzs   =  [ 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, ...
            200, 210, 220, 230, 240, 250, 260, 270, 280, 290];
iintsts = [   7,   8,   7,   8,  20,  40,  60,  20,   7,   9, ...
              7,   8,   7,   8,  20,  60,  60,  20,   7,   9 ];

 [ omzs, ointsts, dat_length, lsqr_flag_f, not_peak_top_flag ] ...
    = scan_spectrum_gauss_fit1_3(imzs, iintsts);

scatter(omzs, ointsts);

