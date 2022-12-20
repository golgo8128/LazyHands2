package RS.Usefuls1;

import java.util.HashMap;

public class VariableType1 {
	

	public static char get_symb_from_varnam(String ivarname)
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

	/*
	static void Main()
	{
	
	    Console.WriteLine($"{get_symb_from_varnam("Int32")}");
	    Console.WriteLine($"{get_symb_from_varnam("Double")}");
	    Console.WriteLine("Hello World!");
	    Console.ReadKey();
	
	}
	*/

}
