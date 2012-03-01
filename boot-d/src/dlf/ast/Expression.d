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
module dlf.ast.Expression;

import dlf.ast.Node;
import dlf.ast.Special;
import dlf.ast.Visitor;
import dlf.ast.Type;

/**
* Base Class for Expression
*/
abstract class Expression : Node
{
    /// ReturnType of Expression
    DataType ReturnType;
}


/**
* Literal Expression Node
*/
final class LiteralExpr : Expression
{
    /// Value
    public string Value;

    /// Create new LiteralExpr
    public this(string value, DataType returnType)
    {
        Value = value;
        ReturnType = returnType;
    }

    ///Mixin for Kind Declaration
    mixin(IsKind("LiteralExpr"));
}


/**
* DotExpr
* e.g. foo.bar.x.y
*/
final class DotExpr : Expression
{
    /// The Composite Identifier
    public CompositeIdentifier Identifier;

    /// Alias This the Composite Identifier
    alias Identifier this;

    /// Target Declaration
    public Declaration Decl;

    /**
    * To String
    */
    override string toString() 
    {   
        return Identifier.toString();
    }

    ///Mixin for Kind Declaration
    mixin(IsKind("DotExpr"));
}

/**
* A Function Call
*/
final class CallExpr : Expression
{
    ///Expression to retrieve a function type
    Expression Func;

    /// Arguments for function call
    Expression[] Arguments;

    //return type is mFunction.solve().mReturnType

    ///Mixin for Kind Declaration
    mixin(IsKind("CallExpr"));
}


/**
* Binary Operator
*  + - * / % ** & | ^ && || < > ~ 
*  << >> 
*  = += -= *= /= %= **= &= |= ^= <= >= !=
*/
public enum BinaryOperator : ubyte 
{ 
    Add, Sub, Mul, Div, Mod, Power, And, Or, Xor, LAnd, LOr, Concat,
    //Shift
    Assign 
}

/**
* Binary Expression
*/
final class BinaryExpr : Expression
{
    /// Operator
    BinaryOperator Op; 

    /// Left Expression
    Expression Left;

    /// Right Expression
    Expression Right;

    /// Mixin for Kind Declaration
    mixin(IsKind("BinaryExpr"));
}

/**
* Unary Operator
* !Expr -Expr Expr++ ++Expr Expr-- --Expr
*/
public enum UnaryOperator : ubyte 
{ 
    Not, Neg, PostIncr, PreIncr, PostDecr, PreDecr 
}

/**
* Unary Expression
*/
final class UnaryExpr : Expression
{
    /// The Operator
    UnaryOperator Op;

    /// The Expression
    Expression Expr;

    /// Mixin for Kind Declaration
    mixin(IsKind("UnaryExpr"));
}

/**
* Lambda Expression
*/
final class LambdaExpression : Expression
{
    //arguments
    //body

    //FunctionDecl -> anonymous function
}

/**
* If Expression
*/
final class IfExpr : Expression
{
    /// Condition
    Expression Condition;
    
    /// Else Ifs Expressions
    IfExpr[] ElseIfsExpr;

    /// Else Expression
    Expression ElseExpr;

    ///Mixin for Kind Declaration
    mixin(IsKind("IfExpr"));
}

/**
* Switch Expression
*/
final class SwitchExpr : Expression
{
    ///Condition?
    Expression Condition;

    //cases
    //default case
        //CaseExpression?

    ///Mixin for Kind Declaration
    mixin(IsKind("SwitchExpr"));
}
