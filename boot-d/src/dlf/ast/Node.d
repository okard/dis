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
module dlf.ast.Node;

/**
* Base Class for AST Nodes
*/
abstract class Node
{
    /// Node Types
    public enum Type
    {
        Declaration,
        Statement,
        Expression,
        DataType,
        Annotation,
        Special
    }

    /// Parent node
    public Node Parent;

    /// Node Type
    public Type NodeType;

    /// For Node Extensions in Semantic and Compiler Passes
    public Node Extend;
}