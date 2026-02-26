module lexer;

import std.ascii : isAlpha, isAlphaNum, isDigit, isWhite;
import std.stdio;

enum TokenKind
{
    EOF,
    OpenBrace,
    CloseBrace,
    OpenParen,
    CloseParen,
    NumericLiteral,
    StringLiteral,
    Newline,
    Equals,
    Plus,
    Minus,
    Asterix,
    Slash,
    LessThan,
    GreaterThan,
    LessThanOrEqual,
    GreaterThanOrEqual,
    Comma,
    IfKeyword,
    ElseKeyword,
    IntType,
    // I'm wondering if I'll do a 64 or 32 bit signed intager as default
    // decisions decisions 🤔
    StringType,
}

struct Token
{
    TokenKind kind;
    string tokenValue;
}

struct Lexer
{
    string source;
    size_t currentPos;
    Token currentToken;

    this(string input)
    {
        source = input;
        popFront();
    }

    bool empty() const => currentToken.kind == TokenKind.EOF;
    Token front() const => currentToken;

    string peekAhead(size_t peekOffset)
    {
        if(currentPos + peekOffset > source.length)
        {
            return "";
        }
        return source[currentPos .. currentPos + peekOffset + 1];
    }

    void popFront()
    {
        // Skip whitespace
        while(currentPos < source.length && source[currentPos].isWhite)
        {
            currentPos++;
        }

        // Skip comments
        if(peekAhead(1) == "//")
        {
            do { currentPos++; } while(source[currentPos != '\n']);
        }

        // Stop at the end of the source
        if(currentPos >= source.length)
        {
            currentToken = Token(TokenKind.EOF, "");
            return;
        }

        char currentChar = source[currentPos];

        if(isAlpha(currentChar))
        {
            size_t startingPos = currentPos;
            while(currentPos < source.length && isAlpha(source[currentPos]))
            {
                currentPos++;
            }

            string lexeme = source[startingPos .. currentPos];

            switch ( lexeme )
            {
                case "let":

                
                default:
                    break;
            }

        }
    }
}