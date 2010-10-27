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
module disc.ast.Visitor;

import disc.ast.Declaration;
import disc.ast.Statement;
import disc.ast.Expression;

/**
* AST Visitor
*/
interface Visitor
{
    //Specialized Visits
    void visit(PackageDeclaration pack);
    void visit(FunctionDeclaration func);
    //Base Visits
    void visit(Declaration decl);
    void visit(Statement stat);
    void visit(Expression expr);
}

/**
* Visitor Mixin
*/
mixin template VisitorMixin()
{
    /// Accept Visitor
    public override void accept(Visitor v) { v.visit(this); }
}
    