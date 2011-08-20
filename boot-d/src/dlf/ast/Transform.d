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
    //if already extended add to bottom extended nodes
    if(n.Extend !is null)
            e.Parent = n.Extend;

    n.Extend = e;
}


/*
* Helper to make possible foreach over extension nodes
* TODO Generate lightweight iterable structure?
* TODO type filter template
* TODO parameter unique to generate errors if multiple instances of one type exist
*/
public Node[] extensions(Node n)
{
    if(n.Extend is null)
        return null;

    Node[] list;
    do
    {
        list ~= n.Extend;
        n = n.Extend;
    }
    while(n.Extend !is null);

    return list;
}
