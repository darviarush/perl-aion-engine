# NAME

Aion::Format::Html - a utilities for format HTML-documents

# SYNOPSIS

```perl
use Aion::Format::Html;

from_html "&excl;"  # => !
to_html "<a>"       # => &lt;a&gt;
```

# DESCRIPION

A utilities for format HTML-documents.

# SUBROUTINES

## from_html ($html)

Converts html to text.

```perl
from_html "Basic is <b>superlanguage</b>!<br>"  # => Basic is superlanguage!\n
```

## to_html ($html)

Escapes html characters.

## safe_html ($html)

Cuts off dangerous and unknown tags from html, and unknown attributes from known tags.

```perl
safe_html "-<embedded><br>-" # => -<br>-
```

## split_on_pages ($html, $symbols_on_page, $by)

Breaks text into pages taking into account html tags.

```perl
[split_on_pages "Alice in wonderland. This is book", 17]  # --> ["Alice in wonderland. ", "This is book"]
```

# AUTHOR

Yaroslav O. Kosmina [darviarush@mail.ru](mailto:darviarush@mail.ru)

# LICENSE

⚖ **GPLv3**

# COPYRIGHT

The Aion::Format::Html module is copyright © 2023 Yaroslav O. Kosmina. Rusland. All rights reserved.
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

Yaroslav O. Kosmina [dart@cpan.org](mailto:dart@cpan.org)

# LICENSE

⚖ **GPLv3**

# COPYRIGHT

The Aion::Format::Html module is copyright © 2023 Yaroslav O. Kosmina. Rusland. All rights reserved.
