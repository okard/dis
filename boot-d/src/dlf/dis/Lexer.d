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
module dlf.dis.Lexer;

import dlf.basic.Location;
import dlf.basic.Source;
import dlf.basic.ArrayBuffer;
import dlf.dis.Token;

//phobos imports
//import std.container;
import std.conv;

//debug
import std.stdio;

/**
* Dis Lexer
*/
class Lexer
{
    //Keyword to Token
    private static TokenType[char[]] mKeywords;
    //Token List
    private ArrayBuffer!(Token) mTokList;
    ///The current source to lex
    private Source mSrc;
    ///Current Token
    private Token mTok;
    ///Current char
    private char mC;

    /**
    * Ctor
    */
    public this()
    {
        mTokList = ArrayBuffer!(Token)(25);
    }

    /**
    * Get a valid character
    */
    private bool nextValidChar(ref char c)
    {
        do
        {
            if(mSrc.isEof())
                return false;

            c = mSrc.getChar();
        }
        while(c == ' ' || c == '\t') //Ignore Space and tab at the moment, to improve

        return true;
    }

    /**
    * Is Alpha
    */
    private static bool isAlpha(char c)
    {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
    }

    /**
    * Is Numeric
    */
    private static bool isNumeric(char c)
    {
        return (c >= '0' && c <= '9');
    }

    /**
    * For double Lookups
    * e.g. +=
    */
    private TokenType lookFor(char c, TokenType a, TokenType b) 
    {
        //if c match peekchar return b if not return a
        if(mSrc.peekChar(1) == c)
        {
            mC = mSrc.getChar();
            return b;
        }
        else
            return a;
    }

    /**
    * Scan Identifier
    */
    private void scanIdentifier(ref Token te)
    {
        char[] ident;
        ident ~= mC;

        while(isAlpha(mSrc.peekChar(1)) || isNumeric(mSrc.peekChar(1)))
        {
            mC = mSrc.getChar();
            ident ~= mC;
        }

        te.Value = cast(string)ident;
    }

    /**
    * Scan String
    */
    private void scanString(ref Token te)
    {
        te.Type = TokenType.String;
        
        char[] str;

        //TODO String "..." can't be defined over multiple lines?
        //TODO Escape Characters "\n"
        do
        { 
            mC = mSrc.getChar();
            
            //escape chars
            if(mC == '\\')
            {
                mC = mSrc.getChar();
                switch(mC)
                {
                case 'n': str ~= '\n'; break;
                case 'r': str ~= '\r'; break;
                case 't': str ~= '\t'; break;
                default:
                }
                continue;
            }
        
            if(mC != '"')
                str ~= mC;
        }
        while(mC != '"');
        
        te.Value = cast(string)str;
    }

    /**
    * Scan Char
    */
    private void scanChar(ref Token te)
    {
        te.Type = TokenType.Char;

        mC = mSrc.getChar();
        if(mC == '\\')
        {
        }

        te.Value = to!string(mC);
        
        mC = mSrc.getChar();
        if(mC != '\'')
        {
            //error
        }
    }

    /**
    * Read Numbers
    * TODO Improve
    */
    private void scanNumber(ref Token te)
    {
        //TODO scanNumbers
        te.Type = TokenType.Integer;
        //Integer, Float, Double

        te.Value ~= mC;

        while(isNumeric(mSrc.peekChar(1)) || mSrc.peekChar(1) == '.')
        {
            mC = mSrc.getChar();
            if(mC == '.')
                te.Type = TokenType.Float;
            te.Value ~= mC;
        }
    }


    /**
    * Scan Comments
    * TODO Scan Comment Docs
    */
    private void scanComments(ref Token te)
    {
        te.Type = TokenType.Comment;
        char c = mSrc.getChar();

        //line comment
        if(c == '/')
            while(mSrc.peekChar(1) != '\n') mSrc.getChar();
        
        //block comment
        if(c == '*')
        {
            //readUntil "*/"
            while(true)
            {
                mSrc.getChar();
                if(mSrc.peekChar(1) == '*' && mSrc.peekChar(2) == '/')
                {
                    mSrc.getChar(); mSrc.getChar();
                    break;
                }
            }
        }

    }

