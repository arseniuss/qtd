/**
 *
 *  Copyright: Copyright QtD Team, 2008-2009
 *  License: <a href="http://www.boost.org/LICENSE_1_0.txt>Boost License 1.0</a>
 *
 *  Copyright QtD Team, 2008-2009
 *  Distributed under the Boost Software License, Version 1.0.
 *  (See accompanying file boost-license-1.0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
 *
 */

module qt.qtd.Str;

version (Tango)
{
    import tango.text.convert.Utf : toString;
    alias char[] string;
    alias wchar[] wstring;
}
else
{
    import std.utf : toString = toUTF8;
}

public static char** toStringzArray(char[][] args)
{
	if ( args is null )
	{
		return null;
	}
	char** argv = (new char*[args.length]).ptr;
	int argc = 0;
	foreach (char[] p; args)
	{
		argv[argc++] = cast(char*)(p.dup~'\0');
	}
	argv[argc] = null;

	return argv;
}
version(Windows)
{
    export extern(C) void _d_toUtf8(wchar* arr, uint size, string* str)
    {
        *str = toString(arr[0..size]);
    }
}
else
{
    extern(C) void _d_toUtf8(wchar* arr, uint size, string* str)
    {
        *str = toString(arr[0..size]);
    }
}

