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
import dlf.ast.Visitor;
import dlf.ast.Type;

/**
* Base Class for Expression
*/
abstract class Expression : Node
{
    DataType mReturnType;
    mixin VisitorMixin;

    alias mReturnType ReturnType;
}


/**
* Literal Expression Node
*/
final class LiteralExpression : Expression
{
    // Visitor Mixin
    mixin VisitorMixin;

    // Type

    /// Value
    public string Value;

    /// Create new LiteralExpression
    public this(string value)
    {
        mixin(set_nodetype);
        Value = value;
    }
}

//

/**
* Dotted Identifier
* e.g. foo.bar.x.y
*/
final class DotIdentifier : Expression
{
    //Visitor Mixin
    mixin VisitorMixin;

    ///parts of identifiers splitted with .
    char[][] mIdentifier;

    //resolve type
    //Type type;

    /**
    * Create dotted identifier
    */
    public this(char[] identifier)
    {
        mixin(set_nodetype);
        mIdentifier ~= identifier;
    }

    /**
    * To String
    */
    override string toString() 
    {
        string s;
        foreach(ps; mIdentifier)
            s ~= ps;
        return s;
    }

    /**
    * TODO Parse dotted expression from string
    */
    public static parse(string value)
    {
    }

    
}

/**
* A Function Call
*/
final class FunctionCall : Expression
{
    //Visitor Mixin
    mixin VisitorMixin;

    ///Expression to retrieve a function type
    Expression mFunction;

    /// Arguments for function call
    Expression[] Arguments;

    //return type is mFunction.solve().mReturnType

    this()
    {
        mixin(set_nodetype);
    }
}


/**
* Binary Expression
*/
final class BinaryExpression : Expression
{
    /// OP + - * / % ** ^ && ||
    enum Op {Add, Div, Mul}

    Expression Left;
    Expression Right;
    
}

//AssignExpression
//Binary/Unary
//if/else
//switch/case
