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
import dlf.ast.Type;

/**
* Class for generate mangling names
*/
static class Mangle
{
    //ideas: package_class_method_param
    //templates?
    //example: dlf.gen.Mangle_clsMangle_this_v
    //for param language types

    //_Disdlf.gen.Mangle_clsMangle_this_
    //

    //mangle datatype?
    //static string mangle(DatatType type)


    /**
    * Mangle a FunctionType
    */
    static string mangle(FunctionType f)
    {
        //f.FuncDecl
        //first generate mangle for function type
        //then add function decl
        //then add parent function 

        string name;
        Node n = f.FuncDecl;
        while(n !is null)
        {
            Declaration d = cast(Declaration)n;
            if(n is null)
            {
                n = n.Parent;
                continue;
            }

            switch(d.Kind)
            {
                case NodeKind.PackageDeclaration:
                case NodeKind.ClassDeclaration:
                case NodeKind.TraitDeclaration:
                case NodeKind.FunctionDeclaration: name = d.Name ~ name; break;
                default:
            }
            
            n = n.Parent;
        }
        
        return name;
    }

    //mangle class type
    //mangle struct types

    /**
    * Get mangled name for declaration 
    */
    static string mangle(Declaration decl)
    {
        string name = "";
        //Functions have Parameters
        if(decl.Kind == NodeKind.FunctionDeclaration)
        {
            //Require name for instance!!!
           //TODO function append parameter
           //TODO right Function Types
        }

        //look backwards and add prefixes
        Node n = decl;
        
        while(true)
        {
            if(!isDeclaration(n))
                continue;
            
            auto d = cast(Declaration)n;

            switch(d.Kind)
            {
                case NodeKind.PackageDeclaration:
                    name = d.Name ~ name;
                    break;
                case NodeKind.ClassDeclaration:
                    name = "_cls" ~ d.Name ~ name;
                    break;
                case NodeKind.FunctionDeclaration:
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