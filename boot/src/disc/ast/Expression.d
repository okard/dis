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
module disc.ast.Expression;

import disc.ast.Node;
import disc.ast.Type;

/**
* Base Class for Expression
*/
abstract class Expression : Node
{
    Type mReturnType;
}

/**
* Dotted Identifier
* e.g. foo.bar.x.y
*/
class DotIdentifier : Expression
{
    ///parts of identifiers splitted with .
    char[][] mIdentifier;

    //resolve type
    //Type type;

    /**
    * Create dotted identifier
    */
    public this(char[] identifier)
    {
        mNodeType = NodeType.DotIdentifier;
        mIdentifier ~= identifier;
    }

    /**
    * To string
    */
    override string toString()
    {
        char[] str;
        foreach(ident; mIdentifier)
            str ~= ident ~ ".";
        return cast(string)str;
    }
}

/**
* A Function Call
*/
class FunctionCall : Expression
{
    ///Expression to retrieve a function type
    Expression mFunction;

    /// Arguments for function call
    Expression[] mArguments;

    //return type is mFunction.solve().mReturnType

    this()
    {
        mNodeType = NodeType.FunctionCall;
    }

    /**
    * to string
    */
    override string toString()
    {
        if(mFunction is null) return "No function expression set";

        //add arguments
        return "Call: " ~ mFunction.toString();
    }
}
