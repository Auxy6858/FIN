module parser.lexer;

import std.ascii : isAlpha, isAlphaNum, isDigit, isWhite;
import std.stdio;

enum TokenKind
{
    // Literals
    NumericLiteral,
    StringLiteral,
    BooleanLiteral,
    FloatLiteral,
    NullLiteral,

    // Operators
    Plus,
    Minus,
    Asterisk,
    Slash,
    BitWiseAnd,
    BitWiseOr,
    BinaryShiftRight,
    BinaryShiftLeft,
    IncrementVariable,
    DecrementVariable,
    PlusEquals, // +=
    MinusEquals, // -=
    MultiplyEquals, // *=
    DivideEquals, // /=
    ModEquals,
    BinaryShiftLeftEquals, // <<=
    BinaryShiftRightEquals,
    // Comparators
    LessThan,
    GreaterThan,
    LessThanOrEqual,
    GreaterThanOrEqual,
    EqualTo, // ==
    NotEqualTo,
    // Punctuation
    OpenBrace, // {}
    CloseBrace,
    OpenParen, // ()
    CloseParen,
    OpenBracket, // []
    CloseBracket,
    Comma,
    Dot,
    Colon,
    // Keywords
    IfKeyword,
    ElseKeyword,
    ForKeyword,
    WhileKeyword,
    ConstKeyword,
    SelfKeyword,
    ConstructorKeyword,
    ClassKeyword,
    ReturnKeyword,
    // Types
    IntType,
    StringType,
    BooleanType,
    VoidType,
    FloatType,

    // Misc
    Newline,
    Equals,
    EOF,
    Identifier
}

struct Token
{
    TokenKind kind;
    string tokenValue;
    size_t line;
    size_t column;
}

struct Lexer
{
    string source;
    size_t currentPos = 0;
    Token currentToken;
    size_t currentLine = 1;
    size_t currentColumn = 1;
    size_t parenthesisDepth = 0;
    size_t bracketDepth = 0;
    size_t braceDepth = 0;

    private void incrementCurrentLine()
    {
        currentLine++;
        currentColumn = 1;
    }

    private char peek() const 
    {
        if(currentPos >= source.length) 
        {
            return '\0';
        }
        return source[currentPos];
    }

    // I've used a buffer of one rather than two, it seems to do the job for now. Hopefully this doesn't come back to bite me later.
    private char peekAhead()
    {
        if(currentPos + 1 >= source.length)
        {
            return '\0';       
        }
        return source[currentPos + 1];
    }

    private char advance()
    {
        char currentChar = source[currentPos++];
        if(currentChar == '\n')
        {
            incrementCurrentLine();
        } else {
            currentColumn++;
        }
        return currentChar;
    }

    private void skipWhitespace()
    {
        while (currentPos < source.length && peek() != '\n' && isWhite(peek()))
            advance();
    }

    private void skipComment()
    {
        while (currentPos < source.length && peek() != '\n')
            advance();
    }

    private Token makeToken(TokenKind kind, string value)
    {
        return Token(kind, value, currentLine, currentColumn);
    }

    this(string input)
    {
        source = input;
    }

    bool isEmpty() const => currentToken.kind == TokenKind.EOF;
    Token front() const => currentToken;

    void popFront()
    {
        currentToken = nextToken();
    }

