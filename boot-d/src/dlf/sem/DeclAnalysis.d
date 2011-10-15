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
module dlf.sem.DeclAnalysis;

public import dlf.basic.Util;

/**
* Semantic Functions for Types
*/
mixin template DeclAnalysis()
{

    /**
    * Analyze the function parameter definition
    */
    private void analyzeFuncParam(ref FunctionBase fd)
    {
        //detect if template function or not

        foreach(FunctionParameter p; fd.Parameter)
        {
            log.Information("Param %s Type: %s", p.Name, p.Type);
            //type should not been Unkown or unsolved
            //p.Type
            //p.Name
            //p.Vararg
        }
    }

    /**
    * Analyze the function statement
    */ 
    private void analyzeFuncStmt(ref FunctionBase fd)
    {
        if(fd.Body is null) return;

        //fix Expression Statement
        if(fd.Body.Kind == NodeKind.ExpressionStatement)
        {
            auto block = new BlockStatement();
            block.Statements ~= new ReturnStatement(to!(ExpressionStatement)(fd.Body).Expr);
            fd.Body = block;
        }
        //fix other statements
        if(fd.Body.Kind != NodeKind.BlockStatement)
        {
            auto block = new BlockStatement();
            block.Statements ~= fd.Body;
            fd.Body = block;
        }
    }

    /**
    * Analyze Main Function
    */
    private void analyzeMainFunc(ref FunctionSymbol func)
    {
        assert(func.Name == "main");

        assert(func.Bases.length == 0, "Multiple defintion of main not allowed");

        auto base = func.Bases[0];

        assertSem(base.Body !is null, "main function required body");

        log.Information("main func parameter count: %s", base.Parameter.length);

        assert(base.Parameter.length != 1, "a main function can only have one parameter");

        if(base.ReturnType.Kind == NodeKind.OpaqueType)
            base.ReturnType = VoidType.Instance;

        //return type: unsolved then solved
        //finally only int or void are allowed

        assert(base.ReturnType == VoidType.Instance || base.ReturnType == IntType.Instance, "main function can be only have return type void or int");

        //FunctionParameter for main should be 
        
        if(func.Instances.length == 0)
        {
            auto type = new FunctionType();
            type.FuncDecl = func;
            type.FuncBase = base;
            type.ReturnType =  base.ReturnType;
            type.Body = base.Body;
            
            if(base.Parameter.length ==1)
            {
                //at string[] argument
                //type.Arguments  ~=
            }

            func.Instances ~= type;
            //generate instance
            //mangled?
        }

        //requires body
    }

}