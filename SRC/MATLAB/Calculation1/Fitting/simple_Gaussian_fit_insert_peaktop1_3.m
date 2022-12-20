function [ coeffz_a, center_x, extrem_y, ox, oy, iz, centr, factr ] = ...
    simple_Gaussian_fit_insert_peaktop1_3(ix, iy) % , varargin)

    ix = reshape(ix, [], 1);
    iy = reshape(iy, [], 1);

    [ iz, centr, factr ] = scale_by_approx(ix);

    [ coeffz_a, center_z, extrem_y ] = ...
        simple_Gaussian_fit1_4(iz, iy);

    center_x = center_z * factr + centr;

    % closest_ix, closest_idx
    [ ~, ~, ox, oy_cell ] ...
        = closest_value_in_sorted_target_val_greater_insert( ...
        transpose(ix), center_x, extrem_y, { transpose(iy) }); % varargin{:});

    oy = oy_cell{1};

end




