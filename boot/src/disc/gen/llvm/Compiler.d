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
module disc.gen.llvm.Compiler;

import disc.ast.Node;
import disc.ast.Visitor;
import disc.ast.Declaration;
import disc.ast.Statement;
import disc.ast.Expression;
import disc.gen.llvm.LLVM;


/**
* LLVM based Dis Compiler
*/
class Compiler : public AbstractVisitor
{
    ///LLVM Context
    private Context mContext;

    /// LLVM Builder
    private Builder mBuilder;

    ///Internal Types to LLVM Types

    /**
    * Constructor
    */
    public this()
    {
        mContext = new Context();
        mBuilder = new Builder(mContext);
    }

    /**
    * Compile AST
    */
    public void compile(Node ast)
    {
        ast.accept(this);
    }

    /**
    * Generate Code for Package
    */
    override void visit(PackageDeclaration pack)
    {
        auto mod = new Module(mContext, pack.mName);

        foreach(func; pack.mFunctions)
            func.accept(this);
        
        string filename = pack.mName ~ ".bc\0";
        mod.writeByteCode(filename);
    }

    /**
    * Compile Function Declaration
    */
    override void visit(FunctionDeclaration func)
    {
        //generate Function Declaration
        //function type
        
        //block Statement
        if(func.mBody !is null)
            func.mBody.accept(this);
    }

    /**
    * Generate Block Statement
    */
    override void visit(BlockStatement block)
    {
    }

    override void visit(ExpressionStatement expr){}
    override void visit(FunctionCall call){}
    
    //Basics
    override void visit(Declaration decl){}
    override void visit(Statement stat){}
    override void visit(Expression expr){}
} 
