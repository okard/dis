/******************************************************************************
*    Dis Programming Language 
*    disc - Bootstrap Dis Compiler
*
*    disc is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    disc is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with disc.  If not, see <http://www.gnu.org/licenses/>.
*
******************************************************************************/
module dlf.gen.Mangle;

import dlf.ast.Node;
import dlf.ast.Declaration;

/**
* Class for generate mangling names
*/
class Mangle
{
    //ideas: package_class_method_param
    //example: dlf.gen.Mangle_clsMangle_this_v
    //for param language types

    //_Disdlf.gen.Mangle_clsMangle_this_
    //

    /**
    * Get mangled name for declaration 
    */
    string mangle(Declaration decl)
    {
        string name = decl.Name;

        //Functions have Parameters
        if(decl.DeclType == Declaration.Type.Function)
        {
           //TODO function append parameter
           //TODO right Function Types
        }

        //look backwards and add prefixes
        Node n = decl;
        while(decl.Parent !is null)
        {
            if(n.NodeType != Node.Type.Declaration)
                continue;
            
            switch(n.to!Declaration().DeclType)
            {
                case Declaration.Type.Package:
                    name = (cast(Declaration)n).Name ~ "_" ~ name;
                    break;
                case Declaration.Type.Class:
                    name = "cls" ~ (cast(Declaration)n).Name ~ "_" ~ name;
                    break;
                case Declaration.Type.Function:
                    name = "fcn" ~ (cast(Declaration)n).Name ~ "_" ~ name;
                default:
            }
    
            n = n.Parent;
        }

        name = "_Dis" ~ name;
        
        return name;
    }

    /**
    * Convert mangled string into readable string
    */
    string demangle(string mangled)
    {
        return "";
    }
}