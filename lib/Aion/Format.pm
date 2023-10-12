package Aion::Format;
use 5.22.0;
no strict; no warnings; no diagnostics;
use common::sense;

our $VERSION = "0.0.0-prealpha";

require POSIX;
require Term::ANSIColor;

use Exporter qw/import/;
our @EXPORT = our @EXPORT_OK = grep {
	*{$Aion::Format::{$_}}{CODE} && !/^(_|(NaN|import)\z)/n
} keys %Aion::Format::;

use DDP {
	colored => 1,
	class => {
		expand => "all",
		inherited => "all",
		show_reftype => 1,
	},
	deparse => 1,
	show_unicode => 1,
	show_readonly => 1,
	print_escapes => 1,
	#show_refcount => 1,
	#show_memsize => 1,
	caller_info => 1,
	output => 'stdout',
	#unicode_charnames => 1,
};

#@category Ловушки

# Ловушка для STDERR
sub trapperr(&) {
	my $sub = shift;
	local *STDERR;
	open STDERR, '>:utf8', \my $f;
	$sub->();
	close STDERR;
	$f
}

# Ловушка для STDOUT
sub trappout(&) {
	my $sub = shift;
	local *STDOUT;
	open STDOUT, '>:utf8', \my $f;
	$sub->();
	close STDOUT;
	$f
}

#@category Цвет

# Колоризирует текст escape-последовательностями: coloring("#{BOLD RED}ya#{}100!#RESET"), а затем - заменяет формат sprintf-ом
sub coloring(@) {
	my $s = shift;
	$s =~ s!#\{([\w \t]*)\}|#(\w+)!
		my $x = $1 // $2;
		$x = "RESET" if $x ~~ [qw/r R/];
		Term::ANSIColor::color($x)
	!ge;
	sprintf $s, @_
}

# Печатает в STDOUT вывод coloring
sub printcolor(@) {
	print coloring @_
}

# Печатает в STDERR вывод coloring
sub warncolor(@) {
	print STDERR coloring @_
}

# Для крона: Пишет в STDOUT
sub accesslog(@) {
	print "[", POSIX::strftime("%F %T", localtime), "] ", coloring @_;
}

# Для крона: Пишет в STDIN
sub errorlog(@) {
	print STDERR "[", POSIX::strftime("%F %T", localtime), "] ", coloring @_;
}

# Проводит соответствия
#
# matches "...", qr/.../ => sub {...}, ...
#
sub matches($@) {
	my $s = shift;
	my $i = 0;
	my $re = join "\n| ", map { $i++ % 2 == 0? "(?<I$i> $_ )": () } @_;
	my $arg = \@_;
	my $fn = sub {
		for my $k (keys %+) {
			return $arg->[$k]->() if do { $k =~ /^I(\d+)\z/ and $k = $1 }
		}
	};

	$s =~ s/$re/$fn->()/gex;

	$s
}

#@category Транслитерация

# Транслитетрирует русский текст (x, w, q)
our %TRANS = qw/
	а a  и i  п p  ц c	э eh
	б b  й y  р r  ч ch   ю ju
	в v  к k  с s  ш sh   я ja
	г g  л l  т t  щ sch
	д d  м m  у u  ъ qh
	е e  н n  ф f  ы y
	ё jo о o  х kh ь q
	ж zh	   
	з z
/;
sub transliterate($) {
	my ($s) = @_;
	$s =~ s/[а-яё]/lc($&) eq $&? $TRANS{$&}: ucfirst $TRANS{lc $&}/gier;
}

# Транслитетрирует текст, оставляя только латинские буквы и тире
sub trans($) {
	my ($s) = @_;
	$s = transliterate $s;
	$s =~ s{[-\s_]+}{-}g;
	$s =~ s![^a-z-]!!gi;
	$s =~ s!^-*(.*?)-*\z!$1!;
	lc $s
}

#@category Транслитерация

