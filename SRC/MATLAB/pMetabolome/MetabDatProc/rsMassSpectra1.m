
classdef rsMassSpectra1 < handle

    properties(SetAccess = private)

        mts
        mzss
        intstss

    end

    methods
        function rms = rsMassSpectra1(mts, spectra_mzss, spectra_intstss)
    
            rms.mts = mts;
            rms.mzss = spectra_mzss;
            rms.intstss = spectra_intstss;

        end

        function [ mspectra ] = get_mspectra_struct(rms)
    
            mspectra.mts = rms.mts;
            mspectra.mzss = rms.mzss;
            mspectra.intstss = rms.intstss;

        end

        function [ spectrum, closest_mt ] = get_spectrum(rms, imt)

            [ closest_mt, closest_mt_idx ] = ...
                closest_value_in_sorted(rms.mts, imt);
                spectrum.mzs = rms.mzss{ closest_mt_idx };
                spectrum.intsts = rms.intstss{ closest_mt_idx };

        end
    
        function [ ephe, closest_mzs ] = get_ephe(rms, imz)

            [ intsts, closest_mzs ] = ...
                get_ephe_from_rsmmsd_simple(imz, rms.mzss, rms.intstss);


            ephe.mts = rms.mts;
            ephe.intsts = intsts;

        end

        function [ ephes_rsmat, closest_mzs_rsmat ] = get_ephes_rsmat(rms, itarget_mzs)

            [ ephes_mat, closest_mzs_mat ] = ...
                get_ephes_from_rsmmsd_simple(itarget_mzs, ... 
                    rms.get_mspectra_struct());
            
            ephes_rsmat = rsMat1(ephes_mat, itarget_mzs, rms.mts);
            closest_mzs_rsmat = rsMat1(closest_mzs_mat, itarget_mzs, rms.mts);

        end

        function [ closest_mt ] = plot_spectrum(rms, imt, varargin)

            [ spectrum, closest_mt ] = rms.get_spectrum(imt);
            plot(spectrum.mzs, spectrum.intsts, varargin{:});

        end

        function [ closest_mzs ] = plot_ephe(rms, imz, varargin)

            [ ephe, closest_mzs ] = rms.get_ephe(imz);
            plot(ephe.mts, ephe.intsts, varargin{:});

        end

    end
end
