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
static class Mangle
{
    //ideas: package_class_method_param
    //example: dlf.gen.Mangle_clsMangle_this_v
    //for param language types

    //_Disdlf.gen.Mangle_clsMangle_this_
    //

    /**
    * Get mangled name for declaration 
    */
    static string mangle(Declaration decl)
    {
        string name = "";
        //Functions have Parameters
        if(decl.DeclType == Declaration.Type.Function)
        {
           //TODO function append parameter
           //TODO right Function Types
        }

        //look backwards and add prefixes
        Node n = decl;
        
        while(true)
        {
            if(n.NodeType != Node.Type.Declaration)
                continue;
            
            auto d = cast(Declaration)n;

            switch(d.DeclType)
            {
                case Declaration.Type.Package:
                    name = d.Name ~ name;
                    break;
                case Declaration.Type.Class:
                    name = "_cls" ~ d.Name ~ name;
                    break;
                case Declaration.Type.Function:
                    name = "_fcn" ~ d.Name ~ name;
                    break;
                default:
            }
    
            n = n.Parent;

            if(n is null)
                break;
        }

        name = "_Dis" ~ name;
        
        return name;
    }

    /**
    * Convert mangled string into readable string
    */
    static string demangle(string mangled)
    {
        return "";
    }
}