# Упрощённый язык регулярок
sub nous($) {
	my ($templates) = @_;
	my $x = join "|", map {
		matches $_,
		# Срезаем все пробелы с конца:
		qr!\s*$! => sub {},
		# Срезаем все начальные строки:
		qr!^([ \t]*\n)*! => sub {},
		# С начала каждой строки 4 пробела или 0-3 пробела и табуляция:
		qr!^( {4}| {0,3}\t)!m => sub {},
		# Пробелы в конце строки и пробельные строки затем заменяем на \s*
		qr!([ \t]*\n)+! => sub { "\\s*" },
		# Заменяем все переменные {{}}:
		qr!\{\{(?<type>[>:])?\s*(?<name>[a-z_]\w*)\s*\}\}!i => sub { 
			"(?<$+{name}>" . (
				$+{type} eq ">"? "[^<>]*?": 
				$+{type} eq ":"? "[^\n]*": 
								 ".*?"
			) . ")" 
		},
		# Заменяем управляющие последовательности:
		qr!\[\[! => sub { "(" },
		qr!\]\]! => sub { ")?" },
		qr!\(\(! => sub { "(" },
		qr!\)\)! => sub { ")" },
		qr!\|\|! => sub { "|" },
		# Остальное - эскейпим:
		qr!.*?! => sub { quotemeta $& },
	} @$templates;
	
	qr/$x/xsmn
}

# формирует человекочитабельный интервал
sub sinterval($) {
	my ($interval) = @_;

	if(0 == int $interval) {
		return sprintf "%.6f mks", $interval*1000_000 if 0 == int($interval*1000_000);
		return sprintf "%.7f ms", $interval*1000 if 0 == int($interval*1000);
		return sprintf "%.8f s", $interval;
	}

	my $hours = int($interval / (60*60));
	my $minutes = int(($interval - $hours*60*60) / 60);
	my $seconds = int($interval - $hours*60*60 - $minutes*60);
	my $last = sprintf "%.3f", $interval - $hours*60*60 - $minutes*60 - $seconds;
	sprintf "%02i:%02i:%02i.%s", $hours, $minutes, $seconds, $last =~ s!^0\.!!r
}

#@category Цифры

