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
module disc.dis.Lexer;

import disc.basic.Source;
import disc.dis.Token;

import std.stdio;

/**
* Represents a Value
*/
struct Value
{
    enum Type { None, String, Double, Float, Integer, UInteger }

    //Type
    Type ValueType;

    union
    {
        char[] String;
        double Double;
        float Float;
        int   Integer;
        uint  UInteger;
    }
}


/**
* Dis Lexer
*/
class Lexer
{
    struct TokenEntry
    {
        Token tok;
        Value val;
        bool hasValue;
    }

    ///The current source to lex
    private Source mSrc;
    ///Current Token
    private Token mTok;
    ///Current char
    private char mC;

    /**
    * Get a valid characeter
    */
    private bool nextValidChar(ref char c)
    {
        do
        {
            if(mSrc.isEof())
                return false;

            c = mSrc.getChar();
        }
        while(c == ' ' || c == '\t') //Ignore Space and tab at the moment, to fix

        return true;
    }

    /**
    * Is Alpha
    */
    private bool isAlpha(char c)
    {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
    }

    /**
    * Scan Identifier
    */
    private void scanIdentifier()
    {
        while(isAlpha(mSrc.peekChar(1)))
        {
            mC = mSrc.getChar();
        }
    }

    /**
    * Get next Token
    */
    Token getToken()
    {
        if(mSrc is null)
            throw new Exception("No Source File");
        

        if(mSrc.isEof() || !nextValidChar(mC))
        {
            mTok = Token.EOF;
            return mTok;
        }   

        //writeln(mC == '\n' ? 'n' : mC);

        switch(mC)
        {
        case '\n': mTok = Token.EOL; break;
        case ';':  mTok = Token.Semicolon; break;
        case ',':  mTok = Token.Comma; break;
        case '.':  mTok = Token.Dot; break;
        case ':':  mTok = Token.Colon; break;
        case '(':  mTok = Token.ROBracket; break;
        case ')':  mTok = Token.RCBracket; break;
        case '[':  mTok = Token.AOBracket; break;
        case ']':  mTok = Token.ACBracket; break;
        case '{':  mTok = Token.COBracket; break;
        case '}':  mTok = Token.CCBracket; break;
        default:
            mTok = Token.None;
        }

        if(mTok == Token.None && isAlpha(mC))
        {
            scanIdentifier();
            mTok = Token.Identifier;

            //Look for Keywords
        }
            

        return mTok;
    }

    /**
    * Take a peek for next Token 
    */
    Token peekToken()
    {
        return Token.None;
    }
    
    /**
    * The current Token
    */
    Token currentToken()
    {
       return mTok;
    }
    
    /**
    * Current Value for Token
    */
    Value currentValue()
    {
        return Value();
    }

    /**
    * Set current Source
    */
    void source(Source src)
    {
        src.reset();
        mSrc = src;
    }
    
    /**
    * Get current Source
    */
    Source source()
    {
        return null;
    }  
} 
