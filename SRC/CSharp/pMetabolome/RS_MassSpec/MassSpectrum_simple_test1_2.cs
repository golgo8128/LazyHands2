using rsMassSpec;
using System;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReadAgilent_dot_d1
{
    internal class MassSpectrum_simple_test1
    {
        static void Main(string[] args)
        {

            string tmpdir = 
                Path.Combine(Environment.GetEnvironmentVariable("RS_TMP_DIR"), "rs_MSpectra");

            string tmp_txt_file = Path.Combine(tmpdir, "testmspectrum_mini2.txt");
            string tmp_rsmspra_file = Path.Combine(tmpdir, "testmspectrum_mini_cs2.rsmspra");

            Directory.CreateDirectory(tmpdir);

            double[] test_mzs0 = { 0.1, 0.2, 0.4 };
            int[] test_intsts0 = { 1, 4, 16 };
            double[] test_mzs1 = { 0.4, 0.7, 1.7, 2.1 };
            int[] test_intsts1 = { 2, 1, 4, 16 };
            double[] test_mzs2 = { 0.7, 1.7 };
            int[] test_intsts2 = { 2, 4 };

            RS_MassSpectra_simple<float, double, int> rsmspectra = new RS_MassSpectra_simple<float, double, int>(3);

            MassSpectrum_simple<double, int>mspec0 = new MassSpectrum_simple<double, int>();
            mspec0.set_spectrum(test_mzs0.Length, test_mzs0, test_intsts0);
            rsmspectra.add_spectrum(1.3f, mspec0);

            MassSpectrum_simple<double, int> mspec1 = new MassSpectrum_simple<double, int>();
            mspec1.set_spectrum(test_mzs1.Length, test_mzs1, test_intsts1);
            rsmspectra.add_spectrum(1.8f, mspec1);

            MassSpectrum_simple<double, int> mspec2 = new MassSpectrum_simple<double, int>();
            mspec2.set_spectrum(test_mzs2.Length, test_mzs2, test_intsts2);
            rsmspectra.add_spectrum(2.3f, mspec2);


            RS_MassSpectra_simple_RW<float, double, int, long> rsmspectra_w
                = new RS_MassSpectra_simple_RW<float, double, int, long>(rsmspectra);
            rsmspectra_w.output_to_file(tmp_rsmspra_file, 256);


            // BinaryWriter tmp_bfw = new BinaryWriter(File.Open(tmp_rsmspra_file, FileMode.Create));


            Console.WriteLine(tmp_rsmspra_file);
            Console.ReadKey();

        }
    }

}
