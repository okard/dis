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
public import dlf.ast.Type;
public import dlf.ast.SymbolTable;

debug import std.stdio;

/**
* Parameter default on stack
*/
public struct VisitorParameter
{
	public bool Changeable = true;
}


/**
* AST Visitor
*/
public interface Visitor
{

public:
    //Declarations
    Declaration visit(PackageDecl);
    Declaration visit(ImportDecl);
    Declaration visit(FunctionDecl);
    Declaration visit(VarDecl);
    //Value
    //Constant
    Declaration visit(ClassDecl);
    Declaration visit(TraitDecl);
    Declaration visit(StructDecl);
    Declaration visit(AliasDecl);
    //Enum
    //Variant

    //Statements
    Statement visit(BlockStmt);
    Statement visit(ExpressionStmt);
    Statement visit(ReturnStmt);
    //For
    //ForEach
    //While
    //Break
    //Continue

    //Expressions
    Expression visit(LiteralExpr);
    Expression visit(CallExpr);
    Expression visit(IdExpr);
    Expression visit(DotExpr);
    Expression visit(BinaryExpr);
    Expression visit(UnaryExpr);
    //Unary
    //IfExpr
    //SwitchExpr
    //Lambda
    

    //Annotations
    //UnitTest

    //Types
    DataType visit(DataType);
    DataType visit(DotType);

    //RefType
    //

	//dummy interface
	Node visit(Node);

    //voids with ref for modification or not?
    //handle in dispatch so pd = dispatch(pd) works?
    //but remove the requirement of return variables?
    //in-out visitor void visit(LiteralExpr in, Node out);
    //disable special ranges (declarations, statements, expression, types, and so on)
}



/**
* Dispatch utils template 
*/
mixin template DispatchUtils(bool modify)
{
    /**
    * Auto Dispatch
    */
    private final T autoDispatch(T)(T e)
    {
        if(e is null) return e;
		VisitorParameter vp;
		vp.Changeable = modify;
		//TODO fast cast here?
		return e.accept(this, vp).to!T;
    }

    /**
    * Map Dispatch to Arrays
    */
    private final void mapDispatch(T)(T[] elements)
    {
        for(int i=0; i < elements.length; i++)
        {
            elements[i] = autoDispatch(elements[i]);
        }
    }

    /**
    * SymbolTable Dispatch
    */
    private final void symDispatch(SymbolTable symTable)
    {
         //go through declarations
        foreach(Declaration d; symTable)
        {
            assert(symTable[d.Name] == d);
            symTable.replace(autoDispatch(d));
        }
    }
}
