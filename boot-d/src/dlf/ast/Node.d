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

import dlf.basic.Location;

/**
* All kinds of ast nodes
*/
public enum NodeKind : uint
{
    Unkown,

    //Declaration
    Declaration,
    PackageDeclaration,
    ImportDeclaration,
    FunctionDeclaration,
    VariableDeclaration,
    ClassDeclaration,
    TraitDeclaration,
    StructDeclaration,
    EnumDeclaration,
    AliasDeclaration,
    VariantDeclaration,
    DelegateDeclaration,

    //Statement
    Statement,
    BlockStatement,
    ExpressionStatement,
    ReturnStatement,
    ForStatement,
    ForEachStatement,
    WhileStatement,

    //Expression
    Expression,
    LiteralExpression,
    DotIdentifier,
    FunctionCall,
    BinaryExpression,
    AssignExpression,
    
    //DataType
    DataType,
    //Annotation
    //CodeGen?
}

/**
* Base Class for AST Nodes
*/
abstract class Node
{
    /// Parent node
    public Node Parent;

    /// Kind (immutable)? function?
    //public NodeKind Kind;
    @property public abstract NodeKind Kind();

    /// Location
    public Location Loc;

    /// For Node Extensions in Semantic and Compiler Passes
    public Node Extend;
}

//TODO Mixin for Node.Kind

//0xFFFF_FFFF
//0x0000_0001
//0x1

bool isDeclaration(Node n) { return n.Kind >= NodeKind.Declaration && n.Kind < NodeKind.Statement; }
bool isStatement(Node n) { return n.Kind >= NodeKind.Statement && n.Kind < NodeKind.Expression; }
bool isExpression(Node n) { return n.Kind >= NodeKind.Expression && n.Kind < NodeKind.DataType; }
//isStatement
//isExpression
//isDataType
//isAnnotation
