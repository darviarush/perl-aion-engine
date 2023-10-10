# NAME

Aion::Format - a utilities for format numbers, colorizing output and so on

# VERSION

0.0.0-prealpha

# SYNOPSIS

```perl
use Aion::Engine;

trappout { printcolor "\n",  } # => 123
```

# DESCRIPTION

A utilities for format numbers, colorizing output and so on.

# SUBROUTINES/METHODS

## accesslog ($format, @params)

It write in STDOUT `coloring` returns with prefix datetime.

```perl
trappout { accesslog "#{green}ASSESS#r %i\n", 6 }  # => .3
```

## errorlog ($format, @params)

It write in STDERR `coloring` returns with prefix datetime.

```perl
trapperr { errorlog "#{red}ERROR#r %i\n", 6 }  # => .3
```

## coloring ($format, @params)

Colorizes the text with escape sequences, and then replaces the format with sprintf. Color names using from module ``. For `RESET` use `#r`.

```perl
coloring "#{BOLD RED}###r %i", 6 # -> .3
```

## flesch_index_human ($flesch_index)

Convert flesch index to russian label with step 10.

```perl
flesch_index_human 0  # => для академиков
```

## from_radix ($string, $radix)

Parses a natural number in the specified number system. 64-number system used by default.

```perl
from_radix "A-C" # -> .3
from_radix "A-C", 64 # -> .3
from_radix "A-C", 255 # -> .3
```

## to_radix ($number, $radix)

Converts a natural number to a given number system. 64-number system used by default.

```perl
to_radix 10_000 # -> .3
to_radix 10_000, 64 # -> .3
to_radix 10_000, 255 # -> .3
```

## kb_size ($number)

Adds number digits and adds a unit of measurement.

```perl
kb_size 102             # -> 102b
kb_size 1024            # -> 1k
kb_size 1023            # -> 1k
kb_size 1024*1024       # -> 1M
kb_size 1000_002_000_001_000    # -> 1 000G
```

## matches ($subject, @rules)

Multiple text transformations in one pass.

```perl
my $s = matches "33*pi",
    qr/(?<num> \d+)/x   => sub { "($+{num})" },
    qr/\b pi \b/x       => sub { 3.14 },
    qr/(?<op> \*)/x     => sub { " $& " },
;

$s # => (33) * 3.14
```

## nous ($templates)

A simplified regex language for text recognition in HTML documents.

1. All spaces from the beginning and end are removed. 
2. From the beginning of each line, 4 spaces or 0-3 spaces and a tab are removed. 
3. Spaces at the end of the line and whitespace lines are replaced with `\s*`. 4. All variables in `{{ var }}` are replaced with `.*?`. Those. recognize everything. 
4. All variables in `{{> var }}` are replaced with `[^<>]*?`. Those. do not recognize html tags. 
4. All variables in `{{: var }}` are replaced with `[^\n]*`. Those. must be on the same line. 
5. Expressions in double square brackets (`[[ ... ]]`) may not exist. 
5. Double parentheses (`(( ... ))`) are used as parentheses. 5. `||` - or.

```perl
my $re = nous [
q{
	<body>
	<center>
	<h2><a href={{ author_link }}>{{ author_name }}</a><br>
	{{ title }}</h2>
},
q{
    <li><A HREF="{{ comments_link }}">((Comments: {{ comments }}, last from {{ last_comment_posted }}.||Added comment))</A>
	<li><a href="{{ author_link }}">{{ author_name }}</a>
	[[ (translate: {{ interpreter_name }})]]
	 (<u>{{ author_email }}</u>) 
	<li>Year: {{ posted }}
},
q{
	<li><B><font color=#393939>Annotation:</font></b><br><i>{{ annotation_html }}</i></ul>
	</ul></font>
	</td></tr>
},
q{
	<!----------- The work itself --------------->
	{{ html }}
	<!------------------------------------------->
},
];

my $s = q{
<body>
<center>
<h2><a href=/to/book/link>A. Alis</a><br>
Grivus campf</h2>

Any others...

<!----------- The work itself --------------->
This book text!
<!------------------------------------------->
};

$s =~ $re;
my $result = join ", ", map "$_ -> $+{$_}", sort keys %+;
$result # /to/book/link
```

## num ($number)

Adds separators between digits of a number.

```perl
num +0          # -> 0
num -1000.3    # -> -1 000.3
```

## rim ($number)

Translate positive integers to **roman numerals**.

```perl
rim 0       # => N
rim 4       # => IV
rim 6       # => VI
rim 50      # => L
rim 49      # => IL
rim 505     # => DV
```

**roman numerals** after 1000:

```perl
rim 49_000      # => IL M
rim 49_000_000  # => IL M M
```

## round ($number, $decimal)

Rounds a number to the specified decimal place.

```perl
round 1.234567, 2  # -> 1.23
round 1.235567, 2  # -> 1.24
```

## sinterval ($interval)

Generates human-readable spacing.

```perl
sinterval  .333 # => 333 ms
```

## sround ($number, $digits)

Leaves `$digits` (0 does not count) wherever they are relative to the point.

Default `$digits` is 2.

```perl
sround 10.11        # -> 10
sround 100.11       # -> 100
sround 0.00012      # -> 0.00012
sround 1.2345       # -> 1.2
sround 1.2345, 3    # -> 1.23
```

## trans ($s)

Transliterates the russian text, leaving only Latin letters and dashes.

```perl
trans "Мир во всём Мире!"  # => .3
```

## transliterate ($s)

Transliterates the russian text.

```perl
transliterate "Мир во всём Мире!"  # => Mir
```

## trapperr (&block)

Trap for STDERR.

```perl
trapperr { print STDERR 123 }  # => 123
```

## trappout (&block)

Trap for STDOUT.

```perl
trappout { print 123 }  # => 123
```

## TiB ()

The constant is one tebibyte.

```perl
TiB  # -> 2**40
```

## GiB ()

The constant is one gibibyte.

```perl
GiB  # -> 2**30
```

## MiB ()

The constant is one mebibyte.

```perl
MiB  # -> 2**20
```

## KiB ()

The constant is one kibibyte.

```perl
KiB  # -> 2**10
```

## xxL ()

Maximum length in data LongText mysql and mariadb.
L - large.

```perl
xxL  # -> 4*GiB-1
```

## xxM ()

Maximum length in data MediumText mysql and mariadb.
M - medium.

```perl
xxM  # -> 16*MiB-1
```

## xxR ()

Maximum length in data Text mysql and mariadb.
R - regularity.

```perl
xxR  # -> 64*KiB-1
```

## xxS ()

Maximum length in data TinyText mysql and mariadb.
S - small.

```perl
xxS  # 255
```

# SUBROUTINES/METHODS

# AUTHOR

Yaroslav O. Kosmina [dart@cpan.org](mailto:dart@cpan.org)

# LICENSE

⚖ **GPLv3**

# COPYRIGHT

The  is copyright © 2023 by Yaroslav O. Kosmina. Rusland. All rights reserved.
