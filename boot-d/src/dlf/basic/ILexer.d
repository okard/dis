module dlf.basic.ILexer;

import dlf.basic.Source;

/**
* Basic Lexer Interface
*/
interface ILexer(T)
{

    /**
    * Load source
    */
    void load(Source src);

    /**
    * Get next token
    */
    T nextToken();

    /**
    * Peek token n
    */
    T peekToken(ushort n);

    //TODO Hook on special Tokens?
    //void regHook(T t, ILexer lex) //at token t start using ILexer 
    //void unHook(); //back to old lexer 
    // For inline asm?

}