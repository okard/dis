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
module dlf.Context;

import dlf.sem.SemanticContext;
import dlf.gen.CodeGen;

/// Target Type
enum TargetType { Executable, StaticLib, SharedLib, Binary }

/// Target Platform
enum TargetPlatform { Linux, MacOSX, Windows }

/// Target Arch
enum TargetArch { x86_32, x86_64, ARM, DisVM }

/**
* Global Compiler Context
*/ 
class Context
{
    ///Target Type
    TargetType Type;

    ///Target Platform
    TargetPlatform Platform;

    ///Target Architecture
    TargetArch Arch;

    /// Link program with runtime
    bool EnableRuntime = true;

    //parser context

    ///Libraries to Link
    string[] libs; 

    ///Semantic Context
    SemanticContext Semantic;

    ///Backend/CodeGen Context
    BackendContext Backend;
}