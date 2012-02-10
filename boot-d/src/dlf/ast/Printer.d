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

import std.stdio;
import std.string;
import std.array;

import dlf.basic.Util;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Type;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Annotation;

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
    void visit(PackageDecl pd)
    {
        writetln("%sPackage: %s",tabs(),  pd.Name);

        tabDeepness++;
        foreach(fd; pd.SymTable)
            dispatch(fd, this);
        tabDeepness--;
    }


    /**
    * Visit FunctionSymbol
    */
    void visit(FunctionDecl fd)
    {
        writet("def(%s): %s(", toString(fd.CallingConv), to!Declaration(fd.Parent).Name);

        foreach(FunctionParameter p; fd.Parameter)
        {
            //if(p.Definition.length == 2)
            //    writef("%s : %s", p.Definition[0], p.Definition[1]);
            if(p.Vararg) writef("...");
            
            if(p != fd.Parameter[$-1])
            writef(", ");
        }

        writefln(") %s", fd.ReturnType);

        if(fd.Body !is null)
            dispatch(fd.Body, this);

        foreach(FunctionDecl fdo; fd.Overrides)
            visit(fdo);
    }

    /**
    * Print Imports
    */
    void visit(ImportDecl imp)
    {
    }
    

    /**
    * Print Variable Declaration
    */
    void visit(VariableDeclaration vd)
    {
        writet("var %s : %s = ", vd.Name, vd.VarDataType.toString());
        dispatch(vd.Initializer, this);
        writeln();
    }

    /**
    * Class
    */
    void visit(ClassDeclaration cd){}
    void visit(TraitDeclaration td){}

    void visit(StructDeclaration sd){}

    /**
    * Visit Block Statement
    */
    void visit(BlockStmt bs)
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
    void visit(ExpressionStmt expr) 
    {
        writet("");
        dispatch(expr.Expr, this);
        writeln();
    }

    void visit(ReturnStmt rs){  }

    /**
    * FunctionCall
    */
    void visit(CallExpression call) 
    {
        writet("%s(", call.Func.toString());

        foreach(arg; call.Arguments)
        {
            dispatch(arg, this);
        }

        writeln(")");
    }

    /**
    * Print Literals
    */
    void visit(LiteralExpression le)
    {
        if(le.ReturnType == StringType.Instance)
        {
            writef("\"%s\"", replace(le.Value, "\n", "\\n"));
        }
        else
            writef("%s", le.Value);
    }

    /**
    * Print Binary Expression
    */
    void visit(BinaryExpression be)
    {
        dispatch(be.Left, this);
        write(" <op> ");
        dispatch(be.Right, this);
    }

    /**
    * Visit Dot Identifier
    */
    void visit(IdentifierExpression di)
    {
        write(di.toString());
    }

    /**
    * Get Tabs
    */
    private string tabs()
    {
        return replicate("\t", tabDeepness);
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
        switch(exp.Kind)
        {
            case NodeKind.IdentifierExpression: return (cast(IdentifierExpression) exp).toString();
            case NodeKind.CallExpression: return toString(cast(CallExpression) exp);
            case NodeKind.LiteralExpression: return (cast(LiteralExpression)exp).Value;
            default: return "<unkown expression>";
        }
    }

    /**
    * Statement to string
    */
    public static string toString(Statement stat)
    {
        switch(stat.Kind)
        {
            case NodeKind.ExpressionStmt: return toString((cast(ExpressionStmt)stat).Expr);
            default: return "<unkown statement>";
        }
    }

    /**
    * FunctionCall to string
    */
    public static string toString(CallExpression fc)
    {
        if(fc.Func is null) return "No function expression set";

        //add arguments
        return "Call: " ~ toString(fc.Func);
    }

    /**
    * Calling Convention to string
    */
    private static string toString(CallingConvention cc)
    {
        switch(cc)
        {
        case CallingConvention.C: return "C";
        case CallingConvention.Dis: return "Dis";
        default: return "";
        }
    }
} 
