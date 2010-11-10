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
module disc.ast.Node;

import disc.basic.Any;
import disc.ast.Visitor;

/**
* Base Class for AST Nodes
*/
abstract class Node
{
    /// parent node
    public Node parent;

    /// Data Save
    public Any any;

    /// Node Type
    public NodeType mNodeType;

    ///mixin for type
    const string set_nodetype = "this.mNodeType = mixin(\"NodeType.\" ~ typeof(this).stringof);";
    
    /**
    * Visitor pattern
    */
    public void accept(Visitor v);
    
    /**
    * Node Type
    */
    @property
    public NodeType NType() { return mNodeType; }
} 

/**
* Node Types
*/
enum NodeType
{
    Unknown,
    //Declarations
    PackageDeclaration,
    FunctionDeclaration,
    VariableDeclaration,
    //Statements
    BlockStatement,
    ExpressionStatement,
    //Expressions
    DotIdentifier,
    FunctionCall
}