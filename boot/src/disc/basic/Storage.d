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
module disc.basic.Storage;


/**
* Stupid Named Storage Class
* Single Assigned
*/
struct Storage(T)
{
    /// Data Storage
    private T data[string];

    /**
    * Get Data
    */
    @property
    T opDispatch(string s)()
    {
        static if(is(T == class) || is(T == interface))
            return data.get(s, null);
        else
            return data[s];
    }
    
    /**
    * Set Data
    * only once
    */
    @property
    void opDispatch(string s)(T value)
    {
        if(s !in data)
            data[s] = value;
        else
            throw new Exception("data already assigned");
        
    }
} 


unittest
{
    Storage!(int) store;

    store.foo(5);
    assert(store.foo() == 5);
}