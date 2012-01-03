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
module dlf.ast.Visitor;

public import dlf.ast.Node;
public import dlf.ast.Declaration;
public import dlf.ast.Statement;
public import dlf.ast.Expression;
public import dlf.ast.Annotation;
public import dlf.ast.SymbolTable;

/**
* AST Visitor
*/
public interface Visitor
{
    public 
    {
    //Declarations
    void visit(PackageDeclaration);
    void visit(ImportDeclaration);
    void visit(FunctionDeclaration);
    void visit(VariableDeclaration);
    //Value
    //Constant
    void visit(ClassDeclaration);
    void visit(TraitDeclaration);
    //Struct
    //Alias
    //Enum
    //Variant

    //Statements
    void visit(BlockStatement);
    void visit(ExpressionStatement);
    void visit(ReturnStatement);
    //For
    //ForEach
    //While

    //Expressions
    void visit(LiteralExpression);
    void visit(CallExpression);
    void visit(IdentifierExpression);
    void visit(AssignExpression);
    void visit(BinaryExpression);

    //Annotations

    //Types
    
    }

    //voids with ref for modification or not?
    //handle in dispatch so pd = dispatch(pd) works?
    //but remove the requirement of return variables?
    //in-out visitor void visit(LiteralExpression in, Node out);
    //disable special ranges (declarations, statements, expression, types, and so on)
}


/**
* Dispatch Function General
*/
Node dispatch(Node n, Visitor v, bool mod = false)
{
    assert(n !is null, "Node shouldn't be null");
    assert(v !is null, "Visitor shouldn't be null");
    assert(n.Self is null, "A not null self, a dispatch goes wrong");

    /*final*/ 
    switch(n.Kind)
    {   
        //Declarations
        case NodeKind.PackageDeclaration: v.visit(cast(PackageDeclaration)n); break;
        case NodeKind.ImportDeclaration: v.visit(cast(ImportDeclaration)n); break;
        case NodeKind.VariableDeclaration: v.visit(cast(VariableDeclaration)n); break;
        //Value
        //Constant
        case NodeKind.FunctionDeclaration: v.visit(cast(FunctionDeclaration)n); break;
        case NodeKind.ClassDeclaration: v.visit(cast(ClassDeclaration)n); break;
        case NodeKind.TraitDeclaration: v.visit(cast(TraitDeclaration)n); break;
        //Struct
        //Alias
        //Enum
        //Variant

        //Statements
        case NodeKind.BlockStatement: v.visit(cast(BlockStatement)n); break;
        case NodeKind.ExpressionStatement: v.visit(cast(ExpressionStatement)n); break;
        case NodeKind.ReturnStatement: v.visit(cast(ReturnStatement)n); break;
        //For
        //ForEach
        //While
        
        //Expressions
        case NodeKind.LiteralExpression: v.visit(cast(LiteralExpression)n); break;
        case NodeKind.CallExpression: v.visit(cast(CallExpression)n); break;
        case NodeKind.IdentifierExpression: v.visit(cast(IdentifierExpression)n); break;
        case NodeKind.BinaryExpression: v.visit(cast(BinaryExpression)n); break;
        //UnaryExpression
        //If
        //Switch
        
        case NodeKind.AssignExpression: v.visit(cast(AssignExpression)n); break;

        //Types
        //Builtin
        //FunctionType
        //ClassType
        //Unsovled
        //Pointer/Array/

        //Special
        case NodeKind.Semantic: assert(false, "Can't dispatch special semantic node");
        case NodeKind.Backend: assert(false, "Can't dispatch special backend node"); 
    
        default: assert(false, "Missing dispatch case");
    }

    assert(!(!mod && (n.Self !is null)), "Only with mod enabled a self should be set");
         
    return mod && (n.Self !is null) ? n.Self : n;
}
    


/**
* Dispatch template utils
*/
mixin template DispatchUtils(bool modify)
{
    /**
    * Auto Dispatch
    */
    private T autoDispatch(T)(T e)
    {
        return cast(T)dispatch(e, this, modify);
    }

    /**
    * Map Dispatch to Arrays
    */
    private void mapDispatch(T)(T[] elements)
    {
        for(int i=0; i < elements.length; i++)
        {
            elements[i] = autoDispatch(elements[i]);
        }
    }

    /**
    * SymbolTable Dispatch
    */
    private void symDispatch(SymbolTable symTable)
    {
         //go through declarations
        foreach(Declaration d; symTable)
        {
            assert(symTable[d.Name] == d);
            symTable[d.Name] = autoDispatch(d);
        }
    }
}
