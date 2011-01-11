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
module disc.gen.llvm.Node; 

import disc.ast.Node;
import disc.ast.Visitor;

//LLVM OOP Wrapper
import llvm = disc.gen.llvm.LLVM;

/**
* LLVM Compiler Node Types
*/
enum CompilerNodeType
{
    Context,
    Module,
    Type,
    Value,
    BasicBlock
}

/**
* LLVM Compiler Nodes
*/
class CompilerNode : Node
{
    //LLVM Context
    //LLVM Module
    //LLVM Type
    //LLVM Value
    //LLVM BasicBlock

    CompilerNodeType CNType;

    /**
    * Create new CompilerNode
    */
    public this()
    {
        Type = NodeType.Special;
    }


    /**
    * For Node Compatibility
    */
    public override void accept(Visitor v)
    {
        assert(true);
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

}

