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
module dlf.gen.c.CCodeGen;

import std.array;
import std.string;
import std.file;
import std.path;

import dlf.basic.Log;
import dlf.basic.Util;

import dlf.ast.Visitor;
import dlf.ast.Node;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Type;

import dlf.Context;
import dlf.gen.Mangle;
import dlf.gen.CodeGen;
import dlf.gen.HeaderGen;
import dlf.gen.c.CCodeWriter;
import dlf.gen.c.CBuilder;

/**
* C Code Generator
*/
class CCodeGen : ObjectGen, Visitor
{
    /// Logger
    private LogSource log = Log("CCodeGen");

    /// Compile Context
    private Context ctx;

    /// Code Writer 
    private CCodeWriter writer;

    /// Code Builder
    private CBuilder builder;

    /// Current C Package
    private CCodeWriter.CPackage p;

    /// Directory to store c source files
    private string srcDir;

    //default header resource
    private static const string DisCGenHeaderName = "dis.h";
    private static const string DisCGenHeader = import(DisCGenHeaderName);

    /**
    * Ctor
    */
    this(Context ctx)
    {
        this.ctx = ctx;

        if(!ctx.Backend.ObjDir.isDir())
            std.file.mkdirRecurse(ctx.Backend.ObjDir);
        
        srcDir = buildPath(ctx.Backend.ObjDir, "tmpDisSrc");
        //TODO create dir
        assert(srcDir.isDir(), "Target src dir isn't a directory");
        writer.SourceDirectory = srcDir;

        // Primary/Builtin Types
        VoidType.Instance.CodeGen = ctype("dis_void");
        BoolType.Instance.CodeGen = ctype("dis_bool");
        ByteType.Instance.CodeGen = ctype("dis_byte");
        UByteType.Instance.CodeGen = ctype("dis_ubyte");
        ShortType.Instance.CodeGen = ctype("dis_short");
        UShortType.Instance.CodeGen = ctype("dis_ushort");
        IntType.Instance.CodeGen = ctype("dis_int");
        UIntType.Instance.CodeGen = ctype("dis_uint");
        LongType.Instance.CodeGen = ctype("dis_long");
        ULongType.Instance.CodeGen = ctype("dis_uint");
        FloatType.Instance.CodeGen = ctype("dis_float");
        DoubleType.Instance.CodeGen = ctype("dis_double");

        VoidType.PtrInstance.CodeGen = ctype("dis_ptr");
        

        //string_literal = bytearray
        //string_type = runtime class

        //special case utf8 -> 4 byte chars?
        //types[CharType.Instance] = ;
        //string runtime linking 
        //add it ever, failes if used and not linked to rt
        //types[StringType.Instance] = ctype("_Disrt.");
    }

    /**
    * Compile Package
    */
    void compile(PackageDeclaration pd)
    {
        assert(pd !is null, "PackageDeclaration is null");
        
        //Package already compiled
        if(pd.CodeGen !is null)
            return;

        //Write Dis Helper Header to src dir
        std.file.write(buildPath(srcDir, DisCGenHeaderName), DisCGenHeader); 

        //compile imports?
        //compile other packages first or look if they already compile
        //pd.Imports.Package
        foreach(ImportDeclaration id; pd.Imports)
        {
            assert(id.Package !is null, "Import Package not parsed");
            
            //already compiled
            if(id.Package.CodeGen !is null)
                continue;

            //first compile imports to get right include names
            autoDispatch(id.Package);

            //detect if one import has recompiled then this source should be recompiled too?
            //Imports to compile before? 
            //so assert when its not yet compiled?
        }

        //start creating definitions
        autoDispatch(pd);

        //compile file, create object file for this package (return object file)
        builder.compile(ctx, [p.SourceFile]);
    }


    /**
    * Seperate Static Build Function
    */
    void link(Context ctx)
    {
        //TODO object files as parameter
        builder.link(ctx, CBuilder.objfiles);
    }

    //debug infos with #line


    /**
    * Compile Package Declaration
    */
    void visit(PackageDeclaration pd)
    { 
        //Package already compiled
        if(pd.CodeGen !is null)
            return;

        //check if target header & source file exist
        //and check modify date when its not newer than already c code is compiled

        //Create C Package
        p = writer.Package(pd.Name);
        pd.CodeGen = cheader(p.Header.name);

        //extend(pd, new CCNode(filename));
        p.start(pd.Name.toUpper.replace(".", "_"));

        p.include(DisCGenHeaderName);

        //include default header dish.h ???
        //Imports
        mapDispatch(pd.Imports);

        //go through declarations
        foreach(Declaration d; pd.SymTable)
            autoDispatch(d);
        
        p.close();
    }

    /**
    * Compile Import Declarations
    */
    void visit(ImportDeclaration id)
    {
        //imports are includes
        //get compile header name
        //p.include(getgen(id.Package).Identifier);
    }

