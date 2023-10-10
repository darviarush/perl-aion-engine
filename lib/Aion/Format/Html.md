# NAME

Aion::Format::Html - 

# SYNOPSIS

```perl
use Aion::Format::Html;

my $aion_format_html = Aion::Format::Html->new;
```

# DESCRIPION

.

# SUBROUTINES

## html2text ()

переводит html в text

```perl
my $aion_format_html = Aion::Format::Html->new;
$aion_format_html->html2text  # -> .3
```

## in_tag ($S, $tag, $atag)

Забрасывает тег в стек

```perl
my $aion_format_html = Aion::Format::Html->new;
$aion_format_html->in_tag($S, $tag, $atag)  # -> .3
```

## out_tag ($S, $tag)

Неявно использует $_

```perl
my $aion_format_html = Aion::Format::Html->new;
$aion_format_html->out_tag($S, $tag)  # -> .3
```

## safe4html ()

срезает у html-я опасные, а так же неведомые теги

```perl
my $aion_format_html = Aion::Format::Html->new;
$aion_format_html->safe4html  # -> .3
```

## split_on_pages ($html, $symbols_on_page, $by)

.

```perl
my $aion_format_html = Aion::Format::Html->new;
$aion_format_html->split_on_pages($html, $symbols_on_page, $by)  # -> .3
```

## summary ()

.

```perl
my $aion_format_html = Aion::Format::Html->new;
$aion_format_html->summary  # -> .3
```

# INSTALL

For install this module in your system run next [command](https://metacpan.org/pod/App::cpm):

```sh
sudo cpm install -gvv Aion::Format::Html
```

# AUTHOR

Yaroslav O. Kosmina [darviarush@mail.ru](mailto:darviarush@mail.ru)

# LICENSE

⚖ **GPLv3**

# COPYRIGHT

The Aion::Format::Html module is copyright © 2023 Yaroslav O. Kosmina. Rusland. All rights reserved.
