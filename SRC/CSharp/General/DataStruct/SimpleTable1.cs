using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace DataStruct
{
    public class SimpleTable
    {
        public string filename;
        public string[] rownames;
        public string[] colnames;
        public string[,] tbl;

        private int rowname_flag;
        private int colname_flag;
        private char sep;
        private struct tabledatdim
        {
            public int num_rows;
            public int num_cols;
            public string[,] tbl; // public string[,]? tbl;

        }

        tabledatdim tbldatdim;

        public SimpleTable(
            string ifilename,
            int irowname_flag, int icolname_flag, char isep)
        {

            this.filename = ifilename;
            this.rowname_flag = irowname_flag;
            this.colname_flag = icolname_flag;
            this.sep = isep;

        }

        public void print_tbl()
        {
            Console.Write("\t");
            Console.WriteLine(String.Join("\t", this.colnames));
            for(int i = 0;i < this.rownames.Length; i++)
            {
                Console.Write($"{this.rownames[i]}");
                for(int j = 0;j < this.colnames.Length;j ++)
                    Console.Write($"\t{this.tbl[i, j]}");
                Console.WriteLine();

            }

        }

        public string[] get_colvec(int idx_col)
        {
            string[] ocolvec = new string[this.rownames.Length];
            for (int i = 0; i < this.rownames.Length; i++)
            {
                ocolvec[i] = this.tbl[i, idx_col ];
            }

            return ocolvec;

        }

        public string[] get_colvec(string icolnam)
        {
            int idx_hit_colnam = Array.IndexOf(this.colnames, icolnam);
            if (idx_hit_colnam < 0)
                throw new Exception($"Column name {icolnam} not found in file {this.filename}");

            return this.get_colvec(idx_hit_colnam);

        }

        public void import_tbl()
        {

            tabledatdim tblfildim_pre = this.pre_import_tbl();

            int row_start_idx = 0;
            int col_start_idx = 0;

            if (this.colname_flag > 0)
                row_start_idx = 1;

            if (this.rowname_flag > 0)
                col_start_idx = 1;

            this.rownames = new string[tblfildim_pre.num_rows - row_start_idx];
            this.colnames = new string[tblfildim_pre.num_cols - col_start_idx];
            this.tbl = new string[this.rownames.Length, this.colnames.Length];

            for(int i_pre = row_start_idx; i_pre < tblfildim_pre.num_rows;i_pre ++)
                for(int j_pre = col_start_idx; j_pre < tblfildim_pre.num_cols;j_pre++)
                {
                    int i = i_pre - row_start_idx;
                    int j = j_pre - col_start_idx;
                    this.tbl[i, j] = tblfildim_pre.tbl[i_pre, j_pre];

                }


            for (int i = 0; i < this.rownames.Length; i++)
                this.rownames[i] = $"Row{i}";
            for (int j = 0; j < this.colnames.Length; j++)
                this.colnames[j] = $"Col{j}";

            if(this.rowname_flag > 0)
                for (int i_pre = row_start_idx; i_pre < tblfildim_pre.num_rows; i_pre++)
                {
                    int i = i_pre - row_start_idx;
                    this.rownames[i] = tblfildim_pre.tbl[i_pre, 0];
                }

            if (this.colname_flag > 0)
                for (int j_pre = col_start_idx; j_pre < tblfildim_pre.num_cols; j_pre++)
                {
                    int j = j_pre - col_start_idx;
                    this.colnames[j] = tblfildim_pre.tbl[0, j_pre];
                }

        }


        private tabledatdim pre_import_tbl()
        {

            tabledatdim tblfildim_pre = this.get_dim_from_file();

            tblfildim_pre.tbl
                = new string[tblfildim_pre.num_rows, tblfildim_pre.num_cols ];
            StreamReader fh = new StreamReader(this.filename);

            int row_ct = 0;
            while (!fh.EndOfStream)
            {
                string rline = fh.ReadLine();
                if (rline.Trim().Length > 0)
                {

                    string[] r;

                    if (this.sep == ',')
                        r = Regex.Split(rline, ",(?=(?:[^\"]*\"[^\"]*\")*(?![^\"]*\"))");
                    else
                        r = rline.Split(this.sep);

                    for(int j = 0;j < r.Length; j++)
                        tblfildim_pre.tbl[ row_ct, j ] = r[ j ].Trim().Trim('"');

                    row_ct++;

                }

            }
            
            fh.Close();

            return tblfildim_pre;

        }

        private tabledatdim get_dim_from_file()
        {
            tabledatdim ofildim;

            StreamReader fh = new StreamReader(this.filename);

            ofildim.num_rows = 0;
            ofildim.num_cols = 0;
            ofildim.tbl = null;

            while (!fh.EndOfStream)
            {
                string rline = fh.ReadLine().Trim();
                if (rline.Length > 0)
                {
                    string[] r = rline.Split(this.sep);
                    ofildim.num_rows++;
                    if(r.Length > ofildim.num_cols)
                    {
                        ofildim.num_cols = r.Length;
                    }
                }

            }

            fh.Close();

            return ofildim;
        }


    }
}
