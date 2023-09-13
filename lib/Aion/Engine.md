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

## 

.

```perl
my $aion_str_util = Aion::Str::Util->new();

$aion_str_util  # -> 1
```

# INSTALL

Add to **cpanfile** in your project:

```cpanfile
requires 'Aion::Str::Util',
    git => 'https://github.com/darviarush/perl-aion-str-util.git',
    ref => 'master',
;
```

And run command:

```sh
$ sudo cpm install -gvv
```

# AUTHOR

Yaroslav O. Kosmina [dart@cpan.org](mailto:dart@cpan.org)

# COPYRIGHT AND LICENSE
This software is copyright (c) 2023 by Yaroslav O. Kosmina.

This is free software; you can redistribute it and/or modify it under the same terms as the Perl 5 programming language system itself.

⚖ **GPLv3**