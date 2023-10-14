package Aion::Format;
use 5.22.0;
no strict; no warnings; no diagnostics;
use common::sense;

our $VERSION = "0.0.0-prealpha";

require Term::ANSIColor;

require Exporter;
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
};

#@category Цвет

# Колоризирует текст escape-последовательностями: coloring("#{BOLD RED}ya#{}100!#RESET"), а затем - заменяет формат sprintf-ом
sub coloring(@) {
	my $s = shift;
	$s =~ s!#\{([\w \t]*)\}|#(\w+)! Term::ANSIColor::color($1 // $2) !ge;
	sprintf $s, @_
}

# Для крона: Пишет в STDOUT
sub accesslog(@) {
	print "[", strftime("%F %T", localtime), "] ", sprintf @_;
}

# Для крона: Пишет в STDIN
sub errorlog(@) {
	print STDERR "[", strftime("%F %T", localtime), "] ", sprintf @_;
}

# Проводит соответствия
#
# matches "...", qr/.../ => sub {...}, ...
#
sub matches(@) {
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
sub to_radix($;$) {
	use bigint;
	my ($n, $radix) = @_;
	$radix //= 64;
	die "to_radix: The number system is too large ($radix). Using number system before " . (1 + length $CIF) if $radix > length $CIF;
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

	my ($x, $y) = split /\./, $s;
	$y = "\.$y" if defined $y;

	$x = reverse $x;
	$x =~ s!\d{3}!$& !g;
	$x =~ s! ([+-]?)$!$1!;
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

	my $i;
	for(sort {$b<=>$a} keys %FLESCH_INDEX_NAMES) {
		$i = $FLESCH_INDEX_NAMES{$_}, last if $flesch_index > $_;
	}

	$i // "несвязный русский текст"
}

1;
