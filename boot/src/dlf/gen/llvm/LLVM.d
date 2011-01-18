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
module dlf.gen.llvm.LLVM;
// This Module wraps LLVM C API back to Classes

public import llvm.c.Core;
import llvm.c.BitWriter;
import llvm.c.transforms.IPO;
import llvm.c.transforms.Scalar;

/**
* LLVM Context
*/
class Context
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
class Module 
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

    /**
    * New Global Variable
    */
    public Value AddGlobal(Type t, string name)
    {
        return new Value(LLVMAddGlobal(mModule, t.llvmType, (cast(char[])name).ptr));
    }
}

/**
* LLVM Type
*/
public class Type 
{
    /// LLVM Type
    private LLVMTypeRef mType;

    /**
    * Create type from type ref
    */
    public this(LLVMTypeRef type)
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

    /**
    * Helper to get TypeArray
    */
    public static LLVMTypeRef[] convertArray(Type[] types)
    {
        auto t = new LLVMTypeRef[types.length];
        for(int i = 0; i < types.length; i++)
            t[i] = types[i].llvmType;
        return t;
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


/**
* Pointer Type
*/
class PointerType : Type
{
    /// Create new PointerType
    public this(Type type2point)
    {
        super(LLVMPointerType(type2point.llvmType,0));
    }
}


/**
* Struct Type
*/
class StructType : Type
{
    
    /// Create a new Struct Type
    public this(Type[] elements, bool packed)
    {
        auto p = convertArray(elements);
        super(LLVMStructType(p.ptr, elements.length, packed));
    }
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
        auto p = convertArray(params);
        super(LLVMFunctionType(retType.llvmType, p.ptr, params.length, varargs));
    }
}

/**
* LLVM Value
*/
class Value 
{
    /// LLVM Value
    private LLVMValueRef mValue;

    /**
    * Creates Basic Value
    */
    private this(LLVMValueRef v)
    {
       mValue = v;
    }

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

/** 
* FunctionValue
*/
class FunctionValue : Value
{
    private string mFnName;

    /**
    * Create new FunctionValue for a Function Type
    */
    public this(Module m, FunctionType func, string name)
    {
        mFnName = name;
        super(LLVMAddFunction(m.llvmModule, cast(char*)name.ptr, func.llvmType));
    }

    /**
    * Get Function Name
    */
    @property
    public string Name()
    {
        return mFnName;
    }

    /**
    * Set Calling Convention
    */
    public void setCallConv(LLVMCallConv cc)
    {
        LLVMSetFunctionCallConv(mValue, cc);
    }

