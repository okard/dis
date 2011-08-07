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
    /// Statement Types
    enum Type
    {
        Block,
        Expression,
        Return
    }

    /// Statement Type
    public Type StmtType;

    /// Create new Statement
    public this()
    {
        NodeType = Node.Type.Statement;
    }

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
    ///Statements
    public Statement[] Statements;

    ///Symbol Table
    public SymbolTable SymTable;

    ///Create new BlockStatement
    this()
    {
        StmtType = Type.Block;
    }
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
        StmtType = Type.Expression;
        Expr = expr;
    }
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
        StmtType = Type.Return;
        Expr = expr;
    }
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

    /// The Block Statement
    public BlockStatement Block;
}

/**
* For-Each Statement
*/
final class ForEachStatement : Statement
{
    //public VariableDeclaration Var;
    public Expression List;
}

/**
* While Statement
* Do-While Statement
*/
final class WhileStatement : Statement
{
    
}
