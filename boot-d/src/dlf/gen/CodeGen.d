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
module dlf.gen.CodeGen;

import dlf.ast.Node;
import dlf.ast.Declaration;


/// Target Type
enum TargetType { Executable, StaticLib, SharedLib }

/// Target Platform
enum TargetPlatform { Linux, MacOSX, Windows }

/// Target Arch
enum TargetArch { x86_32, x86_64, ARM }


/**
* Codegen Context
*/
struct Context
{
    ///Target Type
    TargetType Type;

    ///Target Platform
    TargetPlatform Platform;

    ///Target Architecture
    TargetArch Arch;

    /// Link program with runtime
    bool EnableRuntime = true;

    /// Object files directory
    string ObjDir;

    /// Binary output directory
    string OutDir;

    /// Binary output Name
    string OutFile;

    /// Header directory for library generation
    string HeaderDir;

    //Package, SourceCode resolving
}


//TODO Split interface compiling and linking to steps need shared context
//a compiling interface creates object files
//a linker interface link them together to final program

//ObjectGen
//NativeGen?
//BinaryGen?

/**
* Binary Generation
*/
interface BinaryGen
{
    //init(context);
    //void addObjectFile()
    //void link();
}


/**
* CodeGen Interface
* Object Generation
*/
interface CodeGen
{
    //init(context);
    //compile Package, result? (object file)
    void compile(PackageDeclaration pd);
    //compile to CodeGenLinking
    //context?
}


//Generic Code Gen Exception?