# переводит в римскую систему счисления
# N - ноль
# Через каждую 1000 ставится пробел (разделитель разрядов)
our @RIM_CIF = (
	[ '', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX' ],
	[ '', 'X', 'XX', 'XXX', 'XL', 'L', 'LX', 'LXX', 'LXXX', 'XC' ],
	[ '', 'C', 'CC', 'CCC', 'CD', 'D', 'DC', 'DCC', 'DCCC', 'CM' ]
);
sub rim($) {
	my ($a) = @_;
	use bigint; $a+=0;
	my $s;
	for ( ; $a != 0 ; $a = int( $a / 1000 ) ) {
		my $v = $a % 1000;
		if ( $v == 0 ) {
			$s = "M $s";
		}
		else {
			my $d;
			for ( my $i = 0, $d = "" ; $v != 0 ; $v = int( $v / 10 ), $i++ ) {
				my $x = $v % 10;
				$d = $RIM_CIF[$i][$x] . $d;
			}
			$s = "$d $s";
		}
	}

	$s //= "N";
	$s =~ s/ \z//;
	$s
}

# Использованы символы из кодировки cp1251, что нужно для корректной записи в таблицы
our $CIF = join "", "0".."9", "A".."Z", "a".."z", "_-", # 64 символа для 64-ричной системы счисления
	(map chr, ord "А" .. ord "Я"), "ЁЂЃЉЊЌЋЏЎЈҐЄЇІЅ",
	(map chr, ord "а" .. ord "я"), "ёђѓљњќћџўјґєїіѕ",
	"‚„…†‡€‰‹‘’“”•–—™›¤¦§©«¬­®°±µ¶·№»",	do { no utf8; chr 0xa0 }, # небуквенные символы из cp1251
	"!\"#\$%&'()*+,./:;<=>?\@[\\]^`{|}~", # символы пунктуации ASCII
	" ", # пробел
	(map chr, 0 .. 0x1F, 0x7F), # управляющие символы ASCII
	# символ 152 (0x98) в cp1251 отсутствует.
;
# Переводит натуральное число в заданную систему счисления
sub to_radix(@) {
	use bigint;
	my ($n, $radix) = @_;
	$radix //= 64;
	die "to_radix: Слишком большая система счисления $radix. Используйте СС до " . (1 + length $CIF) if $radix > length $CIF;
	$n+=0; $radix+=0;
	my $x = "";
	for(;;) {
		my $cif_idx = $n % $radix;
		my $cif = substr $CIF, $cif_idx, 1;
		$x =~ s/^/$cif/;
		last unless $n = int($n / $radix);
	}
	return $x;
}

# Парсит натуральное число в указанной системе счисления
sub from_radix(@) {
	use bigint;
	my ($s, $radix) = @_;
	$radix //= 64;
	$radix+=0;
	die "from_radix: Слишком большая система счисления $radix. Используйте СС до " . length $CIF if $radix > length $CIF;
	my $x = 0;
	for my $ch (split "", $s) {
		$x = $x*$radix + index $CIF, $ch;
	}
	return $x;
}

# Округляет до указанного разряда числа
sub round($;$) {
	my ($x, $dec) = @_;
	$dec //= 0;
	my $prec = 10**$dec;
	int($x*$prec + 0.5) / $prec
}


#@category Меры (measure)

# добавляет разделители между разрядами числа
sub num($) {
	my ($s) = @_;

	my $sep = " "; # Неразрывный пробел
	my $dec = ".";

	($s, $sep, $dec) = @$s == 2? @$s: (@$s, $dec) if ref $s;

	my ($x, $y) = split /\./, $s;
	$y = "$dec$y" if defined $y;

	$x = reverse $x;
	$x =~ s!\d{3}!$&$sep!g;
	$x =~ s!$sep([+-]?)$!$1!;
	reverse($x) . $y;
}

# Добавляет разряды чисел и добавляет единицу измерения
sub kb_size($) {
	my ($n) = @_;
	
	return num(round($n / 1024 / 1024 / 1024)) . "G" if $n >= 1024 * 1024 * 1024;
	return num(round($n / 1024 / 1024)) . "M" if $n >= 1024 * 1024;
	return num(round($n / 1024)) . "k" if $n >= 1024;
	
	return num(round($n)) . "b";
}

# Оставляет $n цифр до и после точки: 10.11 = 10, 0.00012 = 0.00012, 1.2345 = 1.2, если $n = 2
sub sround($;$) {
	my ($number, $digits) = @_;
	require Math::BigFloat;
	my $num = Math::BigFloat->new($number);
	$digits //= 2;
	$num =~ /^-?0?(\d*)\.(0*)[1-9]/;
	return "" . round($num, $digits + length $2) if length($1) == 0;
	my $k = $digits - length $1;
	return "" . round($num, $k < 0? 0: $k);
}

# Кибибайт
sub KiB() { 2**10 }

# Мебибайт
sub MiB() { 2**20 }

# Гибибайт
sub GiB() { 2**30 }

# Тебибайт
sub TiB() { 2**40 }

# Максимум в данных TinyText Марии
sub xxS { 255 }

# Максимум в данных Text Марии
sub xxR { 64*KiB-1 }

# Максимум в данных MediumText Марии
sub xxM { 16*MiB-1 }

# Максимум в данных LongText Марии
sub xxL { 4*GiB-1 }

#@category Конверторы

# Маппинг индекса Флеша для человеков
my %FLESCH_INDEX_NAMES = (
	100 => "для младшеклассников",
	90 => "для 11 лет (уровень 5-го класса)",
	80 => "для 12 лет (6-й класс)",
	70 => "для 13 лет (7-й класс)",
	60 => "для 8-х и 9-х классов",
	50 => "для 10-х, 12-х классов",
	40 => "для студентов",
	30 => "для бакалавров",
	20 => "для магистров",
	10 => "для профессионалов",
	0 => "для академиков",
);

sub flesch_index_human($) {
	my ($flesch_index) = @_;
	$FLESCH_INDEX_NAMES{int($flesch_index / 10) * 10} // "несвязный русский текст"
}

1;

__END__

=encoding utf-8

=head1 NAME

Aion::Format - a utilities for format numbers, colorizing output and so on

=head1 VERSION

0.0.0-prealpha

=head1 SYNOPSIS

	use Aion::Format;
	
	trappout { print "123\n" } # => 123\n
	
	coloring "#red ~> #r\n" # => \e[31m ~> \e[0m\n
	trappout { printcolor "#red ~> #r\n" } # => \e[31m ~> \e[0m\n

=head1 DESCRIPTION

A utilities for format numbers, colorizing output and so on.

=head1 SUBROUTINES/METHODS

=head2 coloring ($format, @params)

Colorizes the text with escape sequences, and then replaces the format with sprintf. Color names using from module C<Term::ANSIColor>. For C<RESET> use C<#r> or C<#R>.

	coloring "#{BOLD RED}###r %i", 6 # => \e[1;31m##\e[0m 6

=head2 printcolor ($format, @params)

As C<coloring>, but it print formatted string.

=head2 warncolor ($format, @params)

As C<coloring>, but print formatted string to C<STDERR>.

=head2 accesslog ($format, @params)

It write in STDOUT C<coloring> returns with prefix datetime.

	trappout { accesslog "#{green}ACCESS#r %i\n", 6 }  # ~> \[\d{4}-\d{2}-\d{2} \d\d:\d\d:\d\d\] \e\[32mACCESS\e\[0m 6\n

=head2 errorlog ($format, @params)

It write in STDERR C<coloring> returns with prefix datetime.

	trapperr { errorlog "#{red}ERROR#r %i\n", 6 }  # => ~> \[\d{4}-\d{2}-\d{2} \d\d:\d\d:\d\d\] \e\[31mERROR\e\[0m 6\n

=head2 flesch_index_human ($flesch_index)

Convert flesch index to russian label with step 10.

	flesch_index_human -0.1  # => несвязный русский текст
	flesch_index_human 0     # => для академиков
	flesch_index_human 1     # => для академиков
	flesch_index_human 15    # => для профессионалов
	flesch_index_human 100   # => для младшеклассников
	flesch_index_human 100.1 # => несвязный русский текст

=head2 from_radix ($string, $radix)

Parses a natural number in the specified number system. 64-number system used by default.

	from_radix "A-C" # -> 45004
	from_radix "A-C", 64 # -> 45004
	from_radix "A-C", 255 # -> 666327

=head2 to_radix ($number, $radix)

Converts a natural number to a given number system. 64-number system used by default.

	to_radix 10_000 # => 2SG
	to_radix 10_000, 64 # => 2SG
	to_radix 10_000, 255 # => dt

=head2 kb_size ($number)

Adds number digits and adds a unit of measurement.

	kb_size 102             # => 102b
	kb_size 1024            # => 1k
	kb_size 1023            # => 1\x{a0}023b
	kb_size 1024*1024       # => 1M
	kb_size 1000_002_000_001_000    # => 931\x{a0}324G

=head2 matches ($subject, @rules)

Multiple text transformations in one pass.

	my $s = matches "33*pi",
	    qr/(?<num> \d+)/x   => sub { "($+{num})" },
	    qr/\b pi \b/x       => sub { 3.14 },
	    qr/(?<op> \*)/x     => sub { " $& " },
	;
	
	$s # => (33) * 3.14

=head2 nous ($templates)

A simplified regex language for text recognition in HTML documents.

=over

=item 1. All spaces from the beginning and end are removed. 

=item 2. From the beginning of each line, 4 spaces or 0-3 spaces and a tab are removed. 

=item 3. Spaces at the end of the line and whitespace lines are replaced with C<\s*>. 4. All variables in C<{{ var }}> are replaced with C<.*?>. Those. recognize everything. 

=item 4. All variables in C<< {{E<gt> var }} >> are replaced with C<< [^E<lt>E<gt>]*? >>. Those. do not recognize html tags. 

=item 5. All variables in C<{{: var }}> are replaced with C<[^\n]*>. Those. must be on the same line. 

=item 6. Expressions in double square brackets (C<[[ ... ]]>) may not exist. 

=item 7. Double parentheses (C<(( ... ))>) are used as parentheses. 5. C<||> - or.

=back

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
	my $result = {%+};
	$result # --> {author_link => "/to/book/link", author_name => "A. Alis", title => "Grivus campf"}

=head2 num ($number)

Adds separators between digits of a number.

	num +0         # => 0
	num -1000.3    # => -1 000.3

Separator by default is no-break space. Set separator and decimal point same as:

	num [1000, "#"]         		# => 1#000
	num [-1000.3003003, "_", ","]   # => -1_000,3003003

=head2 rim ($number)

Translate positive integers to B<roman numerals>.

	rim 0       # => N
	rim 4       # => IV
	rim 6       # => VI
	rim 50      # => L
	rim 49      # => XLIX
	rim 505     # => DV

B<roman numerals> after 1000:

	rim 49_000      # => XLIX M
	rim 49_000_000  # => XLIX M M
	rim 49_009_555  # => XLIX IX DLV

=head2 round ($number, $decimal)

Rounds a number to the specified decimal place.

	round 1.234567, 2  # -> 1.23
	round 1.235567, 2  # -> 1.24

=head2 sinterval ($interval)

Generates human-readable spacing.

Width of result is 12 symbols.

	sinterval  6666.6666 	# => 01:51:06.667
	sinterval  6.6666 		# => 00:00:06.667
	sinterval  .333 		# => 0.33300000 s
	sinterval  .000_33 		# => 0.3300000 ms
	sinterval  .000_000_33 	# => 0.330000 mks

=head2 sround ($number, $digits)

Leaves C<$digits> (0 does not count) wherever they are relative to the point.

Default C<$digits> is 2.

	sround 10.11        # -> 10
	sround 100.11       # -> 100
	sround 0.00012      # -> 0.00012
	sround 1.2345       # -> 1.2
	sround 1.2345, 3    # -> 1.23

=head2 trans ($s)

Transliterates the russian text, leaving only Latin letters and dashes.

	trans "Мир во всём Мире!"  # => mir-vo-vsjom-mire

=head2 transliterate ($s)

Transliterates the russian text.

	transliterate "Мир во всём Мире!"  # => Mir vo vsjom Mire!

=head2 trapperr (&block)

Trap for STDERR.

	trapperr { print STDERR 123 }  # => 123

=head2 trappout (&block)

Trap for STDOUT.

	trappout { print 123 }  # => 123

=head2 TiB ()

The constant is one tebibyte.

	TiB  # -> 2**40

=head2 GiB ()

The constant is one gibibyte.

	GiB  # -> 2**30

=head2 MiB ()

The constant is one mebibyte.

	MiB  # -> 2**20

=head2 KiB ()

The constant is one kibibyte.

	KiB  # -> 2**10

=head2 xxL ()

Maximum length in data LongText mysql and mariadb.
L - large.

	xxL  # -> 4*GiB-1

=head2 xxM ()

Maximum length in data MediumText mysql and mariadb.
M - medium.

	xxM  # -> 16*MiB-1

=head2 xxR ()

Maximum length in data Text mysql and mariadb.
R - regularity.

	xxR  # -> 64*KiB-1

=head2 xxS ()

Maximum length in data TinyText mysql and mariadb.
S - small.

	xxS  # -> 255

=head1 SUBROUTINES/METHODS

=head1 AUTHOR

Yaroslav O. Kosmina LL<mailto:dart@cpan.org>

=head1 LICENSE

⚖ B<GPLv3>

=head1 COPYRIGHT

The  is copyright © 2023 by Yaroslav O. Kosmina. Rusland. All rights reserved.
