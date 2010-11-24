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
module disc.gen.llvm.LLVM;
// This Module wraps LLVM C API back to Classes

import llvm.c.Core;
import llvm.c.BitWriter;

import disc.ast.Node;


/**
* LLVM Context
*/
class Context : NodeData
{
    // Global Context Instance
    private static Context mGlobal;
    // LLVM Context 
    private LLVMContextRef mContext;

    /**
    * Create new Context
    */
    public this()
    {
        mContext = LLVMContextCreate();
    }

    /**
    * Create new Context
    */
    private this(LLVMContextRef context)
    {   
        mContext = context;
    }
    
    /**
    * Dtor
    */
    private ~this()
    {
        LLVMContextDispose(mContext);
    }
        
    /**
    * Static Ctor
    */
    public static this()
    {
        mGlobal = new Context(LLVMGetGlobalContext());
    }

    /**
    * Get the llvmContext
    */
    public LLVMContextRef llvmContext()
    {
        return mContext;
    }

    /**
    * Global Context
    */
    public static Context Global()
    {
        return mGlobal;
    }
} 

/**
* LLVM Module
*/
class Module : NodeData
{
    //LLVM Module
    private LLVMModuleRef mModule;

    /**
    * Create new Module
    */
    public this(Context context, string name)
    {
        mModule = LLVMModuleCreateWithNameInContext((cast(char[])name).ptr, context.llvmContext());
    }

    /**
    * Destructor
    */
    public ~this()
    {
        LLVMDisposeModule(mModule);
    }

    /**
    * dump
    */
    public void dump()
    {
        LLVMDumpModule(mModule);
    }

    /**
    * Writes ByteCode to File
    */
    public void writeByteCode(string file)
    {
        LLVMWriteBitcodeToFile(mModule, cast(char*)file.ptr);
    }

    /**
    * Get llvmModule
    */
    @property
    public LLVMModuleRef llvmModule() 
    {
        return mModule;
    }
}

/**
* LLVM Type
*/
class Type : NodeData
{
    /// LLVM Type
    private LLVMTypeRef mType;

    /**
    * Create type from type ref
    */
    private this(LLVMTypeRef type)
    {
        mType = type;
    }

    /**
    * Get LLVM type
    */
    @property
    public LLVMTypeRef llvmType()
    {
        return mType;
    }

    /**
    * LLVM Kind of Type
    */
    @property
    public LLVMTypeKind llvmTypeKind()
    {
        return LLVMGetTypeKind(mType);
    }
}

/*
    integer type
    real type
    function type
    sequence types:
       struct type
       array type
       pointer type
       vector type
    void type
    label type
    opaque type
*/

//Primary Types
static Type llvmBoolType;
static Type llvmInt8Type;
static Type llvmInt16Type;
static Type llvmInt32Type;
static Type llvmInt64Type;

//Create Primary Types
static this()
{
    llvmBoolType = new Type(LLVMInt1Type());
    llvmInt8Type = new Type(LLVMInt8Type());
    llvmInt16Type = new Type(LLVMInt16Type());
    llvmInt32Type = new Type(LLVMInt32Type());
    llvmInt64Type = new Type(LLVMInt64Type());
}

/**
* Function Type
*/
class FunctionType : Type
{
    /**
    * Create new FunctionType
    */
    this(Type retType, Type[] params, bool varargs)
    {   
        //Create Array with primary llvm types
        auto p = new LLVMTypeRef[params.length];
        for(int i = 0; i < params.length; i++)
            p[i] = params[i].llvmType;
            
        super(LLVMFunctionType(retType.llvmType, p.ptr, params.length, varargs));
    }
}

/**
* LLVM Value
*/
class Value : NodeData
{
    /// LLVM Value
    private LLVMValueRef mValue;


    /**
    * Get Type
    */
    public Type TypeOf()
    {
        return new Type(llvmTypeOf());
    }

    /**
    * return LLVM Type
    */
    public LLVMTypeRef llvmTypeOf()
    {
        return  LLVMTypeOf(mValue);
    }

    /**
    * Get LLVM Value
    */
    @property
    public LLVMValueRef llvmValue()
    {
        return mValue;
    }
}

//FunctionValue
class FunctionValue : Value
{
    /**
    * Create new FunctionValue for a Function Type
    */
    public this(Module m, FunctionType func, string name)
    {
        mValue = LLVMAddFunction(m.llvmModule, cast(char*)name.ptr, func.llvmType);
    }

    /**
    * Get First Basic Block
    */
    BasicBlock getFirstBlock()
    {
        return new BasicBlock(LLVMGetFirstBasicBlock(mValue));
    }
}

/**
* Basic Block
*/
class BasicBlock : NodeData
{
    /// LLVM Basic Block
    private LLVMBasicBlockRef mBasicBlock;

    /**
    * Create new Basic Block
    */
    public this(Value val, string name)
    {
        //value must be a function
        mBasicBlock = LLVMAppendBasicBlock(val.llvmValue(), (cast(char[])name).ptr);
    }

    /**
    * Interfacing Existing BasicBLock
    */
    public this(LLVMBasicBlockRef block)
    {
        mBasicBlock = block;
    }

    /**
    * Get llvm basis block
    */
    public LLVMBasicBlockRef llvmBasicBlock()
    {
        return mBasicBlock;
    }

    /**
    * Next Basic Block
    */
    public BasicBlock nextBlock()
    {
        return new BasicBlock(LLVMGetNextBasicBlock(mBasicBlock));
    }

    /**
    * Previous Basic Block
    */
    public BasicBlock prevBlock()
    {
        return new BasicBlock(LLVMGetPreviousBasicBlock(mBasicBlock));
    }
}

/**
* LLVM Builder
*/
class Builder
{
    //LLVM Builder
    private LLVMBuilderRef mBuilder;

    /**
    * Create new Builder
    */
    public this(Context context)
    {
        mBuilder = LLVMCreateBuilderInContext(context.llvmContext());
    }

    /**
    * Destructor
    */
    public ~this()
    {
        LLVMDisposeBuilder(mBuilder);
    }

    /**
    * Set Position to the end of a basis block
    */
    public void PositionAtEnd(BasicBlock block)
    {
        LLVMPositionBuilderAtEnd(mBuilder, block.llvmBasicBlock());
    }

}
