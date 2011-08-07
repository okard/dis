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
module dlf.gen.llvm.Node; 

import dlf.ast.Node;
import dlf.ast.Visitor;

//LLVM OOP Wrapper
import llvm = dlf.gen.llvm.LLVM;

/**
* LLVM Compiler Node Types
*/
enum CompilerNodeType
{
    Context,
    Module,
    Type,
    Value,
    BasicBlock,

    FunctionBlock
}

/**
* LLVM Compiler Nodes
*/
class CompilerNode : Node
{
    /// CompilerNode Type
    CompilerNodeType CNType;

    /**
    * Create new CompilerNode
    */
    public this()
    {
       NodeType = Node.Type.Special;
    }
}

/**
* ModuleNode
*/
class ModuleNode : CompilerNode
{
    /// LLVM Type
    llvm.Module LLVMModule;

    /// Create new Module Compiler Node
    public this(llvm.Module mod)
    {
        CNType = CompilerNodeType.Module;
        LLVMModule = mod;
    }
}

/**
* Type Node
*/ 
class TypeNode : CompilerNode
{
    /// LLVM Type
    llvm.Type LLVMType;

    //OpaqueType?

    /// Create new Type Compiler Node
    public this(llvm.Type type)
    {
        CNType = CompilerNodeType.Type;
        LLVMType = type;
    }

}

/**
* Value Node
*/
class ValueNode : CompilerNode
{
    /// LLVM Value
    llvm.Value LLVMValue;

    /// Creates new Value Compiler Node
    public this(llvm.Value value)
    {
        CNType = CompilerNodeType.Value;
        LLVMValue = value;
    }
}

/**
* Basic Block Node
*/
class BasicBlockNode : CompilerNode
{
    /// LLVM Basic Block
    llvm.BasicBlock LLVMBBlock;

    /// Creates new Value Compiler Node
    public this(llvm.BasicBlock block)
    {
        CNType = CompilerNodeType.BasicBlock;
        LLVMBBlock = block;
    }
}

/// Utility Class
class FunctionBlockNode : CompilerNode
{
    /// Entry Basic Block
    llvm.BasicBlock entry;

    /// Return Basic Block
    llvm.BasicBlock ret;
    
    /// A ReturnValue Variable in Function
    llvm.Value retVal;

    //FuncDecl
    //FuncValue

    /// Creates new Function Block Node
    public this()
    {
        CNType = CompilerNodeType.FunctionBlock;
    }
}
