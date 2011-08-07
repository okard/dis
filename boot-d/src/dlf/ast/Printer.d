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
import std.array;

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
        dispatch(astNode, this);
    }

    //=========================================================================
    //== Visitor Implementation


    /**
    * Visit Package Declaration
    */
    public override void visit(PackageDeclaration pd)
    {
        writetln("%sPackage: %s",tabs(),  pd.Name);

        tabDeepness++;
        foreach(fd; pd.Functions)
            dispatch(fd, this);
        tabDeepness--;
    }

    /**
    * Visit FunctionDeclaration
    */
    public override void visit(FunctionDeclaration fd)
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
            dispatch(fd.Body, this);
    }


    void visit(ImportDeclaration imp)
    {
    }
    

    /**
    * Print Variable Declaration
    */
    public void visit(VariableDeclaration vd)
    {
        writet("var %s : %s = ", vd.Name, vd.VarDataType.toString());
        dispatch(vd.Initializer, this);
        writeln();
    }


    void visit(ClassDeclaration){}
    void visit(TraitDeclaration){}

    /**
    * Visit Block Statement
    */
    public override void visit(BlockStatement bs)
    {
        writetln("{");
        tabDeepness++;

        foreach(Declaration sym; bs.SymTable)
            dispatch(sym, this);

        foreach(stat; bs.Statements)
            dispatch(stat, this);

        tabDeepness--;
        writetln("}");
    }

    /**
    * Visit ExpressionStatement
    */
    public override void visit(ExpressionStatement expr) 
    {
        writet("");
        dispatch(expr.Expr, this);
        writeln();
    }

    void visit(ReturnStatement){}

    /**
    * FunctionCall
    */
    public override void visit(FunctionCall call) 
    {
        writet("%s(", call.Function.toString());

        foreach(arg; call.Arguments)
        {
            dispatch(arg, this);
        }

        writeln(")");
    }

    /**
    * Print Literals
    */
    override void visit(LiteralExpression le)
    {
        if(le.ReturnType == StringType.Instance)
        {
            writef("\"%s\"", replace(le.Value, "\n", "\\n"));
        }
        else
            writef("%s", le.Value);
    }

    /**
    * Print Assign Expression
    */
    override void visit(AssignExpression ae)
    {
        dispatch(ae.Target, this);
        write(" = ");
        dispatch(ae.Value, this);
    }

    /**
    * Print Binary Expression
    */
    override void visit(BinaryExpression be)
    {
        dispatch(be.Left, this);
        write(" <op> ");
        dispatch(be.Right, this);
    }

    /**
    * Visit Dot Identifier
    */
    override void visit(DotIdentifier di)
    {
        write(di.toString());
    }

    /**
    * Base Statement
    */
    public void visit(Statement stat)
    {
        writefln("TODO: Print: %s", stat.toString());
    }

    /**
    * Base Declaration
    */
    void visit(Declaration decl)
    {
        writefln("TODO: Print: %s", decl.toString());
    }

    /**
    * Base Expression
    */
    void visit(Expression expr)
    {
        writefln("TODO: Print: %s", expr.toString());
    }

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
        switch(exp.ExprType)
        {
            case Expression.Type.Identifier: return (cast(DotIdentifier) exp).toString();
            case Expression.Type.Call: return toString(cast(FunctionCall) exp);
            case Expression.Type.Literal: return (cast(LiteralExpression)exp).Value;
            default: return "<unkown expression>";
        }
    }

    /**
    * Statement to string
    */
    public static string toString(Statement stat)
    {
        switch(stat.StmtType)
        {
            case Statement.Type.Expression: return toString((cast(ExpressionStatement)stat).Expr);
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
