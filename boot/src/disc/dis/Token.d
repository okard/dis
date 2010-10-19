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
module disc.dis.Token;

/*
Change structure as soon as bug 4423 is fixed
http://d.puremagic.com/issues/show_bug.cgi?id=4423
*/

/**
* Token
*/
enum Token : ubyte
{
    None,
    EOF,
    //Values & Identifier
    Identifier,
    String,

    //Symbols
    EOL,            // End of Line
    Semicolon,      // ;
    Comma,          // ,
    Dot,            // .
    Colon,          // :
    ROBracket,      // ( - Round Open Bracket
    RCBracket,      // ) - Round Close Bracket
    AOBracket,      // [ - Angled Open Bracket
    ACBracket,      // ] - Angled Close Bracket
    COBracket,      // { - Cambered Open Bracket
    CCBracket,      // } - Cambered Close Bracket

    Mul,            // *

    //Keywords
    KwPackage,
    KwDef 
}


/**
* Token to String
*/
string toString(Token tok)
{
    switch(tok)
    {
    case Token.None:        return "None";
    case Token.Identifier:  return "Identifier";
    case Token.String:      return "String";
    case Token.EOL:         return "End of Line";
    case Token.Semicolon:   return ";";
    case Token.Comma:       return ",";
    case Token.Dot:         return ".";
    case Token.Colon:       return ":";
    case Token.ROBracket:   return "(";
    case Token.RCBracket:   return ")";
    case Token.AOBracket:   return "[";
    case Token.ACBracket:   return "]";
    case Token.COBracket:   return "{";
    case Token.CCBracket:   return "}";
    case Token.Mul:         return "*";
    case Token.KwPackage:   return "package";
    case Token.KwDef:       return "def";
    default: return "no token description";
    }
}