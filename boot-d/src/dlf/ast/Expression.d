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
* TODO: Expressions are Statements?
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
	mixin KindMixin!(NodeKind.LiteralExpr);
    mixin VisitorMixin;
    
    /// Value
    public string Value;

    /// Create new LiteralExpr
    public this(string value, DataType returnType)
    {
        Value = value;
        ReturnType = returnType;
    }
}

//TODO IntLiteral
//TODO FloatLiteral

/**
* A Function Call
*/
final class CallExpr : Expression
{
	mixin KindMixin!(NodeKind.CallExpr);
    mixin VisitorMixin;
    
    ///Expression to retrieve a function type
    Expression Func;

    /// Arguments for function call
    Expression[] Arguments;

    //return type is mFunction.solve().mReturnType
}


/**
* Binary Operator
*  + - * / % ** & | ^ && || < > ~ 
*  << >> >>> <<<
*  = += -= *= /= %= **= &= |= ^= <= >= !=
*/
public enum BinaryOperator : ubyte 
{ 
    // Binary Ops
    Add, Sub, Mul, Div, Mod, Pow, And, Or, Xor, LAnd, LOr, Concat,
    // Shifts
    LLShift, LRShift, ALShift, ARShift,
    // Assign Ops
    Assign, AddAssign, SubAssign, MulAssign, DivAssign, ModAssign, PowerAssign, 
            AndAssign, OrAssign, XorAssign, ConcatAssign,
    // Special Dot Op
    Dot
}

/**
* Binary Expression
*/
class BinaryExpr : Expression
{
	mixin KindMixin!(NodeKind.BinaryExpr);
    mixin VisitorMixin;
    
    /// Operator
    BinaryOperator Op; 

    /// Left Expression
    Expression Left;

    /// Right Expression
    Expression Right;

}

/**
* Dot Expression
* eg. this.foobar.abc
*     super.callit
*     abc.foo
*/
final class DotExpr : BinaryExpr
{
	mixin KindMixin!(NodeKind.DotExpr);
    mixin VisitorMixin;
    
    public this()
    {
        Op = BinaryOperator.Dot;
    }
}

/**
* IdExpr
* e.g. foo.bar.x.y
* TODO is also a literal expr?
*/
final class IdExpr : Expression
{
	mixin KindMixin!(NodeKind.IdExpr);
    mixin VisitorMixin;
    
    /// Identifier
    public string Id;

    /// Target Declaration
    public Declaration Decl;

    /**
    * To String
    */
    override string toString() 
    {   
        return Id;
    }
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
	mixin KindMixin!(NodeKind.UnaryExpr);
    mixin VisitorMixin;
    
    /// The Operator
    UnaryOperator Op;

    /// The Expression
    Expression Expr;
}

/**
* Lambda Expression
*/
final class LambdaExpression : Expression
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    //has a function type
    
    //Parameter[] Arguments
    
    //Statement Body

    //FunctionDecl -> anonymous function
}

/**
* If Expression
*/
final class IfExpr : Expression
{
	mixin KindMixin!(NodeKind.IfExpr);
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    /// Condition
    Expression Condition;
    
    /// Else Ifs Expressions
    IfExpr[] ElseIfsExpr;

    /// Else Expression
    Expression ElseExpr;
}

/**
* Switch Expression
*/
final class SwitchExpr : Expression
{
	mixin KindMixin!(NodeKind.SwitchExpr);
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    ///Condition?
    Expression Condition;

    //cases
    //default case
        //CaseExpression?

}
