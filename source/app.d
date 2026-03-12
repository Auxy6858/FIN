import std.stdio;
import std.file;
import std.conv : text;
import lexer;

int main(string[] args)
{
	bool isFileError = false;
	if(args.length < 2)
	{
		stderr.writeln("FIN: error: No files provided");
		writeln("FIN: Usage: fin <file>");
		return(1);
	}

	if(!(std.file.exists(args[1]) && std.file.isFile(args[1])))
	{
		stderr.writeln(i"FIN: $(makeRed("error")): no such file or directory: '$(args[1])'");
		isFileError = true;
	}

	if(args[1][$-4..$] != ".fin")
	{
		stderr.writeln(i"FIN: $(makeRed("error")): unknown file type in '$(args[1])'");
		isFileError = true;
	}

	if(isFileError)
	{
		return(1);
	}

	string source = std.file.readText(args[1]);
	Lexer lexer = Lexer(source);
	lexer.popFront();

	while (!lexer.isEmpty())
	{
		Token tok = lexer.front();
		writeln(i"$(tok.kind)('$(makeRed(tok.tokenValue))')");
		lexer.popFront();
	}
	return(0);


}

string makeRed(string text)
{
	return "\033[1m\033[31m" ~ text ~ "\033[0m";
}