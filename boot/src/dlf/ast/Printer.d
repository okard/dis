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
module dlf.ast.Printer;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Type;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Annotation;

import std.stdio;
import std.string;

/**
* AST Printer
*/
class Printer : Visitor
{

    /// Tab Count
    private ubyte tabDeepness = 0;

    /**
    * Print Ast
    */
    public void print(Node astNode)
    {
        astNode.accept(this);
    }

    //=========================================================================
    //== Visitor Implementation

    /**
    * Visit FunctionDeclaration
    */
    public void visit(FunctionDeclaration fd)
    {
        writet("Function(%s): %s(", toString(fd.FuncType.CallingConv), fd.Name);

        foreach(string key, ubyte index; fd.mArgumentNames)
        {
            auto t = fd.FuncType.Arguments[index];
            writef("%s %s, ", key, t.toString()); 
        }
        
        if(fd.FuncType.mVarArgs)
            writef("%s...", fd.mVarArgsName);

        writefln(") %s", fd.FuncType.ReturnType.toString());
        //fd.mType.mReturnType

        if(fd.Body !is null)
            fd.Body.accept(this);
    }

    /**
    * Visit Package Declaration
    */
    public void visit(PackageDeclaration pd)
    {
        writetln("%sPackage: %s",tabs(),  pd.Name);

        tabDeepness++;
        foreach(fd; pd.Functions)
            fd.accept(this);
        tabDeepness--;
    }

    /**
    * Visit Block Statement
    */
    public void visit(BlockStatement bs)
    {
        writetln("{");
        tabDeepness++;
        foreach(stat; bs.Statements)
            stat.accept(this);
        tabDeepness--;
        writetln("}");
    }

    /**
    * Visit ExpressionStatement
    */
    public void visit(ExpressionStatement expr) 
    {
        expr.Expr.accept(this);
    }

    /**
    * FunctionCall
    */
    public void visit(FunctionCall call) 
    {
        writet("%s(", call.Function.toString());

        foreach(arg; call.Arguments)
        {
            write(toString(arg));
        }

        writeln(")");
    }

    void visit(LiteralExpression){}

    /**
    * Print Statement
    */
    public void visit(Statement stat)
    {
        writef(tabs());
        writeln(toString(stat));
    }

    /**
    * Visit Declaration
    */
    void visit(Declaration decl){}

    /**
    * Visit Expression
    */
    void visit(Expression expr){}

    void visit(ImportDeclaration){}
    void visit(VariableDeclaration){}
    void visit(ClassDeclaration){}
    void visit(TraitDeclaration){}
    void visit(DotIdentifier){}
    void visit(Annotation){}
    void visit(ReturnStatement){}

    /**
    * Get Tabs
    */
    private string tabs()
    {
        return repeat("\t", tabDeepness);
    }

    /**
    * Write with Tabs
    */
    private void writet(T...)(string s, T args)
    {
        write(tabs());
        writef(s, args);
    }

    /**
    * Write Line with Tabs
    */
    private void writetln(T...)(string s, T args)
    {
        write(tabs());
        writefln(s, args);
    }

    //=========================================================================
    //== To String Functions

    /**
    * Expression to string
    */
    public static string toString(Expression exp)
    {
        switch(exp.Type)
        {
            case NodeType.DotIdentifier: return (cast(DotIdentifier) exp).toString();
            case NodeType.FunctionCall: return toString(cast(FunctionCall) exp);
            case NodeType.LiteralExpression: return (cast(LiteralExpression)exp).Value;
            default: return "<unkown expression>";
        }
    }

    /**
    * Statement to string
    */
    public static string toString(Statement stat)
    {
        switch(stat.Type)
        {
            case NodeType.ExpressionStatement: return toString((cast(ExpressionStatement)stat).Expr);
            default: return "<unkown statement>";
        }
    }

    /**
    * DotIdentifier to string
    */
    public static string toString(DotIdentifier di)
    {
        char[] str;

        for(int i=0; i < (di.length-1); i++)
            str ~= di[i] ~ ".";

        str ~= di[di.length-1];
        return cast(string)str;
    }

    /**
    * FunctionCall to string
    */
    public static string toString(FunctionCall fc)
    {
        if(fc.Function is null) return "No function expression set";

        //add arguments
        return "Call: " ~ toString(fc.Function);
    }

    /**
    * Calling Convention to string
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
