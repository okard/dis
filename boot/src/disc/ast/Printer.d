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
module disc.ast.Printer;

import disc.ast.Node;
import disc.ast.Type;
import disc.ast.Declaration;
import disc.ast.Statement;
import disc.ast.Expression;

import std.stdio;

/**
* AST Printer
*/
class Printer
{

    /**
    * Print FunctionDeclaration
    */
    public void print(FunctionDeclaration fd)
    {
        writef("Function(%s): %s(", toString(fd.mType.mCallingConv), fd.mName);

        foreach(string key, ubyte index; fd.mArgumentNames)
        {
            auto t = fd.mType.mArguments[index];
            writef("%s %s, ", key, t.toString()); 
        }
        
        if(fd.mType.mVarArgs)
            writef("%s...", fd.mVarArgsName);

        writefln(") %s", fd.mType.mReturnType.toString());
        //fd.mType.mReturnType

        if(fd.mBody !is null)
            print(fd.mBody);
    }

    /**
    * Print Package Declaration
    */
    public void print(PackageDeclaration pd)
    {
        writefln("Package: %s",  pd.mName);

        foreach(fd; pd.mFunctions)
            print(fd);
    }

    /**
    * Print Block Statement
    */
    public void print(BlockStatement bs)
    {
        writeln("{");
        foreach(Statement stat; bs.mStatements)
            print(stat);
        writeln("}");
    }

    /**
    * Print statement
    */
    public void print(Statement stat)
    {
        writeln(toString(stat));
    }


    public static string toString(Expression exp)
    {
        switch(exp.mNodeType)
        {
            case NodeType.DotIdentifier: return toString(cast(DotIdentifier) exp);
            case NodeType.FunctionCall: return toString(cast(FunctionCall) exp);
            default: return "<unkown expression>";
        }
    }

    public static string toString(Statement stat)
    {
        switch(stat.mNodeType)
        {
            case NodeType.ExpressionStat: return toString((cast(ExpressionStatement)stat).mExpression);
            default: return "<unkown statement>";
        }
    }


    public static string toString(DotIdentifier di)
    {
        char[] str;

        for(int i=0; i < (di.mIdentifier.length-1); i++)
            str ~= di.mIdentifier[i] ~ ".";

        str ~= di.mIdentifier[di.mIdentifier.length-1];
        return cast(string)str;
    }

    /**
    * to string
    */
    public static string toString(FunctionCall fc)
    {
        if(fc.mFunction is null) return "No function expression set";

        //add arguments
        return "Call: " ~ toString(fc.mFunction);
    }

    /**
    * Calling Convention to String
    */
    private static string toString(FunctionType.CallingConvention cc)
    {
        switch(cc)
        {
        case FunctionType.CallingConvention.C: return "C";
        case FunctionType.CallingConvention.Dis: return "Dis";
        default: return "";
        }
    }
} 
