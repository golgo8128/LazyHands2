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
            string tmp_rsmspra_file = Path.Combine(tmpdir, "testmspectrum_mini2.rsmspra");

            Directory.CreateDirectory(tmpdir);

            MassSpectrum_simple<float, int>mspec = new MassSpectrum_simple<float, int>();

            float[] test_mzs1 = { 0.1F, 0.2F, 0.4F };
            int[] test_intsts1 = { 1, 4, 16 };
            float[] test_mzs2 = { 0.4F, 0.7F, 1.7F, 2.1F };
            int[] test_intsts2 = { 2, 1, 4, 16 };
            float[] test_mzs3 = { 0.7F, 1.7F };
            int[] test_intsts3 = { 2, 4 };

            //mspec.set_spectrum(test_mzs1.Length, test_mzs1, test_intsts1);
            mspec.set_spectrum(test_mzs2.Length, test_mzs2, test_intsts2);
            //mspec.set_spectrum(test_mzs3.Length, test_mzs3, test_intsts3);

            mspec.print_spectrum();
            mspec.output_spectrum_to_txtfile(tmp_txt_file);

            BinaryWriter tmp_bfw = new BinaryWriter(File.Open(tmp_rsmspra_file, FileMode.Create));

            mspec.output_to_file(tmp_bfw);

            Console.WriteLine(tmp_rsmspra_file);
            Console.ReadKey();

        }
    }

}
