module parser.parser;

import parser.lexer;
import ast;

enum BindingPower
{
    Lowest = 0,
    Assignment = 1,
    Conditional = 2,
    Sum = 3,
    Product = 4,
    Prefix = 5,
    Call = 6
}

int getBindingPower(TokenKind kind)
{
    switch(kind)
    {
        case TokenKind.Equals:
        case TokenKind.PlusEquals:
        case TokenKind.MinusEquals:
            return BindingPower.Assignment;
        case TokenKind.EqualTo:
        case TokenKind.NotEqualTo:
        case TokenKind.LessThan:
            return BindingPower.Conditional;
        case TokenKind.Plus:
        case TokenKind.Minus:
            return BindingPower.Sum;
        case TokenKind.Asterisk:
        case TokenKind.Slash:
            return BindingPower.Product;
        case TokenKind.OpenParen:
        case TokenKind.OpenBracket:
        case TokenKind.Dot:
            return BindingPower.Call;
        default:
            return BindingPower.Lowest;
    }
}

struct Parser
{
    Lexer* lexer;
    Token currentToken;
    Token peekToken;
    CompilationError[] compilationErrors;

    this(Lexer* lexer)
    {
        this.lexer = lexer;
        nextToken();
        nextToken();
    }

    void nextToken()
    {
        currentToken = peekToken;
        peekToken = lexer.nextToken();
    }

    void addCompilationError(string error)
    {
        compilationErrors ~= CompilationError();
    }
}

struct CompilationError 
{
    size_t line;
    size_t column;
    string errorMessage;
}

Expression parseExpression(int bindingPower)
{

}