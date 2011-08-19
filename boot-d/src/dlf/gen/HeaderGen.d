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
module dlf.gen.HeaderGen;

import dlf.ast.Visitor;


/**
* Generate Dis Header
*/
class HeaderGen : Visitor
{

    //Declarations
    Node visit(PackageDeclaration pd){ return pd; }
    Node visit(ImportDeclaration id){ return id; }
    Node visit(FunctionDeclaration fd){ return fd; }
    Node visit(VariableDeclaration vd){ return vd; }
    Node visit(ClassDeclaration cd){ return cd; }
    Node visit(TraitDeclaration td){ return td; }
    //Statements
    Node visit(BlockStatement bs){ return bs; }
    Node visit(ExpressionStatement es){ return es; }
    Node visit(ReturnStatement rs){ return rs; }
    //Expressions
    Node visit(LiteralExpression le){ return le; }
    Node visit(CallExpression ce){ return ce; }
    Node visit(DotIdentifier di){ return di; }
    Node visit(AssignExpression ae){ return ae; }
    Node visit(BinaryExpression be){ return be; }
}
