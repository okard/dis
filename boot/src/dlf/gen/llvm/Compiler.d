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
import dlf.ast.Annotation;
import dlf.ast.Type;
import dlf.ast.SymbolTable;

import llvm = dlf.gen.llvm.LLVM;
import dlf.gen.llvm.Node;
import dlf.gen.Mangle;

//for debug
import std.stdio;

//NOTICE:  llc -filetype=obj foobar.bc; gcc foobar.o
//         llc -filetype=asm foobar.bc; gcc foobar.s


/**
* LLVM based Dis Compiler
*/
class Compiler : Visitor
{
    alias dlf.ast.Type.DataType astType;

    /// LLVM PassManager
    private llvm.PassManager mPassManager;
    
    /// LLVM Context
    private llvm.Context mContext;

    /// LLVM Builder
    private llvm.Builder mBuilder;

    ///Current LLVM Module
    private llvm.Module mCurModule;

    /// LLVM Types
    private llvm.Type mTypes[DataType];

    /// Current SymbolTable
    private SymbolTable mSymTbl;


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

        //At the moment char is same type as Byte
        mTypes[CharType.Instance] = mTypes[ByteType.Instance];
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
    void visit(PackageDeclaration pack)
    {
        //Create Module for Package
        auto mod = new llvm.Module(mContext, pack.Name);
        assign(pack, new ModuleNode(mod));
        mCurModule = mod;

        //Create Functions
        foreach(func; pack.Functions)
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
    void visit(FunctionDeclaration func)
    {
        //TODO look for Extension Methods
        //TODO look for class functions
        //TODO better check if always generated
        if(CNode!ValueNode(func) !is null)
            return;

        // template functions
        if(func.isTemplate)
        {
            //template functions can not generated
            //but has subtypes after semantic pass
            return;
        }

        llvm.Type type;
        //generate FuncType
        if(CNode!TypeNode(func.FuncType) is null)
        {
            type = Gen(func.FuncType);
            //add type to type hashmap
            assign(func.FuncType, new TypeNode(type));
        }
        else
            type = CNode!TypeNode(func.FuncType).LLVMType;

        //create llvm function
        auto mod = CNode!ModuleNode(func.Parent).LLVMModule;

        if(mod is null)
        {
            writeln("Cant get module");
            return;
        }

        auto t = cast(llvm.FunctionType)type;

        if(t is null)
        {
            writeln("Cant get functype");
            return;
        }
        
        //TODO: Function Name Mangling
        auto f = new llvm.FunctionValue(mod, t, func.Name);
        //f.setCallConv(llvm.LLVMCallConv.C);
        assign(func, new ValueNode(f));
        
        //store created function
        //func.Store.Compiler(f);
        
        //block Statement
        if(func.Body !is null)
            func.Body.accept(this);
    }

    void visit(ImportDeclaration){}

    /**
    * Generate Variables
    */
    void visit(VariableDeclaration)
    {
        //LLVM Values
    }

    /**
    * Generate Classes
    */
    void visit(ClassDeclaration)
    {
        //Classes are a llvm struct type
        
    }

    void visit(TraitDeclaration){}

    /**
    * Generate Block Statement
    */
    void visit(BlockStatement block)
    {
        //Generate Entry BasicBlock
        if(block.Parent.Type == NodeType.FunctionDeclaration)
        {
            
            auto func = cast(llvm.FunctionValue)CNode!ValueNode(block.Parent).LLVMValue;
            auto bb = new llvm.BasicBlock(func, "entry");
            assign(block, new BasicBlockNode(bb));

            auto b2 = new llvm.BasicBlock(func, "return");
            mBuilder.PositionAtEnd(b2);
            mBuilder.RetVoid();

            mBuilder.PositionAtEnd(bb);
            mBuilder.Br(b2);
            //generate return label?
            //generate return variable
        }

        //For If, Switch, For, While, Do -> new BasicBlock(parent.basicblock)

        //New Basic Block
        foreach(s; block.Statements)
            s.accept(this);
    }

    /**
    * Generate Expression Statement
    */
    void visit(ExpressionStatement stat)
    {
        stat.Expr.accept(this);
    }
    
    /**
    * Generate a Function Call
    */
    void visit(FunctionCall call)
    {
        //semantic pass should have resolved the function
        //get function: auto f =  (cast(FunctionDeclaration)call.Store.Semantic()
        //get llvmValue auto llvmF = cast(llvmFunctionDeclaration)f.Store.Compiler();
        //if not created then create???
    }


    void visit(DotIdentifier)
    {
        //Look into type
        //look wht to get here
        
    }

    void visit(Annotation){}

    //Basics
    void visit(Declaration decl){}
    void visit(Statement stat){}
    void visit(Expression expr){}

    /**
    * Convert Ast Type to LLVM Type
    */
    llvm.Type AstType2LLVMType(DataType t)
    {
        //writefln("CodeGen: resolve type %s", t.toString());

        //Gen PointerTypes?

        //Create Pointer Types
        if(cast(PointerType)t !is null)
        {
            auto pt = cast(PointerType)t;
            
            //Already Known Type to point to
            if(AstType2LLVMType(pt.PointType) !is null) 
            {
                return new llvm.PointerType(AstType2LLVMType(pt.PointType));
            }
            //gen PointType?
        }

        return mTypes.get(t, mTypes[OpaqueType.Instance]);
    }

    /**
    * CodeGen Function
    */
    private llvm.FunctionType Gen(FunctionType ft)
    {
        auto args = new llvm.Type[ft.Arguments.length];

        for(int i=0; i < ft.Arguments.length; i++)
        {
            args[i] = AstType2LLVMType(ft.Arguments[i]);
        }

        return new llvm.FunctionType(AstType2LLVMType(ft.ReturnType), args, ft.mVarArgs);
    }
    
    
    /**
    * extract compiler node
    */
    private static T CNode(T)(Node n)
        if(is(T : CompilerNode))
    {
        if(n is null)
            return null;

        if(n.Extend is null)
            return null;

        if(n.Extend.Type != NodeType.Special)
            return null;
        
        //go through extend Parent?

        return cast(T)n.Extend;
    }

    /**
    * Has CompilerNode
    */
    private static bool hasCNode(Node n)
    {
        return (CNode!CompilerNode(n) !is null);
    }

     /**
    * Assign a Node to Extend Property of Node
    */
    private static void assign(Node n, Node e)
    {
        if(n.Extend !is null)
             e.Parent = n.Extend;

        n.Extend = e;
    }
} 
