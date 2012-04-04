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
    /// Index of Statement in containing construct
    uint Index = 0; 
} 

/**
* Defines a Block {}
* Is more Declaration?
* Has a SymbolTable?
* Can have classes, functions, ...
* Occurs in Functions, Loops, LambdaExpressions, ...
*/
final class BlockStmt : Statement
{
    /// Symbol Table
    public SymbolTable SymTable;

    public InstanceDecl[string] Data;

    /// Statements
    public Statement[] Statements;

    /// Mixin for Kind Declaration
    mixin(IsKind("BlockStmt"));
}

/**
* A Expression Statement
* e.g. Function Call, Assign Expression
*/
final class ExpressionStmt : Statement
{
    /// Expression
    public Expression Expr;

    ///Create new ExpressionStatement
    public this(Expression expr)
    {
        Expr = expr;
        expr.Parent = this;
    }

    /// Mixin for Kind Declaration
    mixin(IsKind("ExpressionStmt"));
}

/**
* Return Statement
*/
final class ReturnStmt : Statement
{
    /// The Return Expression
    public Expression Expr;

    /// Function Declaration
    public FunctionDecl Func;

    /// Create new Return Statement
    public this(Expression expr)
    {
        Expr = expr;
    }

    /// Mixin for Kind Declaration
    mixin(IsKind("ReturnStmt"));
}

/**
* For Statement
*/
final class ForStmt : Statement
{
    /// Symbol Table?

    /// Initialization Statements
    public Statement[] InitializerStmts;

    /// Break Condition
    public Expression ConditionExpr;

    /// Statements done after a run
    public Statement[] RunStmts;

    /// The Body Statement
    public Statement Body;

    /// Mixin for Kind Declaration
    mixin(IsKind("ForStmt"));
}

/**
* For-Each Statement
*/
final class ForEachStmt : Statement
{
    //public VarDecl Var;

    public Expression List;

    /// Body Statement
    public Statement Body;

    /// Mixin for Kind Declaration
    mixin(IsKind("ForEachStmt"));
}

/**
* While Statement
* Do-While Statement
*/
final class WhileStmt : Statement
{
    /// Post test condition, While or DoWhile
    bool PostCondition = false;

    ///Loop Condition
    public Expression Condition;

    /// Body Statement
    public Statement Body;

    /// Mixin for Kind Declaration
    mixin(IsKind("WhileStmt"));
}


/**
* 'continue' Statement
*/
final class ContinueStmt : Statement
{
    //target statement
}

/**
* 'break' Statement
*/
final class BreakStmt : Statement
{
    //target statement
}

//Try Catch Finally Throw

final class ThrowStmt : Statement
{
}

final class TryStmt : Statement
{
}

final class CatchStmt : Statement
{
}

final class FinallyStmt : Statement
{
}
