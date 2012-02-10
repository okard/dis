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
module dlf.gen.HeaderGen;

import std.stdio;
import std.file;
import std.path;

import dlf.ast.Visitor;


/**
* Generate Dis Header
*/
class HeaderGen : Visitor
{
    /// Header File
    private File hdr;

    /**
    * Create Header
    */
    void create(PackageDecl pd, string path)
    {
        //path.isDir();

        //create directory structure
        //file = join(path, pd.name )

        //hdr = File(file, "w");
        
        dispatchAuto(pd);
    }

    //Declarations
    void visit(PackageDecl pd)    
    { 
        //write package definition

    }
    
    void visit(ImportDeclaration id){  }
    void visit(FunctionDeclaration fd){  }
    void visit(VariableDeclaration vd){  }
    void visit(ClassDeclaration cd){  }
    void visit(TraitDeclaration td){  }
    void visit(StructDeclaration sd){}

    //Statements
    void visit(BlockStmt bs){  }
    void visit(ExpressionStmt es){  }
    void visit(ReturnStmt rs){  }

    //Expressions
    void visit(LiteralExpression le){  }
    void visit(CallExpression ce){  }
    void visit(IdentifierExpression di){  }
    void visit(BinaryExpression be){  }

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
            dispatchAuto(elements[i]);
        }
    }
}
