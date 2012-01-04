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
final class LiteralExpression : Expression
{
    /// Value
    public string Value;

    /// Create new LiteralExpression
    public this(string value, DataType returnType)
    {
        Value = value;
        ReturnType = returnType;
    }

    ///Mixin for Kind Declaration
    mixin(IsKind("LiteralExpression"));
}

//

/**
* IdentifierExpression
* e.g. foo.bar.x.y
*/
final class IdentifierExpression : Expression
{
    /// The Composite Identifier
    public CompositeIdentifier Identifier;

    /// Alias This the Composite Identifier
    alias Identifier this;

    /**
    * To String
    */
    override string toString() 
    {   
        return Identifier.toString();
    }

    ///Mixin for Kind Declaration
    mixin(IsKind("IdentifierExpression"));
}

/**
* A Function Call
*/
final class CallExpression : Expression
{
    ///Expression to retrieve a function type
    Expression Function;

    /// Arguments for function call
    Expression[] Arguments;

    //return type is mFunction.solve().mReturnType

    ///Mixin for Kind Declaration
    mixin(IsKind("CallExpression"));
}


/**
* Binary Expression
*/
final class BinaryExpression : Expression
{
    /// OP + - * / % ** ^ && ||
    public enum Operator : ubyte { Add, Sub, Mul, Div, Mod, Power, And, Or, Xor,
                                   Assign }

    /// Operator
    Operator Op; 

    /// Left Expression
    Expression Left;

    /// Right Expression
    Expression Right;

    /// Mixin for Kind Declaration
    mixin(IsKind("BinaryExpression"));
}

/**
* Unary Expression
*/
final class UnaryExpression : Expression
{
    /// Valid Operators
    public enum Operator : ubyte { Not }

    /// The Operator
    Operator Op;

    /// The Expression
    Expression Expr;

    /// Mixin for Kind Declaration
    mixin(IsKind("UnaryExpression"));
}

/**
* Lambda Expression
*/
final class LambdaExpression : Expression
{
    //arguments
    //body

    //functionDeclaration -> anonymous function
}

/**
* If Expression
*/
final class IfExpression : Expression
{
    /// Condition
    Expression Condition;
    
    /// Else Ifs Expressions
    IfExpression[] ElseIfsExpr;

    /// Else Expression
    Expression ElseExpr;

    ///Mixin for Kind Declaration
    mixin(IsKind("IfExpression"));
}

/**
* Switch Expression
*/
final class SwitchExpression : Expression
{
    ///Condition?
    Expression Condition;

        //cases
    //default case

    ///Mixin for Kind Declaration
    mixin(IsKind("SwitchExpression"));
}
