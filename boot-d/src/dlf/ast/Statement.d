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
module dlf.ast.Statement;

import dlf.ast.Node;
import dlf.ast.Visitor;
import dlf.ast.Expression;

import dlf.ast.SymbolTable;
 

/**
* Statement Base Class
*/
abstract class Statement : Node
{
    //index?
} 

/**
* Defines a Block {}
* Is more Declaration?
* Has a SymbolTable?
* Can have classes, functions, ...
* Occurs in Functions, Loops, LambdaExpressions, ...
*/
final class BlockStatement : Statement
{
    ///Symbol Table
    public SymbolTable SymTable;

    ///Statements
    public Statement[] Statements;

    ///Mixin for Kind Declaration
    mixin(IsKind("BlockStatement"));
}

/**
* A Expression Statement
* e.g. Function Call, Assign Expression
*/
final class ExpressionStatement : Statement
{
    /// Expression
    public Expression Expr;

    ///Create new ExpressionStatement
    public this(Expression expr)
    {
        Expr = expr;
    }

    ///Mixin for Kind Declaration
    mixin(IsKind("ExpressionStatement"));
}

/**
* Return Statement
*/
final class ReturnStatement : Statement
{
    /// The Return Expression
    public Expression Expr;

    /// Create new Return Statement
    public this(Expression expr)
    {
        Expr = expr;
    }

    ///Mixin for Kind Declaration
    mixin(IsKind("ReturnStatement"));
}

/**
* For Statement
*/
final class ForStatement : Statement
{
    /// Initialization Statements
    public Statement[] InitializerStmts;

    /// Break Condition
    public Expression ConditionExpr;

    /// Statements done after a run
    public Statement[] RunStmts;

    /// The Body Statement
    public Statement Body;

    ///Mixin for Kind Declaration
    mixin(IsKind("ForStatement"));
}

/**
* For-Each Statement
*/
final class ForEachStatement : Statement
{
    //public VariableDeclaration Var;

    public Expression List;

    ///Body Statement
    public Statement Body;

    ///Mixin for Kind Declaration
    mixin(IsKind("ForEachStatement"));
}

/**
* While Statement
* Do-While Statement
*/
final class WhileStatement : Statement
{
    /// Post test condition, While or DoWhile
    bool PostTest = false;

    ///Loop Condition
    public Expression Condition;

    /// Body Statement
    public Statement Body;

    ///Mixin for Kind Declaration
    mixin(IsKind("WhileStatement"));
}
