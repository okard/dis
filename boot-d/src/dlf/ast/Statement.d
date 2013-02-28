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

//For Declarations
//final class DeclStmt : Statement 

//TwoKind of Statements with SymbolTable and without

/**
* Defines a Block {}
* Is more Declaration?
* Has a SymbolTable?
* Can have classes, functions, ...
* Occurs in Functions, Loops, LambdaExpressions, ...
*/
final class BlockStmt : Statement
{
	mixin KindMixin!(NodeKind.BlockStmt);
    mixin VisitorMixin;
    
    /// Statements
    public Statement[] Statements;
}

/**
* A Expression Statement
* e.g. Function Call, Assign Expression
*/
final class ExpressionStmt : Statement
{
	mixin KindMixin!(NodeKind.ExpressionStmt);
    mixin VisitorMixin;
    
    /// Expression
    public Expression Expr;

    ///Create new ExpressionStatement
    public this(Expression expr)
    {
        Expr = expr;
        expr.Parent = this;
    }
}

/**
* Return Statement
*/
final class ReturnStmt : Statement
{
	mixin KindMixin!(NodeKind.ReturnStmt);
    mixin VisitorMixin;
    
    /// The Return Expression
    public Expression Expr;

    /// Function Declaration
    public FunctionDecl Func;

    /// Create new Return Statement
    public this(Expression expr)
    {
        Expr = expr;
    }
}

/**
* For Statement
*/
final class ForStmt : Statement
{
	mixin KindMixin!(NodeKind.ForStmt);
    //mixin VisitorMixin;
    
    /// Symbol Table?

    /// Initialization Statements
    public Statement[] InitializerStmts;

    /// Break Condition
    public Expression ConditionExpr;

    /// Statements done after a run
    public Statement[] RunStmts;

    /// The Body Statement
    public Statement Body;
}

/**
* For-Each Statement
*/
final class ForEachStmt : Statement
{
	mixin KindMixin!(NodeKind.ForEachStmt);
    //mixin VisitorMixin;
    
    //public VarDecl Var;

    public Expression List;

    /// Body Statement
    public Statement Body;
}

/**
* While Statement
* Do-While Statement
*/
final class WhileStmt : Statement
{
	mixin KindMixin!(NodeKind.WhileStmt);
    //mixin VisitorMixin;
    
    /// Post test condition, While or DoWhile
    bool PostCondition = false;

    ///Loop Condition
    public Expression Condition;

    /// Body Statement
    public Statement Body;
}


/**
* 'continue' Statement
*/
final class ContinueStmt : Statement
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    //target statement

    //mixin(IsKind("ContinueStmt"));

    //support something like "continue if x > 3;"
    //Expression condition;
}

/**
* 'break' Statement
*/
final class BreakStmt : Statement
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    //target statement
    //mixin(IsKind("BreakStmt"));

    //support something like "break if x > 3;"
    //Expression condition;
}

//Try Catch Finally Throw

final class ThrowStmt : Statement
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    //Expression
    //mixin(IsKind("ThrowStmt"));
}

final class TryStmt : Statement
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    //mixin(IsKind("TryStmt"));
}

final class CatchStmt : Statement
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    //mixin(IsKind("CatchStmt"));
}

final class FinallyStmt : Statement
{
	// Mixin for Visitor
    //mixin VisitorMixin;
    
    //mixin(IsKind("FinallyStmt"));
}
