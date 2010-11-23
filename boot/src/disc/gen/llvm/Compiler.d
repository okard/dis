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
import disc.ast.Type;
import llvm = disc.gen.llvm.LLVM;


/**
* LLVM based Dis Compiler
*/
class Compiler : public AbstractVisitor
{
    alias disc.ast.Type.Type astType;

    ///LLVM Context
    private llvm.Context mContext;

    /// LLVM Builder
    private llvm.Builder mBuilder;

    /// LLVM Types
    private llvm.Type mTypes[astType];

    ///Internal Types to LLVM Types

    //Current SymbolTable

    /**
    * Constructor
    */
    public this()
    {
        mContext = new llvm.Context();
        mBuilder = new llvm.Builder(mContext);

        //Initialize types
        //mTypes[Parser.InternalTypes["bool"]] = new Type(LLVMInt1Type())
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
        //Create Module for Package
        auto mod = new llvm.Module(mContext, pack.mName);
        pack.Store.Compiler(mod);

        //Create Functions
        foreach(func; pack.mFunctions)
        {
            func.accept(this);
        }
        
        //Write Package LLVM Moduel to file
        string filename = pack.mName ~ ".bc\0";
        mod.writeByteCode(filename);
    }

    /**
    * Compile Function Declaration
    */
    override void visit(FunctionDeclaration func)
    {
        //already generated
        if(cast(llvm.FunctionValue)func.Store.Compiler())
            return;

        //generate Function Declaration
        
        //create function type
        /*
        func.mType.Store.Compiler(new llvm.FunctionType(llvmBoolType, [llvmBoolType], false));

        //create llvm function
         auto f = new llvmFunctionValue(cast(Module)func.Parent.Store.Compiler(), 
                                       cast(llvmFunctionType)func.mType.Store.Compiler(), 
                                        func.mName);
        */
        //store created function
        //func.Store.Compiler(f);
        
        //block Statement
        if(func.mBody !is null)
            func.mBody.accept(this);
    }

    /**
    * Generate Block Statement
    */
    override void visit(BlockStatement block)
    {
        //value from parent node
        //auto bl = new llvm.BasicBlock(cast(llvm.Value)block.Parent.Store.Compiler(), "block");
    }

    override void visit(ExpressionStatement expr){}
    
    /**
    * Generate a Function Call
    */
    override void visit(FunctionCall call)
    {
        //semantic pass should have resolved the function
        //get function: auto f =  (cast(FunctionDeclaration)call.Store.Semantic()
        //get llvmValue auto llvmF = cast(llvmFunctionDeclaration)f.Store.Compiler();
        //if not created then create???
    }
    
    //Basics
    override void visit(Declaration decl){}
    override void visit(Statement stat){}
    override void visit(Expression expr){}

    /**
    * Convert Ast Type to LLVM Type
    */
    llvm.Type AstType2LLVMType(astType t)
    {
        //lookup in mTypes
        return null;
    }
} 
