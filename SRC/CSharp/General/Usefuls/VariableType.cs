using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace VariableType
{
    internal class VariableType
    {

        private static Dictionary<string, char> varname_to_symb_h
            = new Dictionary<string, char>()
            { { "SByte",   'c' },
              { "Byte",    'h' },
              { "Int32",   'i' },
              { "UInt32",  'j' },
              { "Int64",   'x' },
              { "UInt64",  'y' },
              { "Single",  'f' },
              { "Double",  'd' },
            };

        public static char get_symb_from_varnam(string ivarname)
        {
            if (varname_to_symb_h.ContainsKey(ivarname))
            {
                return varname_to_symb_h[ivarname];
            }
            else
            {
                throw new Exception($"Variable name \"{ivarname}\" not found");
            }

        }

        static void Main()
        {

            Console.WriteLine($"{get_symb_from_varnam("Int32")}");
            Console.WriteLine($"{get_symb_from_varnam("Double")}");
            Console.WriteLine("Hello World!");
            Console.ReadKey();

        }
    }
}
