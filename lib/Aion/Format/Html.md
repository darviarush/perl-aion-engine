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