    /**
    * Add Function Attribute
    */
    public void addFunctionAttr(LLVMAttribute PA)
    {
        LLVMAddFunctionAttr(mValue, PA);
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
class BasicBlock
{
    /// LLVM Basic Block
    private LLVMBasicBlockRef mBasicBlock;

    /**
    * Create new Basic Block
    */
    public this(FunctionValue val, string name)
    {
        //value must be a function

        mBasicBlock = LLVMAppendBasicBlock(val.llvmValue(), (cast(char[])name).ptr);
    }

    /**
    * Create new Basic Block
    */
    public this(BasicBlock block, string name)
    {
        mBasicBlock = LLVMInsertBasicBlock(block.llvmBasicBlock, (cast(char[])name).ptr);
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
    @property
    public LLVMBasicBlockRef llvmBasicBlock()
    {
        return mBasicBlock;
    }
    
    /**
    * Get Basic Block as Value
    */
    public LLVMValueRef llvmBBValue()
    {
        return LLVMBasicBlockAsValue(mBasicBlock);
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

    /**
    * Label Jump
    */
    public void Br(BasicBlock bb)
    {
        LLVMBuildBr(mBuilder, bb.llvmBasicBlock);
    }

    /** 
    * Add Return Void Instruction
    */
    public void RetVoid()
    {
       auto value = LLVMBuildRetVoid(mBuilder);
    }

    /**
    * Return a value
    */
    public void RetValue(Value value)
    {
        auto val =  LLVMBuildRet(mBuilder, value.llvmValue());
    }

    /**
    * Alloc memory for type
    */
    public Value Alloca(Type t, string name)
    {
        return new Value(LLVMBuildAlloca(mBuilder, t.llvmType, (cast(char[])name).ptr));
    }

    /**
    * Get Element from Struct
    */
    public Value StructGEP(Value v, uint Index, string name)
    {
        return new Value(LLVMBuildStructGEP(mBuilder, v.llvmValue, Index, (cast(char[])name).ptr));
    }

    /**LLVMValueRef LLVMBuildBr(LLVMBuilderRef, LLVMBasicBlockRef Dest);
    * Store a Value at ptr-value
    */
    public void Store(Value ptr, Value val)
    {
        //check if Value is a ptr value?
        LLVMBuildStore(mBuilder, val.llvmValue, ptr.llvmValue);
    }

    /**
    * Create a Function Call
    */
    public Value Call(FunctionValue fn, Value[] args)
    {
        //Create array with primary llvm values
        auto argarr = new  LLVMValueRef[args.length];
        for(int i = 0; i < args.length; i++)
            argarr[i] = args[i].llvmValue;

        return new Value(LLVMBuildCall(mBuilder, fn.llvmValue(), argarr.ptr, argarr.length, (cast(char[])fn.Name).ptr));
    }

    /**
    * Get LLVMBuilder
    */
    @property
    public LLVMBuilderRef llvmBuilder()
    {
        return mBuilder;
    }
}

/**
* PassManager
*/
class PassManager
{
    ///llvm PassManager
    private LLVMPassManagerRef mPassManager;

    ///llvm optimization level
    private PassType mPassType;

    enum PassType { None =0, Debug = 1, Release = 2, Optimized = 3}

    /**
    * Creates new PassManager
    */
    public this()
    {
        mPassManager = LLVMCreatePassManager();
    }

    /**
    * Destructor
    */
    public ~this()
    {
        LLVMDisposePassManager(mPassManager);
    }

    /**
    * Run Pass Manager
    */
    public bool Run(Module m)
    {
        //Verify Module before?

        return LLVMRunPassManager(mPassManager, m.llvmModule()) == 0 ? false : true;
    }


    /**
    * Simplify Pass Configuration
    */
    public void Configure(PassType p)
    {
        //TODO

        //Add right passes for choosen configuration
        if(p <= PassType.None)
        {
        }

        if(p <= PassType.Debug)
        {
        }

        if(p <= PassType.Release)
        {
            AddGlobalOptimizerPass();
            AddStripSymbolsPass();
            AddDeadArgEliminationPass();
            AddStripDeadPrototypesPass();
        }

        if(p <= PassType.Optimized)
        {
            AddFunctionInliningPass();
            AddCFGSimplificationPass();
        }
    }

    /**
    * Add Pass
    */
    public void AddFunctionInliningPass()
    {
        /** See llvm::createFunctionInliningPass function. */
        LLVMAddFunctionInliningPass(mPassManager);
    }

    /**
    * Add Pass
    */
    public void AddGlobalOptimizerPass()
    {
        /** See llvm::createGlobalOptimizerPass function. */
        LLVMAddGlobalOptimizerPass(mPassManager);
    }

    /**
    * Add Pass
    */
    public void AddStripSymbolsPass()
    {
        /** See llvm::createStripSymbolsPass function. */
        LLVMAddStripSymbolsPass(mPassManager);
    }

    /**
    * Add Pass
    */
    public void AddDeadTypeEliminationPass()
    {
        /** See llvm::createDeadTypeEliminationPass function. */
        LLVMAddDeadTypeEliminationPass(mPassManager);
    }

    /**
    * Add Pass
    */
    public void AddDeadArgEliminationPass()
    {
        /** See llvm::createDeadArgEliminationPass function. */
        LLVMAddDeadArgEliminationPass(mPassManager);
    }

    /**
    * Add Pass
    */
    public void AddCFGSimplificationPass()
    {
        /** See llvm::createCFGSimplificationPass function. */
        LLVMAddCFGSimplificationPass(mPassManager);
    }

    /**
    * Add Pass
    */
    public void AddStripDeadPrototypesPass()
    {
        /** See llvm::createStripDeadPrototypesPass function. */
        LLVMAddStripDeadPrototypesPass(mPassManager);
    }
}
