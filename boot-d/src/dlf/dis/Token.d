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
enum TokenType //: ubyte//c main
{
    None,
    EOF,
    //Values/Literals & Identifier
    Identifier,
    Char,
    String,
    Integer,
    Float,
    Double,

    //Symbols
    EOL,            // End of Line
    Semicolon,      // ;
    Comma,          // ,
    Colon,          // :
    ROBracket,      // ( - Round Open Bracket
    RCBracket,      // ) - Round Close Bracket
    AOBracket,      // [ - Angled Open Bracket
    ACBracket,      // ] - Angled Close Bracket
    COBracket,      // { - Cambered Open Bracket
    CCBracket,      // } - Cambered Close Bracket
    Annotation,     // @
    Dot,            // .
    Slice,          // ..
    Vararg,         // ...

    //Binary & Math Operator
    Add,            // +
    Sub,            // -
    Mul,            // *
    Div,            // /
    Mod,            // %
    Not,            // ! Prefix Not, Postfix Tmpl Instance
    Xor,            // ^
    And,            // &
    Or,             // |
    Assign,         // =
    Concat,         // ~

    //Double Operator
    LambdaAssign,   // ->
    Power,          // ** (4 ** 2 == 4²)
    LAnd,           // && Logic And
    LOr,            // || Logic Or
    Equal,          // ==
    NotEqual,       // !=
    
    //ConcatAssign  // ~=
    AddAssign,      // +=
    SubAssign,      // -=
    MulAssign,      // *=
    DivAssign,      // /=

    //:=
    // <<
    // >> shift operators
    // <-
    // ~>
    // <~ proposol mixin operator
    //=>
    //#>
    //<#
    //+>
    //<+
    //#  <-- Singleton object? Const? static?
    //$
    //.. //DotDot Slice Expression
    //... //Vararg Token


    //Keywords
    KwPackage,      // package
    KwDef,          // def
    KwClass,        // class
    KwVar,          // var
    KwVal,          // val
    KwTrait,        // trait
    KwType,         // type
    KwImport,       // import
    KwIf,           // if
    KwElse,         // else
    KwSwitch,       // switch
    KwCase,         // case
    KwFor,          // for
    KwWhile,        // while
    KwDo,           // do
    KwBreak,        // break
    KwContinue,     // continue
    KwThis,         // this
    KwReturn,       // return
    KwNull,         // null
    KwTrue,         // true
    KwFalse,        // false

    //To think about: 
    // -op, operator overloading 
    // -obj, classes or singletons 
    // -asm inline assembler (parse as string???)
    // -dsl[linq] for embedded dsl, compiler plugins
    // -ptr for pointer types

    //Comment Tokens, DocComments
    Comment
}


/**
* Token to String
*/
string toString(TokenType tok)
{
    final switch(tok)
    {
    case TokenType.None:        return "<None>";
    case TokenType.EOF:         return "<EOF>";
    case TokenType.Identifier:  return "<Identifier>";
    case TokenType.Char:        return "<Char>";
    case TokenType.String:      return "<String>";
    case TokenType.Integer:     return "<Integer>";
    case TokenType.Float:       return "<Float>";
    case TokenType.Double:      return "<Double>";
    case TokenType.EOL:         return "<EOL>";
    case TokenType.Semicolon:   return ";";
    case TokenType.Comma:       return ",";
    case TokenType.Dot:         return ".";
    case TokenType.Slice:       return "..";
    case TokenType.Vararg:      return "...";
    case TokenType.Colon:       return ":";
    case TokenType.ROBracket:   return "(";
    case TokenType.RCBracket:   return ")";
    case TokenType.AOBracket:   return "[";
    case TokenType.ACBracket:   return "]";
    case TokenType.COBracket:   return "{";
    case TokenType.CCBracket:   return "}";
    case TokenType.Annotation:  return "@";
    // Single Operator
    case TokenType.Add:         return "+";
    case TokenType.Sub:         return "-";
    case TokenType.Mul:         return "*";
    case TokenType.Div:         return "/";
    case TokenType.Mod:         return "%";
    case TokenType.Not:         return "!";
    case TokenType.Xor:         return "^";
    case TokenType.And:         return "&";
    case TokenType.Or:          return "|";
    case TokenType.Assign:      return "=";
    case TokenType.Concat:      return "~";
    //Double Operator
    case TokenType.LambdaAssign:return "->";
    case TokenType.Power:       return "**";
    case TokenType.LAnd:        return "&&";
    case TokenType.LOr:         return "||";
    case TokenType.Equal:       return "==";
    case TokenType.NotEqual:    return "!=";
    case TokenType.AddAssign:   return "+=";
    case TokenType.SubAssign:   return "-=";
    case TokenType.MulAssign:   return "*=";
    case TokenType.DivAssign:   return "/=";
    //Keywords
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
    case TokenType.KwContinue:  return "continue";
    case TokenType.KwBreak:     return "break";
    case TokenType.KwThis:      return "this";
    case TokenType.KwReturn:    return "return";
    case TokenType.KwNull:      return "null";
    case TokenType.KwTrue:      return "true";
    case TokenType.KwFalse:     return "false";
    case TokenType.Comment:     return "<comment>";
    }
}

///Structure for TokenList
public struct Token
{
    public string toString()
    {
        return dlf.dis.Token.toString(Type);
    }

    TokenType Type;
    Location Loc;
    string Value;
}