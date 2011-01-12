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
module dlf.dis.Token;

import dlf.basic.Location;

/*
Change structure as soon as bug 4423 is fixed
http://d.puremagic.com/issues/show_bug.cgi?id=4423
*/

/**
* Token
*/
enum TokenType : ubyte
{
    None,
    EOF,
    //Values/Literals & Identifier
    Identifier,
    String,
    Integer,
    Float,
    Double,

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
    Annotation,     // @

    //Binary & Math Operator
    Add,            // +
    Sub,            // -
    Mul,            // *
    Div,            // /
    Mod,            // %
    Not,            // !
    Xor,            // ^
    And,            // &
    Or,             // |
    Assign,         // =
    LambdaAssign,   // ->
    //Double Operator
    Power,          // ** (4 ** 2 == 4²)
    LAnd,           // && Logic And
    LOr,            // || Logic Or
    Equal,          // ==
    NotEqual,       // !=
    
    AddAssign,      // +=
    SubAssign,      // -=
    MulAssign,      // *=
    DivAssign,      // /=

    //Keywords
    KwPackage,
    KwDef,
    KwClass,
    KwVar,
    KwVal,
    KwTrait,
    KwType,
    KwImport,
    KwIf,
    KwElse,
    KwSwitch,
    KwCase,
    KwFor,
    KwWhile,
    KwDo,
    KwThis,

    //Comment Tokens
    Comment
}


/**
* Token to String
*/
string toString(TokenType tok)
{
    switch(tok)
    {
    case TokenType.None:        return "None";
    case TokenType.Identifier:  return "Identifier";
    case TokenType.String:      return "String";
    case TokenType.Integer:     return "Integer";
    case TokenType.Float:       return "Float";
    case TokenType.Double:      return "Double";
    case TokenType.EOL:         return "End of Line";
    case TokenType.Semicolon:   return ";";
    case TokenType.Comma:       return ",";
    case TokenType.Dot:         return ".";
    case TokenType.Colon:       return ":";
    case TokenType.ROBracket:   return "(";
    case TokenType.RCBracket:   return ")";
    case TokenType.AOBracket:   return "[";
    case TokenType.ACBracket:   return "]";
    case TokenType.COBracket:   return "{";
    case TokenType.CCBracket:   return "}";
    case TokenType.Assign:      return "=";
    case TokenType.LambdaAssign:return "->";
    case TokenType.Mul:         return "*";
    case TokenType.MulAssign:   return "*=";
    case TokenType.Annotation:  return "@";
    case TokenType.KwPackage:   return "package";
    case TokenType.KwDef:       return "def";
    case TokenType.KwClass:     return "class";
    case TokenType.KwVar:       return "var";
    case TokenType.KwVal:       return "val";
    case TokenType.KwTrait:     return "trait";
    case TokenType.KwType:      return "type";
    case TokenType.KwImport:    return "import";
    case TokenType.KwIf:        return "if";
    case TokenType.KwElse:      return "else";
    case TokenType.KwSwitch:    return "switch";
    case TokenType.KwCase:      return "case";
    case TokenType.KwFor:       return "for";
    case TokenType.KwWhile:     return "while";
    case TokenType.KwDo:        return "do";
    case TokenType.KwThis:      return "this";
    case TokenType.Comment:     return "<comment>";
    default: return "no token description";
    }
}

///Structure for TokenList
public struct Token
{
    public string toString()
    {
        return dlf.dis.Token.toString(type);
    }

    TokenType type;
    Location loc;
    string value;
}