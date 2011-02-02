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
module dlf.ast.Transform;

import dlf.ast.Node;
import dlf.ast.Declaration;
import dlf.ast.Statement;
import dlf.ast.Expression;
import dlf.ast.Type;


/**
* extend a Node with appending an another one
*/
public static void extend(Node n, Node e)
{
    if(n.Extend !is null)
            e.Parent = n.Extend;

    n.Extend = e;
}


/**
* Replace nodes with an another one?
*/
public void replace(Node n, Node e)
{
    //check for parent
    if(n.Parent !is null)
    {
        return;
    }

    //right handling
    switch(n.Parent.NodeType)
    {
        // Declarations =======================================================
        case Node.Type.Declaration:
            break;

        case Node.Type.Statement:
            auto stmt = n.Parent.to!Statement();

            switch(stmt.StmtType)
            {
                case Statement.Type.Expression:
                    assert(e.NodeType == Node.Type.Expression);
                    stmt.to!ExpressionStatement().Expr = cast(Expression)e;
                    break;
                default:
            }
            break;

        // Expressions ========================================================
        case Node.Type.Expression:
            auto expr = n.Parent.to!Expression();

            switch(expr.ExprType)
            {
                case Expression.Type.Binary:
                    break;
                case Expression.Type.Assign:
                    break;
                default:
            }
            break;
        default:
    }
}

