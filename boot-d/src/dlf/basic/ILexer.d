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



	//----------------------------------
	// Lexer Hooking
	
    //TODO Hook on special Tokens?
    // For inline asm?
    
    //void hook(T t, ILexer lex) //at token t start using ILexer 
    //void unHook(); //back to old lexer 
    //ILexer currentLexer();
    
    //------------------------
    // Lexer Position Stuff
    
    //class LexerPosition; each lexer can class LP : LexerPosition
    //LexerPosition savePos();
    //void loadPos(LexerPosition p);
    //void loadOffset(size_t offset);
    
    //-------------------------
    //Basic Interface for Token?
    
}
