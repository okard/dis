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
module dlf.ast.Node;

import dlf.ast.Visitor;

/**
* Base Class for AST Nodes
*/
abstract class Node
{
    /// parent node
    public Node Parent;

    /// Node Type
    public NodeType Type;

    /// For Node Extensions in Semantic and Compiler Passes
    public Node Extend;

    /// Mixin for node type
    protected const string set_nodetype = "this.Type = mixin(\"NodeType.\" ~ typeof(this).stringof);";
    
    /// Create new Node
    public this()
    {
    }

    /**
    * Visitor pattern
    */
    public abstract void accept(Visitor v);
    
}

/**
* Node Types
*/
enum NodeType
{
    Unknown,
    Special,
    DataType,
    //Declarations
    PackageDeclaration,
    TraitDeclaration,
    ClassDeclaration,
    FunctionDeclaration,
    VariableDeclaration,
    //Statements
    BlockStatement,
    ExpressionStatement,
    ReturnStatement,
    //Expressions
    DotIdentifier,
    FunctionCall,
    LiteralExpression,
    AssignExpression,
    BinaryExpression
}