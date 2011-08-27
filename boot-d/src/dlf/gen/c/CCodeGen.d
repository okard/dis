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

import dlf.basic.Log;

import dlf.ast.Visitor;
import dlf.ast.Node;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Type;
import dlf.ast.Transform;

import dlf.gen.CodeGen;
import dlf.gen.HeaderGen;
import dlf.gen.c.CCodeWriter;
import dlf.gen.c.CBuilder;

/**
* C Code Generator
*/
class CCodeGen : CodeGen, Visitor
{
    /// Logger
    private LogSource log = Log("CCodeGen");

    /// Compile Context
    private Context ctx;

    /// Header generator
    private HeaderGen hdrgen;

    /// Code Writer 
    private CCodeWriter writer;

    /// Code Builder
    private CBuilder builder;

    /// Current C Package
    private CCodeWriter.CPackage p;

    /// Directory to store c source files
    private string srcDir;

    /// Internal Generated DataTypes
    private CCNode[DataType] types;

    //default header resource
    //private static const string DisCGenHeader = import("dish.h");

    /**
    * Ctor
    */
    this(Context ctx)
    {
        this.ctx = ctx;
        hdrgen = new HeaderGen();
        srcDir = ctx.ObjDir ~ "/src/";
        assert(srcDir.isDir(), "Target src dir isn't a directory");

        // Primary/Builtin Types
        types[VoidType.Instance] = ctype("void");
        types[BoolType.Instance] = ctype("bool");
        types[ByteType.Instance] = ctype("char");
        types[UByteType.Instance] = ctype("unsigned char");
        types[ShortType.Instance] = ctype("short");
        types[UShortType.Instance] = ctype("unsigned short");
        types[IntType.Instance] = ctype("int");
        types[UIntType.Instance] = ctype("unsigned int");
        types[LongType.Instance] = ctype("long");
        types[ULongType.Instance] = ctype("unsigned long");
        types[FloatType.Instance] = ctype("float");
        types[DoubleType.Instance] = ctype("double");
        
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

        //compile imports?
        //compile other packages first or look if they already compile
        //pd.Imports.Package
        foreach(ImportDeclaration id; pd.Imports)
        {
            assert(id.Package !is null, "Import Package not parsed");
            p = writer.Package(srcDir, id.Package.Name);
            dispatchAuto(id.Package);
            //detect if one import has recompiled then this source should be recompiled too?
        }

        //check if already compiled
        //if(extension!CCNode(pd. true) !is null)
        //CCNode Extension for pd
        //check modification date if exists
        

        //Create C Package
        p = writer.Package(srcDir, pd.Name);

        extend(pd, cheader(p.Header.name));
        
        //start creating definitions
        dispatchAuto(pd);

        //For Libraries generate Header Files
        if(ctx.Type == TargetType.StaticLib 
        || ctx.Type == TargetType.SharedLib)
        {
            //hdrgen.create(folder, pd)
        }

        //For Executables generate main function not so good only for package containing main???
        if(ctx.Type == TargetType.Executable)
        {
            //if executable, create main.c file with runtime handling and main function call
            //embed runtime etc
            //write main function
        }

        //compile file
        builder.compile(ctx, writer.getCSources());

        //buildeperate?
        //resulting c files -> compile -> link
        

        //executeable
        //shared lib
        //static lib
    }


    /**
    * Seperate Static Build Function
    */
    static void link(Context ctx)
    {
        CBuilder.link(ctx);
    }
    
    //package -> c package (header, src)

    // Steps:
    //1. package -> *.c, *.h -> List of c files (Path: .objdis/src/*.c,*.h)
    //2. *.c -> *.obj -> List of Objects (Compiler Options)
    //3. *.obj -> binary (Linker Options)

    //debug infos with #line


    /**
    * Compile Package Declaration
    */
    void visit(PackageDeclaration pd)
    { 
        //extend(pd, new CCNode(filename));
        p.start(pd.Name.toUpper.replace(".", "_"));

        //include default header dish.h

        //Imports

        //check package imports they should go in first
        
        p.close();
    }

    /**
    * Compile Import Declarations
    */
    void visit(ImportDeclaration id)
    {
        //imports are includes
        //get compile header name
        //p.include( extension!ccode(id.Package, true).header);
         
    }

    /**
    * Compile FunctionDeclaration
    */
    void visit(FunctionDeclaration fd)
    { 
        //for def(C) declarations -> create c definitions

        //foreach(fd.Instances)

        //compile FunctionType fd.Instances
        //mangle name?
        // datatype 

    }

    void visit(VariableDeclaration vd){ }
    void visit(ClassDeclaration cd){  }
    void visit(TraitDeclaration td){  }

    //Statements
    void visit(BlockStatement bs){  }
    void visit(ExpressionStatement es){  }
    void visit(ReturnStatement rt){  }

    //Expressions
    void visit(LiteralExpression le){  }
    void visit(CallExpression fc){  }
    void visit(DotIdentifier di){  }
    void visit(AssignExpression ae){  }
    void visit(BinaryExpression be){  }


    /**
    * Auto Dispatch
    */
    private T dispatchAuto(T)(T e)
    {
        return cast(T)dispatch(e, this);
    }

    /**
    * Map Dispatch to Arrays
    */
    private void mapDispatch(T)(T[] elements)
    {
        for(int i=0; i < elements.length; i++)
        {
            dispatchAuto(elements[i]);
        }
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
    * Compiler AST Extension Nodes
    */
    private static class CCNode : Node
    {
        //header file name

        /// Type List for C Code Identifier
        enum IdentifierType { Header, Function, Struct, Var, Type};

        /// Type of C Code Identifier
        IdentifierType Type;

        /// Identifier in C
        string Identifier;

        //allocator function?
        //is value type 
        //is ptr type?

        ///Node Kind Mixin
        mixin(IsKind("Backend"));

    }

}