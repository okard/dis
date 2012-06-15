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

import std.string;
import std.array;
import std.conv;

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
    static string mangle(FunctionDecl f, FunctionType t)
    {
        string name;

        int i = 0;
        foreach(DataType dt; t.Arguments)
        {
            name = format("%d%s%s",i, dt.toString(), name);
            i++;
        }

        //f.FuncDecl
        //first generate mangle for function type
        //then add function decl
        //then add parent function 
  
        Node n = f;
        while(n !is null)
        {
            Declaration d = n.to!Declaration;
            if(n is null)
            {
                n = n.Parent;
                continue;
            }

            switch(d.Kind)
            {
                case NodeKind.PackageDecl: 
                    name = "pkg" ~ to!(string)(d.Name.length) ~ d.Name.replace(".","_") ~ name; 
                    break;
                case NodeKind.FunctionDecl: 
                    name = "fnc" ~ to!(string)(d.Name.length) ~ d.Name ~ name; 
                    break;
                case NodeKind.StructDecl:
                    name = "sct" ~ to!(string)(d.Name.length) ~ d.Name ~ name; 
                    break;
                case NodeKind.ClassDecl: 
                    name = "cls" ~ to!(string)(d.Name.length) ~ d.Name ~ name; 
                    break;
                case NodeKind.TraitDecl: 
                    name = "trt" ~ to!(string)(d.Name.length) ~ d.Name ~ name; 
                    break;

                default:
            }
            
            n = n.Parent;
        }
        
        name = "_dis" ~ name;
        return name;
    }

    //mangle class type
    //mangle struct types

    /**
    * Get mangled name for declaration 
    */
    /*static string mangle(Declaration decl)
    {
        string name = "";
        //Functions have Parameters
        if(decl.Kind == NodeKind.FunctionSymbol)
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
            
            auto d = n.to!Declaration;

            switch(d.Kind)
            {
                case NodeKind.PackageDecl:
                    name = d.Name ~ name;
                    break;
                case NodeKind.ClassDecl:
                    name = "_cls" ~ d.Name ~ name;
                    break;
                case NodeKind.FunctionSymbol:
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
    }*/

    /**
    * Convert mangled string into readable string
    */
    static string demangle(string mangled)
    {
        return "";
    }
}