    Token nextToken()
    {
        skipWhitespace();

        if(currentPos >= source.length)
        {
            return makeToken(TokenKind.EOF, "EOF");
        }
        
        char currentChar = advance();

        switch (currentChar)
        {
            case '\n':
                if(parenthesisDepth + braceDepth + bracketDepth > 0 || isContinuationToken(currentToken.kind))
                    return nextToken();
                return makeToken(TokenKind.Newline, "\\n");

            case '"':   return lexString();

            case '+':
                if(peek() == '+') { advance(); return makeToken(TokenKind.IncrementVariable, "++"); }
                if(peek() == '=') {advance(); return makeToken(TokenKind.PlusEquals, "+="); }
                return makeToken(TokenKind.Plus, "+");
            case '-':
                if(peek() == '-') { advance(); return makeToken(TokenKind.DecrementVariable, "--"); }
                return makeToken(TokenKind.Minus, "-");
            case '*':   return makeToken(TokenKind.Asterisk, "*");
            case '/':
                if(peek() == '/') { skipComment(); return nextToken(); }
                if(peek() == '=') {advance(); return makeToken(TokenKind.DivideEquals, "/=");}
                return makeToken(TokenKind.Slash, "/");

            case '=':
                if(peek() == '=') { advance(); return makeToken(TokenKind.EqualTo, "=="); }
                return makeToken(TokenKind.Equals, "=");
            case '!':
                if(peek() == '=') { advance(); return makeToken(TokenKind.NotEqualTo, "!="); }
                return makeToken(TokenKind.EOF, ""); // bare ! not yet defined
            case '<':
                if(peek() == '=') { advance(); return makeToken(TokenKind.LessThanOrEqual, "<="); }
                return makeToken(TokenKind.LessThan, "<");
            case '>':
                if(peek() == '=') { advance(); return makeToken(TokenKind.GreaterThanOrEqual, ">="); }
                return makeToken(TokenKind.GreaterThan, ">");
            case '&':   return makeToken(TokenKind.BitWiseAnd, "&");
            case '|':   return makeToken(TokenKind.BitWiseOr, "|");

            case '{':   braceDepth++;       return makeToken(TokenKind.OpenBrace, "{");
            case '}':   braceDepth--;       return makeToken(TokenKind.CloseBrace, "}");
            case '(':   parenthesisDepth++; return makeToken(TokenKind.OpenParen, "(");
            case ')':   parenthesisDepth--; return makeToken(TokenKind.CloseParen, ")");
            case '[':   bracketDepth++;     return makeToken(TokenKind.OpenBracket, "[");
            case ']':   bracketDepth--;     return makeToken(TokenKind.CloseBracket, "]");
            case ',':   return makeToken(TokenKind.Comma, ",");
            case '.':   return makeToken(TokenKind.Dot, ".");
            case ':':   return makeToken(TokenKind.Colon, ":");

            default:
                if (isAlpha(currentChar) || currentChar == '_')
                    return lexIdentifierOrKeyword(currentChar);
                if (isDigit(currentChar))
                    return lexNumber(currentChar);
                // unknown character — skip it
                return nextToken();
        }
    }

    private Token lexString()
    {
        string value;
        while(currentPos < source.length && peek() != '"')
        {
            value ~= advance();
        }
        advance();
        return makeToken(TokenKind.StringLiteral, value);
    }

    private Token lexNumber(char first)
    {
        bool isFloat = false;
        string value;
        value ~= first;
        while(currentPos < source.length && (isDigit(peek()) || peek() == '.'))
        {
            if(peek() == '.')
            {
                isFloat = true;
            }
            value ~= advance();
        }
        return makeToken(isFloat ? TokenKind.FloatLiteral : TokenKind.NumericLiteral, value);
    }

    private Token lexIdentifierOrKeyword(char first)
    {
        string value;
        value ~= first;
        while (currentPos < source.length && (isAlphaNum(peek()) || peek() == '_'))
            value ~= advance();

        switch (value)
        {
            case "if":          return makeToken(TokenKind.IfKeyword, value);
            case "else":        return makeToken(TokenKind.ElseKeyword, value);
            case "for":         return makeToken(TokenKind.ForKeyword, value);
            case "while":       return makeToken(TokenKind.WhileKeyword, value);
            case "const":       return makeToken(TokenKind.ConstKeyword, value);
            case "self":        return makeToken(TokenKind.SelfKeyword, value);
            case "constructor": return makeToken(TokenKind.ConstructorKeyword, value);
            case "class":       return makeToken(TokenKind.ClassKeyword, value);
            case "return":      return makeToken(TokenKind.ReturnKeyword, value);
            case "true":        return makeToken(TokenKind.BooleanLiteral, value);
            case "false":       return makeToken(TokenKind.BooleanLiteral, value);
            case "null":        return makeToken(TokenKind.NullLiteral, value);
            case "int":         return makeToken(TokenKind.IntType, value);
            case "float":       return makeToken(TokenKind.FloatType, value);
            case "string":      return makeToken(TokenKind.StringType, value);
            case "bool":        return makeToken(TokenKind.BooleanType, value);
            case "void":        return makeToken(TokenKind.VoidType, value);
            default:            return makeToken(TokenKind.Identifier, value);
        }
    }

    private bool isContinuationToken(TokenKind kind)
    {
        switch (kind)
        {
            case TokenKind.Plus:
            case TokenKind.Minus:
            case TokenKind.Asterisk:
            case TokenKind.Slash:
            case TokenKind.EqualTo:
            case TokenKind.NotEqualTo:
            case TokenKind.LessThan:
            case TokenKind.GreaterThan:
            case TokenKind.LessThanOrEqual:
            case TokenKind.GreaterThanOrEqual:
            case TokenKind.BitWiseAnd:
            case TokenKind.BitWiseOr:
            case TokenKind.Comma:
            case TokenKind.Equals:
                return true;
            default:
                return false;
        }
    }  
}