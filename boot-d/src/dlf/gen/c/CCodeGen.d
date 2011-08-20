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
module dlf.gen.c.CCodeGen;

import dlf.ast.Visitor;
import dlf.ast.Node;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Type;

import dlf.gen.CodeGen;
import dlf.gen.HeaderGen;
import dlf.gen.c.CCodeWriter;

/**
* C Code Generator
*/
class CCodeGen : CodeGen, Visitor
{
    /// Compile Context
    private Context ctx;

    /// Header generator
    private HeaderGen hdrgen;

    /// Code Writer
    private CCodeWriter writer;

    /// Current C Package
    private CCodeWriter.CPackage p;

    ///Compiler Flags
    private string[] compilerFlags = [ "-std=c99", "-c", "-Wall", "-g" ];

    //Linker Flags
    //Link Runtime at default

    /**
    * Ctor
    */
    this(Context ctx)
    {
        this.ctx = ctx;
        hdrgen = new HeaderGen();
    }

    /**
    * Compile Package
    */
    void compile(PackageDeclaration pd)
    {
        //Create C Package
        p = writer.Package("", "");

        //compile imports?
        //compile other packages first or look if they already compiled

        //p.start
        //include default header dish.h

        dispatchAuto(pd);

        //check package imports they should go in first
        
        //p.close
        


        //if executable, create main.c file with runtime handling and main function call
        //embed runtime etc

        //resulting c files -> compile -> link
        


        //For Libraries generate Header Files
        if(ctx.Type == TargetType.StaticLib || ctx.Type == TargetType.SharedLib)
        {
        }
    }

    //package -> c package (header, src)

    // Steps:
    //1. package -> *.c, *.h -> List of c files (Path: .objdis/src/*.c,*.h)
    //2. *.c -> *.obj -> List of Objects (Compiler Options)
    //3. *.obj -> binary (Linker Options)

    //debug infos with #line


    /**
    * Compile Package Declaration
    */
    Node visit(PackageDeclaration pd)
    { 
        //Imports
        
        return pd; 
    }

    /**
    * Compile Import Declarations
    */
    Node visit(ImportDeclaration id)
    {
        //imports are includes
        //get compile header name
        
        return id; 
    }

    /**
    * Compile FunctionDeclaration
    */
    Node visit(FunctionDeclaration fd)
    { 
        //for def(C) declarations -> create c definitions

        //compile FunctionType fd.Instances
        //mangle name?

        return fd; 
    }

    Node visit(VariableDeclaration vd){ return vd;}
    Node visit(ClassDeclaration cd){ return cd; }
    Node visit(TraitDeclaration td){ return td; }
    //Statements
    Node visit(BlockStatement bs){ return bs; }
    Node visit(ExpressionStatement es){ return es; }
    Node visit(ReturnStatement rt){ return rt; }
    //Expressions
    Node visit(LiteralExpression le){ return le; }
    Node visit(CallExpression fc){ return fc; }
    Node visit(DotIdentifier di){ return di; }
    Node visit(AssignExpression ae){ return ae; }
    Node visit(BinaryExpression be){ return be; }


    /**
    * Auto Dispatch
    */
    private T dispatchAuto(T)(T e)
    {
        return cast(T)dispatch(e, this);
    }

    /**
    * Map Dispatch to Arrays
    */
    private void mapDispatch(T)(T[] elements)
    {
        for(int i=0; i < elements.length; i++)
        {
            /*elements[i] =*/ dispatchAuto(elements[i]);
        }
    }

}