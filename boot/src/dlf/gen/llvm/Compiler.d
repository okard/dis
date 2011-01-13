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
module dlf.gen.llvm.Compiler;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Type;

import llvm = dlf.gen.llvm.LLVM;
import dlf.gen.llvm.Node;


/**
* LLVM based Dis Compiler
*/
class Compiler : public AbstractVisitor
{
    alias dlf.ast.Type.DataType astType;

    /// LLVM PassManager
    private llvm.PassManager mPassManager;
    
    /// LLVM Context
    private llvm.Context mContext;

    /// LLVM Builder
    private llvm.Builder mBuilder;

    /// LLVM Types
    private llvm.Type mTypes[DataType];

    ///Internal Types to LLVM Types

    //Current SymbolTable

    /**
    * Constructor
    */
    public this()
    {
        mPassManager = new llvm.PassManager();
        mContext = new llvm.Context();
        mBuilder = new llvm.Builder(mContext);

        //Initialize types
        mTypes[OpaqueType.Instance] = new llvm.Type(llvm.LLVMOpaqueType());
        mTypes[VoidType.Instance] = new llvm.Type(llvm.LLVMVoidType());
        mTypes[BoolType.Instance] = new llvm.Type(llvm.LLVMInt1Type());
        mTypes[ByteType.Instance] = new llvm.Type(llvm.LLVMInt8Type());
        mTypes[UByteType.Instance] = new llvm.Type(llvm.LLVMInt8Type());
        mTypes[ShortType.Instance] = new llvm.Type(llvm.LLVMInt16Type());
        mTypes[UShortType.Instance] = new llvm.Type(llvm.LLVMInt16Type());
        mTypes[IntType.Instance] = new llvm.Type(llvm.LLVMInt32Type());
        mTypes[UIntType.Instance] = new llvm.Type(llvm.LLVMInt32Type());
        mTypes[LongType.Instance] = new llvm.Type(llvm.LLVMInt64Type());
        mTypes[ULongType.Instance] = new llvm.Type(llvm.LLVMInt64Type());
        mTypes[FloatType.Instance] = new llvm.Type(llvm.LLVMFloatType());
        mTypes[DoubleType.Instance] = new llvm.Type(llvm.LLVMDoubleType());
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
    * Entry Point for generating code for a package
    */
    override void visit(PackageDeclaration pack)
    {
        //Create Module for Package
        auto mod = new llvm.Module(mContext, pack.Name);
        pack.NodeStack.push(new CompilerNode());
        //pack.Store.Compiler(mod);

        //Create Functions
        foreach(func; pack.mFunctions)
        {
            func.accept(this);
        }
        
        //Write Package LLVM Moduel to file
        string filename = pack.Name ~ ".bc\0";
        mod.writeByteCode(filename);
        mod.dump();
    }

    /**
    * Compile Function Declaration
    */
    override void visit(FunctionDeclaration func)
    {
        //TODO better check if always generated
        //if(cast(ValueNode)func.NodeStack.top !is null)
        //    return;

        //generate FuncType
        //if(cast(TypeNode)func.FuncType.NodeStack.top !is null)
        //{
            
        //}

        //already generated
        //if(cast(llvm.FunctionValue)func.Store.Compiler())
        //    return;

        //generate Function Declaration
        
        //create function type
        /*
        //a function type -> function declarations?
        
        func.mType.Store.Compiler(new llvm.FunctionType(llvmBoolType, [llvmBoolType], false));

        //create llvm function
         auto f = new llvmFunctionValue(cast(Module)func.Parent.Store.Compiler(), 
                                       cast(llvmFunctionType)func.mType.Store.Compiler(), 
                                        func.mName);
        */
        //store created function
        //func.Store.Compiler(f);
        
        //block Statement
        if(func.Body !is null)
            func.Body.accept(this);
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
    llvm.Type AstType2LLVMType(DataType t)
    {
        return mTypes.get(t, mTypes[OpaqueType.Instance]);
    }

    /**
    * CodeGen Function
    */
    private llvm.Type Gen(FunctionType ft)
    {

        
        //new llvm.FunctionType(llvmBoolType, [llvmBoolType], false)
        return null;
    }
    
    
    /**
    * extract compiler node
    */
    private CompilerNode cnode(Node n)
    {
        //n.NodeStack.top.Type == Special
        //auto cn = cast(CompilerNode)n.NodeStack.top;
        //cn.CNType 
        return null;
    }
} 
