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
public enum NodeKind : ushort
{
    Unkown,

    //Declarations
    Declaration,
    PackageDecl,
    ImportDecl,
    FunctionDecl,
    VarDecl,
    ValDecl,
    ConstDecl,
    ClassDecl,
    StructDecl,
    TraitDecl,
    EnumDecl,
    AliasDecl,
    VariantDecl,

    //Statements
    Statement,
    BlockStmt,
    ExpressionStmt,
    ReturnStmt,
    ForStmt,
    ForEachStmt,
    WhileStmt,

    //Expressions
    Expression,
    LiteralExpr,
    CallExpr,
    BinaryExpr,
    DotExpr,
    IdExpr,
    UnaryExpr,
    AssignExpr,
    IfExpr,
    SwitchExpr,
    
    //DataTypes
    //Primary:
    VoidType,
    BoolType,
    Byte8Type,
    UByte8Type,
    Short16Type,
    UShort16Type,
    Int32Type,
    UInt32Type,
    Long64Type,
    ULong64Type,
    Float32Type,
    Double64Type,
    //Other:
    RefType,
    PtrType,
    ArrayType,
    FunctionType,
    DeclarationType,
    // PlaceHolder:
    OpaqueType,
    DotType,

    //Annotation,
    Annotation,
    TestAnnotation,

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
    //TODO Make this struct? for different node types different?
    public Node Semantic;

    /// Storage for CodeGen Node
    //TODO Make this struct? for different node types different?
    public Node CodeGen;

    /// Kind (immutable)? function?
    @property public abstract const NodeKind Kind() const;

    @property
    public final T to(T:Node)()
    {
        //TODO can be optimized into a static cast
        //assert(T.Kind == this.Kind, "Missmatch "~this.toString());
        // FuncDecl to Declaration needs special handling
        T n = cast(T)this;
        assert(n);
        return n;
    }
}

/**
* Mixin for Node Kind Declaration
*/
string IsKind(string name)
{
    return "@property public override NodeKind Kind(){ return NodeKind."~name~"; } " ~
           "@property public final static NodeKind Kind() { return NodeKind."~name~"; } ";
}


/// Is Declaration
bool isDeclaration(Node n) { return n.Kind >= NodeKind.Declaration && n.Kind < NodeKind.Statement; }

/// Is Statement
bool isStatement(Node n) { return n.Kind >= NodeKind.Statement && n.Kind < NodeKind.Expression; }

/// Is Expression
bool isExpression(Node n) { return n.Kind >= NodeKind.Expression && n.Kind < NodeKind.VoidType; }

/// Is DataType
bool isDataType(Node n) { return n.Kind >= NodeKind.VoidType && n.Kind < NodeKind.Annotation; }

/// Is Annotation
bool isAnnotation(Node n) { return n.Kind >= NodeKind.Annotation && n.Kind < NodeKind.Comment; }

/// Is Backend Node
bool isBackendNode(Node n) { return n is null ? false : n.Kind == NodeKind.Backend; }

/// Is Semantic Node
bool isSemanticNode(Node n) { return n is null ? false : n.Kind == NodeKind.Semantic; }
