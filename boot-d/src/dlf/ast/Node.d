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

//ids to split kind groups
//0xFFFF_FFFF
//0x0000_0001
//0x1

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
    DotIdentifier, //DotExpression, IdentifierExpression
    CallExpression,
    BinaryExpression,
    AssignExpression,
    IfExpression,
    SwitchExpression,
    
    //DataType
    DataType,
    OpaqueType,
    UnsolvedType,
    FunctionType,
    ClassType,
    TraitType,

    //Annotation

    //Special
    Comment,
    Semantic,
    Backend
}

/**
* Base Class for AST Nodes
*/
abstract class Node
{
    /// Parent node
    public Node Parent;

    /// Location
    public Location Loc;

    /// Storage for Semantic Node
    public Node Semantic;

    /// Storage for CodeGen Node
    public Node CodeGen;

    /// Kind (immutable)? function?
    @property public abstract NodeKind Kind();

    /// Self Pointer for (crazy) dispatch replace
    public Node Self;
}

/**
* Mixin for Node Kind Declaration
*/
string IsKind(string name)
{
    return "@property public override NodeKind Kind(){ return NodeKind."~name~"; }";
}


/// Is Declaration
bool isDeclaration(Node n) { return n.Kind >= NodeKind.Declaration && n.Kind < NodeKind.Statement; }

/// Is Statement
bool isStatement(Node n) { return n.Kind >= NodeKind.Statement && n.Kind < NodeKind.Expression; }

/// Is Expression
bool isExpression(Node n) { return n.Kind >= NodeKind.Expression && n.Kind < NodeKind.DataType; }

//isDataType
//isAnnotation

bool isBackendNode(Node n) { return n is null ? false : n.Kind == NodeKind.Backend; }

bool isSemanticNode(Node n) { return n is null ? false : n.Kind == NodeKind.Semantic; }