    /**
    * Get Next Entry
    */
    private Token nextToken()
    {
        auto tok = Token();

        if(mSrc is null)
            throw new Exception("No Source File");
        
        //look for file end and no valid chars
        if(mSrc.isEof() || !nextValidChar(mC))
        {
            tok.Type = TokenType.EOF;
            return tok;
        }   

        //writeln(mC == '\n' ? 'n' : mC);

        tok.Loc = mSrc.Loc;

        //Check for special characters
        switch(mC)
        {
        case '\n': tok.Type = TokenType.EOL; break;
        case ';':  tok.Type = TokenType.Semicolon; break;
        case ',':  tok.Type = TokenType.Comma; break;
        case '.':  tok.Type = TokenType.Dot; break;
        case ':':  tok.Type = TokenType.Colon; break;
        case '(':  tok.Type = TokenType.ROBracket; break;
        case ')':  tok.Type = TokenType.RCBracket; break;
        case '[':  tok.Type = TokenType.AOBracket; break;
        case ']':  tok.Type = TokenType.ACBracket; break;
        case '{':  tok.Type = TokenType.COBracket; break;
        case '}':  tok.Type = TokenType.CCBracket; break;
        case '@':  tok.Type = TokenType.Annotation; break;
        case '!':  tok.Type = lookFor('=', TokenType.Not, TokenType.NotEqual); break;
        case '+':  tok.Type = lookFor('=', TokenType.Add, TokenType.AddAssign); break;
        case '-':  tok.Type = lookFor('=', TokenType.Sub, TokenType.SubAssign); break;
        case '=':  tok.Type = lookFor('=', TokenType.Assign, TokenType.Equal); break;
        case '*':  tok.Type = lookFor('=', TokenType.Mul, TokenType.MulAssign); break;
        //Can be Comments
        case '/':  if(mSrc.peekChar(1) == '/' || mSrc.peekChar(1) == '*') 
                        scanComments(tok);
                   else
                        tok.Type = TokenType.Div;
                   break;

        case '&': tok.Type = TokenType.And; break;
        case '|': tok.Type = TokenType.Or; break;

        case '"':  scanString(tok); break;
        case '\'': scanChar(tok); break; 
        default:
            tok.Type = TokenType.None;
        }

        //Handle Identifiers and Keywords
        if(tok.Type == TokenType.None && isAlpha(mC))
        {
            scanIdentifier(tok);
            //keyword or identifier
            tok.Type = mKeywords.get(tok.Value, TokenType.Identifier);
        }

        //Handle Numbers
        if(tok.Type == TokenType.None && isNumeric(mC))
        {
            scanNumber(tok);
        }
        
        return tok;
    }

    /**
    * Get next Token
    */
    Token getToken()
    {
        if(!mTokList.empty())
        {
            mTok = mTokList.popFront();
            //mTokList.removeFront();
        }
        else
            mTok = nextToken();
        
        return mTok;
    }

    /**
    * Take a peek for next Token 
    */
    Token peekToken(ushort n)
    {
        if(mTokList.length() >= n)
            return mTokList[n-1];
        
        Token tok;
        while(mTokList.length() < n)
            tok =  mTokList.addAfter(nextToken());

        return tok;
    }
    
    /**
    * The current Token
    */
    @property
    Token CurrentToken()
    {
       return mTok;
    }
    
    /**
    * Current Value for Token
    */
    @property
    string CurrentValue()
    {
        return mTok.Value;
    }

    /**
    * Set current Source
    */
    @property
    void Src(Source src)
    {
        mSrc = src;
    }
    
    /**
    * Get current Source
    */
    @property
    Source Src()
    {
        return mSrc;
    }  

    /**
    * Static Constructor
    * Initialize Keywords
    */
    static this()
    {
        mKeywords["def"] = TokenType.KwDef;
        mKeywords["package"] = TokenType.KwPackage;
        mKeywords["class"] = TokenType.KwClass;
        mKeywords["var"] = TokenType.KwVar;
        mKeywords["val"] = TokenType.KwVal;
        mKeywords["trait"] = TokenType.KwTrait;
        mKeywords["type"] = TokenType.KwType;
        mKeywords["import"] = TokenType.KwImport;
        mKeywords["if"] = TokenType.KwIf;
        mKeywords["else"] = TokenType.KwElse;
        mKeywords["switch"] = TokenType.KwSwitch;
        mKeywords["case"] = TokenType.KwCase;
        mKeywords["for"] = TokenType.KwFor;
        mKeywords["while"] = TokenType.KwWhile;
        mKeywords["do"] = TokenType.KwDo;
        mKeywords["this"] = TokenType.KwThis;
        mKeywords["return"] = TokenType.KwReturn;
        mKeywords["null"] = TokenType.KwNull;
        mKeywords["true"] = TokenType.KwTrue;
        mKeywords["false"] = TokenType.KwFalse;
    }
} 

// UnitTests ==================================================================

unittest
{
    //lexer unittest
    import std.stdio;
    
    writeln("[TEST] Lexer Tests passed ");
}
