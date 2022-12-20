using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace DataStruct
{

    public class SimpleTable_test
    {

        static void Main()
        {

            string test_tsv_file =
                Path.Combine(Environment.GetEnvironmentVariable("RS_PROG_DIR"),
                    "ProgTestData", "MetabDataSample", "annotlist_RSC1_test1_1.csv");
                    // "DataReadTest1", "testcsv1.csv");

            /* string test_tsv_file = Path.Combine(Environment.GetEnvironmentVariable("RS_TRUNK_DIR"),
                "cWorks", "Project", "MetabolomeGeneral", "CE-MS", "STDs", "Cation",
                "RefSTD_C114_annotlist20200303.csv");
            */

            SimpleTable tbl1 = new SimpleTable(test_tsv_file, 0, 1, ',');

            // tblfiledim tmpdim = tbl1.get_dim_from_file();
            tbl1.import_tbl();
            tbl1.print_tbl();

            string[] strs_mzs = tbl1.get_colvec("m/z");
            string[] strs_ppms = tbl1.get_colvec("ppm");

            double[] mzs = strs_mzs.Select(tmpmz => double.Parse(tmpmz)).ToArray();
            double[] ppms = strs_ppms.Select(tmpppm => double.Parse(tmpppm)).ToArray();

            double[] mz_min = new double[mzs.Length];
            double[] mz_max = new double[mzs.Length];
            for (int i = 0; i < mzs.Length; i++)
            {
                mz_min[i] = mzs[i] * (1 - ppms[i] / Math.Pow(10, 6));
                mz_max[i] = mzs[i] * (1 + ppms[i] / Math.Pow(10, 6));

            }

            Console.WriteLine(test_tsv_file);
            Console.ReadKey();

        }

    }
}
