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
module dlf.gen.Semantic;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Type;
import dlf.ast.SymbolTable;

import std.stdio;

/**
* Semantic Pass for AST
*/
class Semantic : Visitor
{
    /// Current Symbol Table
    private SymbolTable mSymTbl;

    //rules
    //semantic passes?

    //Type stack name -> Type 
    //Stack!(Type[char[]])

    //Import external types into actual PackageDeclaration 
    //Mark as external 
    //error when a import isn't resolved
    
    /**
    * Visit Declaration
    */
    void visit(Declaration decl)
    {
    }

    /**
    * Visit Statement
    */
    void visit(Statement stat)
    {
    }

    /**
    * Visit Expression
    */
    void visit(Expression expr)
    {
    }

    /**
    * Visit PackageDeclaration
    */
    void visit(PackageDeclaration pack)
    {
        foreach(FunctionDeclaration f; pack.mFunctions)
            f.accept(this);  
    }

    /**
    * Visit FunctionDeclaration
    */
    void visit(FunctionDeclaration func)
    { 
        Information("Semantic FuncDcl %s", func.Name);

        Information("\t return type %s", func.FuncType.ReturnType.toString());
        //resolve return value
        if(func.FuncType.ReturnType is null || func.FuncType.ReturnType == OpaqueType.Instance)
        {
            func.FuncType.ReturnType = VoidType.Instance;
            
            //if has body look through all return statements

            Information("\t Resolved ReturnType of '%s' is '%s'", func.Name, func.FuncType.ReturnType.toString());
        }

        //check if no Body then do through parameters 
        //Single Pairs are types

        
        //go into Body
        if(func.Body !is null)
            func.Body.accept(this);
    }

    /**
    * Visit Block Statement
    */
    void visit(BlockStatement block)
    {
        foreach(stat; block.Statements)
            stat.accept(this);
    }

    /**
    * Visit Expression Statement
    */
    void visit(ExpressionStatement expr)
    {
        expr.mExpression.accept(this);
    }

    /**
    * Visit Function Call
    */
    void visit(FunctionCall call)
    {
        Information("Semantic FuncCall %s", call.Function.toString());
        
        //check for function
        //call.mFunction.NType() == NodeType.DotIdentifier
        //Look for parameter type matching
        auto fexpr = call.Function;
        
        //Expression to Function

        if(fexpr.Type == NodeType.DotIdentifier)
        {
            //get function declaration
        }
    }

    /**
    * Import Declaration
    */
    void visit(ImportDeclaration impDecl)
    {
    }

    void visit(VariableDeclaration){}
    void visit(ClassDeclaration){}
    void visit(TraitDeclaration){}

    /**
    * Get the Declaration of a DotIdentifier
    * e.g. "this.foo.bar.x" is a VariableDeclaration(int)
    */
    private Declaration resolve(DotIdentifier di)
    {
        //Symbol Table should not be null

        return null;
    }

    /**
    * Run semantic passes 
    * Parse Tree -> AST
    */
    public Node run(Node astNode)
    {
        astNode.accept(this);
        return astNode;
    }


    /**
    * Semantic Information Log
    */
    private void Information(T...)(string s, T args)
    {
        writefln(s, args);
    }

    /**
    * Semantic Error Log
    */
    private void Error(T...)(string s, T args)
    {
        writefln(s, args);
    }

}