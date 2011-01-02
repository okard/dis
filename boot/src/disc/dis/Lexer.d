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

import disc.basic.Location;
import disc.basic.Source;
import disc.basic.ArrayBuffer;
import disc.dis.Token;

//phobos imports
//import std.container;

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
        mTokList = ArrayBuffer!(Token)(10);
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
    private bool isAlpha(char c)
    {
        return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_';
    }

    /**
    * Scan Identifier
    */
    private void scanIdentifier(ref Token te)
    {
        char[] ident;
        ident ~= mC;

        while(isAlpha(mSrc.peekChar(1)))
        {
            mC = mSrc.getChar();
            ident ~= mC;
        }

        te.value = cast(string)ident;
    }

    /**
    * Scan String
    */
    private void scanString(ref Token te)
    {
        te.type = TokenType.String;
        
        char[] str;

        do
        { 
            mC = mSrc.getChar();
            if(mC != '"')
                str ~= mC;
        }
        while(mC != '"');
        
        te.value = cast(string)str;
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
            tok.type = TokenType.EOF;
            return tok;
        }   

        //writeln(mC == '\n' ? 'n' : mC);

        tok.loc = mSrc.Loc;

        //Check for special characters
        switch(mC)
        {
        case '\n': tok.type = TokenType.EOL; break;
        case ';':  tok.type = TokenType.Semicolon; break;
        case ',':  tok.type = TokenType.Comma; break;
        case '.':  tok.type = TokenType.Dot; break;
        case ':':  tok.type = TokenType.Colon; break;
        case '(':  tok.type = TokenType.ROBracket; break;
        case ')':  tok.type = TokenType.RCBracket; break;
        case '[':  tok.type = TokenType.AOBracket; break;
        case ']':  tok.type = TokenType.ACBracket; break;
        case '{':  tok.type = TokenType.COBracket; break;
        case '}':  tok.type = TokenType.CCBracket; break;
        case '*':  tok.type = TokenType.Mul; break;
        case '"':  scanString(tok); break;
        default:
            tok.type = TokenType.None;
        }

        //Handle Identifiers and Keywords
        if(tok.type == TokenType.None && isAlpha(mC))
        {
            scanIdentifier(tok);
            tok.type = TokenType.Identifier;

            //look for keywords
            if(tok.value in mKeywords)
            {
                tok.type = mKeywords[tok.value];
            }
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
        if(mTokList.length() > n)
            return mTokList[n-1];
        
        Token tok;
        while(mTokList.length < n)
            tok =  mTokList.addAfter(nextToken());

        return tok;
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
    string currentValue()
    {
        return mTok.value;
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


    static this()
    {
        mKeywords["def"] = TokenType.KwDef;
        mKeywords["package"] = TokenType.KwPackage;
    }
} 
