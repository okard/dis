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
module dlf.sem.Semantic;

import std.string;

import dlf.basic.Log;

import dlf.Context;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Annotation;
import dlf.ast.Type;
import dlf.ast.SymbolTable;

import dlf.sem.DeclAnalysis;
import dlf.sem.TypeAnalysis;

import std.stdio;

//TODO Add Initializer Expressions for builtin data types

/**
* Semantic Pass for AST
*/
final class Semantic
{
    //Semantic Logger
    private LogSource log = Log("Semantic");

    /// Type Resolver Run
    private TypeAnalysis typeResolver;

    /// Context
    private Context context;


    /**
    * Ctor
    */
    public this(Context ctx)
    {
        this.context = ctx;
        typeResolver = new TypeAnalysis(this);
    }

    /**
    * Run semantic passes 
    * Parse Tree -> AST
    */
    public Node run(Node astNode)
    {
        //prepare runtime imports for package types
        if(astNode.Kind == NodeKind.PackageDecl)
        {
            //check filename and package decl
            checkPackageName(cast(PackageDecl)astNode);
            
            //setDefaultImports(astNode);
        }
        
        //resolve types
        astNode = dispatch(astNode, typeResolver);
    
        //scope instanciatio classes

        //TODO Multiple Runs?
        return astNode;
    }

    /**
    * Run semantic for a package
    */
    public PackageDecl run(PackageDecl pd)
    {

        checkPackageName(pd);
        //prepare step?
        //resolve types
        pd = cast(PackageDecl)dispatch(pd, typeResolver);

        return pd;
    }

    
    /**
    * Package Name and File Path must match
    */
    private void checkPackageName(PackageDecl pkg)
    {    
        import std.path;

        auto pkgname = pkg.PackageIdentifier;
        auto pathr = pathSplitter(stripExtension(absolutePath(pkg.Loc.Name)));
        auto index = pkgname.length-1;

        //namespace module
        if(pathr.back != pkgname[index])
            index--;

        //loop through package parts which must be match with directory structure
        while(index >= 0)
        {
            Information("Package Path Check %d %s == %s", index, pathr.back, pkgname[index]);
            if(pathr.back != pkgname[index])
            {
                 Error("package <-> path does not match");
                 throw new SemanticException("package path validation");
            }
            
            if(index == 0)
                break;

            //TODO fix pathr.empty

            index--;
            pathr.popBack();   
        } 
    }
    

    /**
    * Semantic Information Log
    */
    package final void Information(T...)(string s, T args)
    {
        log.log!(LogType.Information)(s, args);
    }

    /**
    * Semantic Error Log
    */
    package final void Error(T...)(string s, T args)
    {
        log.log!(LogType.Error)(s, args);
    }

    /**
    * Fatal semantic error
    */
    package final void Fatal(string msg = "")
    {
         throw new SemanticException(msg);
    }

    /**
    * Semantic Assert
    */
    private void assertSem(bool cond, string message)
    {
        if(!cond)
        {
            Error(message);
            Fatal(message);
        }
    }

    /**
    * Log Event
    */
    @property
    ref LogEvent OnLog()
    {
        return log.OnLog;
    }

    
    /**
    * Get the context
    */
    @property
    package
    ref Context SemContext()
    {
        return context;
    }
    
    /**
    * Semantic Exception
    */
    public static class SemanticException : Exception
    {
        /// New Semantic Exception
        this(string msg)
        {
            super(msg);
        }
    }
}