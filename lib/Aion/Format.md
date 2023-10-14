# NAME

Aion::Engine - a utilities for format numbers, colorizing output and so on

# VERSION

0.0.0-prealpha

# SYNOPSIS

```perl
use Aion::Engine;

printcolor "\n", ;

$aion_str_util  # -> 1
```

# DESCRIPTION

Aion::Engine concentrate utilities from the submodules, as is Aion::Engine::Number, Aion::Engine::Sub, etc.

# SUBROUTINES/METHODS

## accesslog ()

Для крона: Пишет в STDOUT

```perl
my $aion_format = Aion::Format->new;
$aion_format->accesslog  # -> .3
```

## coloring ()

Колоризирует текст escape-последовательностями: coloring("#{BOLD RED}ya#{}100!#RESET"), а затем - заменяет формат sprintf-ом

```perl
my $aion_format = Aion::Format->new;
$aion_format->coloring  # -> .3
```

## errorlog ()

Для крона: Пишет в STDIN

```perl
my $aion_format = Aion::Format->new;
$aion_format->errorlog  # -> .3
```

## flesch_index_human ($flesch_index)

.

```perl
my $aion_format = Aion::Format->new;
$aion_format->flesch_index_human($flesch_index)  # -> .3
```

## kb_size ($n)

Добавляет разряды чисел и добавляет единицу измерения

```perl
my $aion_format = Aion::Format->new;
$aion_format->kb_size($n)  # -> .3
```

## matches ()



```perl
my $aion_format = Aion::Format->new;
$aion_format->matches  # -> .3
```

## nous ($templates)

Упрощённый язык регулярок

```perl
my $aion_format = Aion::Format->new;
$aion_format->nous($templates)  # -> .3
```

## num ($s)

добавляет разделители между разрядами числа

```perl
my $aion_format = Aion::Format->new;
$aion_format->num($s)  # -> .3
```

## rim ($a)

.

```perl
my $aion_format = Aion::Format->new;
$aion_format->rim($a)  # -> .3
```

## round ($x, $dec)

Округляет до указанного разряда числа

```perl
my $aion_format = Aion::Format->new;
$aion_format->round($x, $dec)  # -> .3
```

## sinterval ($interval)

формирует человекочитабельный интервал

```perl
my $aion_format = Aion::Format->new;
$aion_format->sinterval($interval)  # -> .3
```

## sround ($number, $digits)

Оставляет $n цифр до и после точки: 10.11 = 10, 0.00012 = 0.00012, 1.2345 = 1.2, если $n = 2

```perl
my $aion_format = Aion::Format->new;
$aion_format->sround($number, $digits)  # -> .3
```

## to_radix ($number, $radix)

Converts a natural number to a given number system.

If `$radix` not present, then use 64 number system.

```perl
to_radix 13**6  # => .3
```

## from_radix ($number, $radix)

Parses a natural number in the specified number system.

If `$radix` not present, then use 64 number system.

```perl
from_radix  # -> .3
```

## transliterate ($s)

Transliterate cirillic text to latin.

```perl
transliterate "У лукоморья дуб зелёный!"  # => У лукоморья дуб зелёный!
```

## trans ($s)

Transliterate cirillic text, leaving only Latin letters and dashes and translates it to lowercase.

```perl
trans "У лукоморья дуб зелёный!"  # => .3
```


## TiB ()

A tibibyte.

```perl
TiB  # -> 2**40
```

## GiB ()

A gibibyte.

```perl
GiB  # -> 2**30
```

## MiB ()

A mibibyte.

```perl
MiB  # -> 2**20
```

## KiB ()

A kibibyte.

```perl
KiB  # -> 2**10
```

## xxL ()

A maximum length LongText-field in Mysql and Maria.

```perl
xxL  # ->  4*GiB-1
```

## xxM ()

A maximum length MediumText-field in Mysql and Maria.

```perl
xxM  # -> 16*MiB-1
```

## xxR ()

A maximum length Text-field in Mysql and Maria.

```perl
xxR  # -> 64*KiB-1
```

## xxS ()

A maximum length TinyText-field in Mysql and Maria.

```perl
xxS  # -> 255
```

# AUTHOR

Yaroslav O. Kosmina [dart@cpan.org](mailto:dart@cpan.org)

# LICENSE

⚖ **GPLv3**

# COPYRIGHT

Aion::Format is copyright © 2023 by Yaroslav O. Kosmina. Rusland. All rights reserved.