    /**
    * Compile FunctionSymbol
    */
    void visit(FunctionDeclaration fd)
    {
        //generate for each instantiation of (tpl) function
        foreach(FunctionType ft; fd.Instances)
        {
            //Generate code for each function instance
            gen(ft);
            //fd.Body[ft]
        }

        //generate overrides functions
        //unique name through mangleing
        mapDispatch(fd.Overrides);

        //generate c main wrapper
        //main can't be a template so generate c main here
        if(fd.Name == "main")
            genCMain();
    }

    /**
    * Generate Function type
    */
    private void gen(FunctionType ft)
    {
        auto funcDecl = to!FunctionDeclaration(ft.FuncDecl);

        //write type information for runtime?
        
        //name for function type
        string name = funcDecl.CallingConv == CallingConvention.C ?
                      funcDecl.Name :
                      Mangle.mangle(ft);

        log.Information("Function: %s", name);

        //TODO checking
        //TODO prepare parameter
        //TODO write demangled name above as comment

        //add codegen node
        ft.CodeGen = cfunction(name);

        //resolve retun type
        //TODO gen code for when not yet done? gen declaration?
        string rettype = getgen(ft.ReturnType).Identifier;
        
        //reate function declaration
        p.debugln(funcDecl.Loc);
        p.funcDecl(rettype, name, []);

        //write body aka function definition
        if(ft.Body !is null)
        {
            assert(ft.Body.Kind == NodeKind.BlockStatement, "Sem should rewrite body to block statement");

            //start function definition
            p.funcDef(rettype, name, []);
            
            autoDispatch(ft.Body);
        }
    }

    /**
    * Generate C main function
    */
    private void genCMain()
    {
        log.Information("Generate C Main Function");

        p.funcDef("int", "main", ["int argc", "char **argv"]);
        p.blockStart();
        
        if(ctx.EnableRuntime)
        {
            //init runtime
            //initialize linked libs
        }

        //convert arguments to dis array (runtime??)
        //call dis main

        if(ctx.EnableRuntime)
        {
            //disable runtime
            //deinitialize linked libs
        }

        p.blockEnd();
    }
    

    void visit(VariableDeclaration vd)
    {
        //value vs reference type

        //initializer maybe not working here directly (globalvariables?)
        //p.variable(type, name, initializer);
    }

    void visit(ClassDeclaration cd)
    {
        //add to type array?

        //type information for runtime?

        //generate for each class instance
    }
    
    void visit(TraitDeclaration td)
    {  
        //add to type array?
    }

    //Statements
    void visit(BlockStatement bs)
    {  
        p.blockStart();
        //write variables
        //write statements
        p.blockEnd();
    }
    
    void visit(ExpressionStatement es)
    {  
        autoDispatch(es.Expr);
    }

    void visit(ReturnStatement rt)
    {  
        //save expression result
        //return it
    }

    //Expressions
    void visit(LiteralExpression le)
    {  
        //write value
    }
    
    
    void visit(CallExpression ce)
    {  
        //retrieve functionname
        //arguments maybe need to be prepared
        //p.call(name, [args]);
    }

    void visit(IdentifierExpression di)
    {
        //TODO how this?
        // this->foo->bar when reference
        // this.foo.bar when value type
    }

    void visit(BinaryExpression be)
    {  
        //write be.Left
        //write op
        //write be.Right
    }


    /// Mixin Dispatch Utils
    mixin DispatchUtils!false;

   /**
    * Log Event
    */
    @property
    ref LogEvent OnLog()
    {
        return log.OnLog;
    }

    /**
    * Get CCNode from node
    */
    private static CCNode getgen(Node n) 
    {
        return to!CCNode(n.CodeGen);
    }

    /**
    * create a simple type node
    */
    private static CCNode ctype(string name)
    {
        auto n = new CCNode();
        n.Type = CCNode.IdentifierType.Type;
        n.Identifier = name;
        return n;
    }

    /**
    * Create c function node
    */
    private static CCNode cfunction(string name)
    {
        auto n = new CCNode();
        n.Type = CCNode.IdentifierType.Function;
        n.Identifier = name;
        return n;
    }

    /**
    * Create a c header node
    */
    private static CCNode cheader(string file)
    {
        auto n = new CCNode();
        n.Type = CCNode.IdentifierType.Header;
        n.Identifier = file;
        return n;
    }

    /**
    * Compiler AST Extension Node for c code backend
    * C Codegen Node
    */
    private static class CCNode : Node
    {
        //header file name

        /// Type List for C Code Identifier
        enum IdentifierType { Unkown, Header, Function, Struct, Var, Type};

        /// Type of C Code Identifier
        IdentifierType Type;

        /// Identifier in C
        string Identifier;

        //allocator function?
        //is value type 
        //is ptr type?
        //declaration
        //definitions

        //objfile

        //Union

        /**
        * Create new Compiler AST Node
        */
        this()
        {
        }

        /**
        * Create new Compiler AST Node
        */
        this(string identifier, IdentifierType type = IdentifierType.Unkown)
        {
            Identifier = identifier;
            Type = type;
        }

        ///Node Kind Mixin
        mixin(IsKind("Backend"));
    }

}