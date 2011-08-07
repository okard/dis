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
import dlf.ast.Transform;

import llvm = dlf.gen.llvm.LLVM;
import dlf.gen.llvm.Node;
import dlf.gen.llvm.IdGen;
import dlf.gen.Mangle;

//for debug
import std.stdio;

//NOTICE:  llc -filetype=obj foobar.bc; gcc foobar.o
//         llc -filetype=asm foobar.bc; gcc foobar.s


/**
* LLVM based Dis Compiler
*/
class Compiler : AbstractVisitor
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

    /// Id generator
    private IdGen mIdGen;


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
        mTypes[BoolType.Instance] = new llvm.IntegerType(1);
        mTypes[ByteType.Instance] = new llvm.IntegerType(8);
        mTypes[UByteType.Instance] = new llvm.IntegerType(8);
        mTypes[ShortType.Instance] = new llvm.IntegerType(16);
        mTypes[UShortType.Instance] = new llvm.IntegerType(16);
        mTypes[IntType.Instance] = new llvm.IntegerType(32);
        mTypes[UIntType.Instance] = new llvm.IntegerType(32);
        mTypes[LongType.Instance] = new llvm.IntegerType(64);
        mTypes[ULongType.Instance] = new llvm.IntegerType(64);
        mTypes[FloatType.Instance] = new llvm.Type(llvm.LLVMFloatType());
        mTypes[DoubleType.Instance] = new llvm.Type(llvm.LLVMDoubleType());

        //At the moment char is same type as Byte
        mTypes[CharType.Instance] = mTypes[ByteType.Instance];
        mTypes[StringType.Instance] = mTypes[ByteType.Instance];
    }

    /**
    * Compile AST
    */
    public void compile(Node ast)
    {
        dispatch(ast, this);
    }

    /**
    * Generate Code for Package
    * Entry Point for generating code for a package
    */
    override void visit(PackageDeclaration pack)
    {
        //Create Module for Package
        auto mod = new llvm.Module(mContext, pack.Name);
        extend(pack, new ModuleNode(mod));
        mCurModule = mod;

        //Create Functions
        foreach(func; pack.Functions)
        {
            dispatch(func, this);
        }
        
        //Write Package LLVM Moduel to file
        string filename = pack.Name ~ ".bc\0";
        mod.writeByteCode(filename);
        mod.dump();
    }

    /**
    * Import Declaration does not require compiler action?
    */
    override void visit(ImportDeclaration)
    {
    }

    /**
    * Generate Classes
    */
    override void visit(ClassDeclaration)
    {
        //Classes are a llvm struct type
        //Create Struct
    }

    /**
    * Traits are also more semantic stuff?
    */
    override void visit(TraitDeclaration)
    {
    }

    /**
    * Compile Function Declaration
    */
    override void visit(FunctionDeclaration func)
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
            //generate required function instances here
            return;
        }

        llvm.Type type;
        //generate FuncType
        if(CNode!TypeNode(func.FuncType) is null)
        {
            type = Gen(func.FuncType);
            //add type to type hashmap
            extend(func.FuncType, new TypeNode(type));
        }
        else
            type = CNode!TypeNode(func.FuncType).LLVMType;

        auto t = cast(llvm.FunctionType)type;

        if(t is null)
        {
            writeln("Cant get functype");
            return;
        }

        // Generate Value

        //TODO: Function Name Mangling
        auto mangledName = Mangle.mangle(func);
        Information("Mangled Name: %s", mangledName);
        auto f = new llvm.FunctionValue(mCurModule, t, func.Name);
        //f.setCallConv(llvm.LLVMCallConv.C);
        extend(func, new ValueNode(f));
       
        //block Statement
        if(func.Body !is null)
            dispatch(func.Body, this);
    }

    /**
    * Generate Variables
    */
    override void visit(VariableDeclaration var)
    {
        //LLVM Values
        //Create new Var 
        mBuilder.Alloca(AstType2LLVMType(var.VarDataType), "_var_"~var.Name);
        //TODO Initialize Variable
    }

    /**
    * Generate Block Statement
    */
    override void visit(BlockStatement block)
    {
        //Variables, Inner Functions and classes

        //Function Basic Blocks
        if(block.Parent.NodeType == Node.Type.Declaration 
        && (cast(Declaration)block.Parent).DeclType == Declaration.Type.Function)
        {
            auto funcDecl = cast(FunctionDeclaration)block.Parent;
            auto funcCNode = CNode!ValueNode(funcDecl);
            auto funcVal = cast(llvm.FunctionValue)funcCNode.LLVMValue;

            //check for function Template
            //semantic should have removed body and add seperated typed functions
            if(funcDecl.isTemplate)
            {
                Information("Skip %s is Function Template", funcDecl.Name);
            }

            assert(funcDecl !is null);
            assert(funcCNode !is null);
            assert(funcVal !is null);

            //generate Function Block Node
            auto fbb = new FunctionBlockNode();
            extend(block, fbb);
            
            // entry block
            fbb.entry = new llvm.BasicBlock(funcVal, "entry");
            
            //TODO gen return value
            mBuilder.PositionAtEnd(fbb.entry);

            if(funcDecl.FuncType.ReturnType != VoidType.Instance)
            {
                //fbb.retValue = mBuilder.Alloca(func.returnType
            }

            //return block
            fbb.ret = new llvm.BasicBlock(funcVal, "return");
            mBuilder.PositionAtEnd(fbb.ret);
            
            mBuilder.RetVoid();

            //go to entry block
            mBuilder.PositionAtEnd(fbb.entry);

            //Build Variables on Stack
            foreach(Declaration sym; block.SymTable)
                dispatch(sym, this);

            //Build Statements for Function
            foreach(s; block.Statements)
                dispatch(s, this);

            //jump to return label
            mBuilder.Br(fbb.ret);
            return;
        }

        //For If, Switch, For, While, Do -> new BasicBlock(parent.basicblock)

        //Position mBuilder;

        //New Basic Block
        foreach(s; block.Statements)
            dispatch(s, this);
    }

    /**
    * Generate Expression Statement
    */
    override void visit(ExpressionStatement stat)
    {
        dispatch(stat.Expr, this);
    }

    /**
    * Visit ReturnStatement
    */
    override void visit(ReturnStatement rs)
    {
        //assign to variable retval the expression result
        //jump to label return
    }
    
    /**
    * Generate a Function Call
    */
    override void visit(FunctionCall call)
    {
        //semantic pass should have resolved the function
        
        //Require Function Declaration
        FunctionDeclaration funcDecl;
        
        //check for dot identifier
        if(cast(FunctionDeclaration)call.Function.Extend is null)
        {
            Error("FunctionCall has no Function to Call");
            return;
        }
        else
        {
            funcDecl = cast(FunctionDeclaration)call.Function.Extend;
        }
        //call.Extend should be FunctionDeclaration
        //generate calling expressions


        llvm.Value[] callArgs;
        foreach(arg; call.Arguments)
        {
            dispatch(arg, this);
            llvm.Value value;

            //TODO Right Handling for Types

            //string  literal handling
            if(arg.NodeType == Node.Type.Expression
            && arg.ExprType == Expression.Type.Literal
            && (cast(Expression)arg).ReturnType == StringType.Instance)
            {
                auto val = CNode!ValueNode(arg).LLVMValue;
                value = val;
            }
            
            callArgs ~= value;
        }
        
        //get FunctionValue from Function Declaration
        auto f = cast(llvm.FunctionValue)CNode!ValueNode(funcDecl).LLVMValue;

        //Function Value to Call
        if(f is null)
        {
            Error("Calling Function %s has not been generated", funcDecl.Name);
            return;
        }
        
        auto result = mBuilder.Call(f, callArgs, funcDecl.FuncType.ReturnType == VoidType.Instance ? "" : mIdGen.GenVar);
        
        //get function: auto f =  (cast(FunctionDeclaration)call.Store.Semantic()
        //get llvmValue auto llvmF = cast(llvmFunctionDeclaration)f.Store.Compiler();
        //if not created then create???
    }

    /**
    * Dot Identifier 
    */
    override void visit(DotIdentifier)
    {
        //Look into type
        //look wht to get here
        
    }

    /**
    * Literal Expression
    */
    override void visit(LiteralExpression le)
    {
        //Generate Constant Values
        if(le.ReturnType == StringType.Instance)
        {
            //string stored at global context
            auto str = llvm.Value.ConstString(le.Value);
            
            //TODO generate ids to store the strings
            auto val = mCurModule.AddGlobalConstant(str.TypeOf(), mIdGen.GenConstString);
            val.SetInitializer(str);
            llvm.LLVMSetGlobalConstant(val.llvmValue, true);
            val.SetLinkage(llvm.LLVMLinkage.Internal);
  
            //assign direct the right pointer
            auto zero = (cast(llvm.IntegerType)mTypes[IntType.Instance]).Zero;

            //it seems that GEP is really a value and isnt append zu current mBuilder Position
            auto value = mBuilder.GEP(val, [zero, zero], "");

            extend(le, new ValueNode(value));
        }
    }

    /**
    * Create Assign Expression
    */
    override void visit(AssignExpression ae)
    {
        //store or load right value into
        // the variable
    }

    /**
    * Create Binary Expression
    */
    override void visit(BinaryExpression be)
    {
        //instructions for real and integer?
        //check return type
        
        switch(be.Op)
        {
            case BinaryExpression.Operator.Add:
                break;
            default:
        }
    }

    /**
    * Convert Ast Type to LLVM Type
    * Look for always generated, basic types, pointer types
    */
    llvm.Type AstType2LLVMType(DataType t)
    {
        //Information("CodeGen: resolve type %s", t.toString());

        //type has generated node
        if(hasCNode(t))
        {
            auto type = CNode!TypeNode(t);
            return type.LLVMType;
        }

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
    * Generates a LLVM FunctionType from a AST FunctionType
    */
    private llvm.FunctionType Gen(FunctionType ft)
    {
        auto args = new llvm.Type[ft.Arguments.length];

        if(ft.ReturnType == OpaqueType.Instance)
            Error("Opaque Return Type");

        //add types
        for(int i=0; i < ft.Arguments.length; i++)
        {
            auto t = AstType2LLVMType(ft.Arguments[i]);
            
            //check for opaque types as parameters
            if(ft.Arguments[i] == OpaqueType.Instance)
                Error("Opaque Parameter Type in Function Type Generation");
            
            args[i] = t;
        }

        return new llvm.FunctionType(AstType2LLVMType(ft.ReturnType), args, ft.mVarArgs);
    }

    /**
    * Information Log
    */
    private void Information(T...)(string s, T args)
    {
        writefln(s, args);
    }

    /**
    * Error Log
    */
    private void Error(T...)(string s, T args)
    {
        writefln(s, args);
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

        if(n.Extend.NodeType != Node.Type.Special)
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
} 
