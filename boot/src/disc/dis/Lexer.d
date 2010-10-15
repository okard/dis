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

//phobos imports
import std.container;

//debug
import std.stdio;

/**
* Represents a Value
*/
struct Value
{
    public enum Type { None, String, Identifier, Double, Float, Integer, UInteger }


    //Type
    Type ValueType;

    union
    {
        char[] String;
        char[] Identifier;
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
    ///Structure for TokenList
    public struct TokenEntry
    {
        public TokenEntry assign(Token tok, Value v)
        {
            this.tok = tok;
            this.val = v;
            hasValue = true;
            return this;
        }

        public TokenEntry assign(Token tok)
        {
            this.tok = tok;
            //this.val = null;
            hasValue = false;
            return this;
        }

        Token tok;
        Value val;
        bool hasValue;
    }

    //Token List
    private SList!(TokenEntry) mTokList;
    ///The current source to lex
    private Source mSrc;
    ///Current Token
    private TokenEntry mTok;
    ///Current char
    private char mC;

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
    private bool isAlpha(char c)
    {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
    }

    /**
    * Scan Identifier
    */
    private void scanIdentifier()
    {
        char[] ident;
        ident ~= mC;

        while(isAlpha(mSrc.peekChar(1)))
        {
            mC = mSrc.getChar();
            ident ~= mC;
        }

        mTok.val = Value(Value.Type.Identifier, ident);
    }

    /**
    * Scan String
    */
    private void scanString()
    {
        mTok.assign(Token.String);
        
        char[] str;

        do
        { 
            mC = mSrc.getChar();
            if(mC != '"')
                str ~= mC;
        }
        while(mC != '"');
        
        mTok.val = Value(Value.Type.String, str);
    }

    /**
    * Get next Token
    */
    TokenEntry getToken()
    {
        if(mSrc is null)
            throw new Exception("No Source File");
        
        //look for file end and no valid chars
        if(mSrc.isEof() || !nextValidChar(mC))
        {
            mTok.assign(Token.EOF);
            return mTok;
        }   

        //writeln(mC == '\n' ? 'n' : mC);

        //Check for special characters
        switch(mC)
        {
        case '\n': mTok.assign(Token.EOL); break;
        case ';':  mTok.assign(Token.Semicolon); break;
        case ',':  mTok.assign(Token.Comma); break;
        case '.':  mTok.assign(Token.Dot); break;
        case ':':  mTok.assign(Token.Colon); break;
        case '(':  mTok.assign(Token.ROBracket); break;
        case ')':  mTok.assign(Token.RCBracket); break;
        case '[':  mTok.assign(Token.AOBracket); break;
        case ']':  mTok.assign(Token.ACBracket); break;
        case '{':  mTok.assign(Token.COBracket); break;
        case '}':  mTok.assign(Token.CCBracket); break;
        case '"':  scanString(); break;
        default:
            mTok.assign(Token.None);
        }

        //Handle Identifiers and Keywords
        if(mTok.tok == Token.None && isAlpha(mC))
        {
            scanIdentifier();
            mTok.assign(Token.Identifier);

            //to improve
            //Look for Keywords
            if(mTok.val.Identifier == "def")
                mTok.tok = Token.KwDef;
            if(mTok.val.Identifier == "package")
                mTok.tok = Token.KwPackage;
        }
            

        return mTok;
    }

    /**
    * Take a peek for next Token 
    */
    TokenEntry peekToken()
    {
        return TokenEntry().assign(Token.None);
    }
    
    /**
    * The current Token
    */
    TokenEntry currentToken()
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
        return mSrc;
    }  
} 
