package Aion::Format::Url;

use common::sense;

use Exporter qw/import/;
our @EXPORT = our @EXPORT_OK = grep {
    ref \$Aion::Format::Url::{$_} eq "GLOB"
        && *{$Aion::Format::Url::{$_}}{CODE} && !/^(_|(NaN|import)\z)/n
} keys %Aion::Format::Url::;


#@category escape url

use constant UNSAFE_RFC3986 => qr/[^A-Za-z0-9\-\._~]/;

sub to_url_param(;$) {
	my ($param) = @_ == 0? $_: @_;
	$param =~ s/${\ UNSAFE_RFC3986}/$& eq " "? "+": sprintf "%%%02X", ord $&/age;
	$param
}

sub _escape_url_params {
	my ($key, $param) = @_;

	!defined($param)? ():
	$param eq 1? $key:
	ref $param eq "HASH"? do {
		join "&", map _escape_url_params("${key}[$_]", $param->{$_}), sort keys %$param
	}:
	ref $param eq "ARRAY"? do {
		join "&", map _escape_url_params("${key}[]", $_), @$param
	}:
	join "", $key, "=", to_url_param $param
}

sub to_url_params(;$) {
	my ($param) = @_ == 0? $_: @_;

	if(ref $param eq "HASH") {
		join "&", map _escape_url_params($_, $param->{$_}), sort keys %$param
	}
	else {
		join "&", pairmap { _escape_url_params($a, $b) } @$param
	}
}

# #@see https://habr.com/ru/articles/63432/
# # В multipart/form-data
# sub to_multipart(;$) {
# 	my ($param) = @_ == 0? $_: @_;
# 	$param =~ s/[&=?#+\s]/$& eq " "? "+": sprintf "%%%02X", ord $&/ge;
# 	$param
# }

#@category parse url

sub _parse_url ($) {
	my ($link) = @_;
	$link =~ m!^
		( (?<proto> \w+ ) : )?
		( //
			( (?<user> [^:/?\#\@]* ) :
		  	  (?<pass> [^/?\#\@]*  ) \@  )?
			(?<domain> [^/?\#]* )             )?
		(  / (?<path>  [^?\#]* ) )?
		(?<part> [^?\#]+ )?
		( \? (?<query> [^\#]*  ) )?
		( \# (?<hash>  .*	   ) )?
	\z!xn;
	return %+;
}

# 1 - set / in each page, if it not file (*.*), or 0 - unset
use config DIR => 0;
use config ONPAGE => "off://off";

# Парсит и нормализует url
sub parse_url($;$$) {
	my ($link, $onpage, $dir) = @_;
	$onpage //= ONPAGE;
	$dir //= DIR;
	my $orig = $link;

	my %link = _parse_url $link;
	my %onpage = _parse_url $onpage;

	if(!exists $link{path}) {
		$link{path} = join "", $onpage{path}, $onpage{path} =~ m!/\z!? (): "/", $link{part};
		delete $link{part};
	}

	if(exists $link{proto}) {}
	elsif(exists $link{domain}) {
		$link{proto} = $onpage{proto};
	}
	else {
		$link{proto} = $onpage{proto};
		$link{user} = $onpage{user} if exists $onpage{user};
		$link{pass} = $onpage{pass} if exists $onpage{pass};
		$link{domain} = $onpage{domain};
	}

	# нормализуем
	$link{proto} = lc $link{proto};
	$link{domain} = lc $link{domain};
	$link{dom} = $link{domain} =~ s/^www\.//r;
	$link{path} = lc $link{path};

	my @path = split m!/!, $link{path}; my @p;

	for my $p (@path) {
		if($p eq ".") {}
		elsif($p eq "..") {
			#@p or die "Выход за пределы пути";
			pop @p;
		}
		else { push @p, $p }
	}

	@p = grep { $_ ne "" } @p;

	if(@p) {
		$link{path} = join "/", "", @p;
		if($link{path} =~ m![^/]*\.[^/]*\z!) {
			$link{dir} = $`;
			$link{file} = $&;
		} elsif($dir) {
			$link{path} = $link{dir} = "$link{path}/";
		} else {
			$link{dir} = "$link{path}/";
		}
	} elsif($dir) {
		$link{path} = "/";
	} else { delete $link{path} }

	$link{orig} = $orig;
	$link{onpage} = $onpage;
	$link{link} = join "", $link{proto}, "://",
		exists $link{user} || exists $link{pass}? ($link{user},
			exists $link{pass}? ":$link{pass}": (), '@'): (),
		$link{dom},
		$link{path},
		length($link{query})? ("?", $link{query}): (),
		length($link{hash})? ("#", $link{hash}): (),
	;

	return \%link;
}

# Нормализует url
sub normalize_url($;$$) {
	parse_url($_[0], $_[1], $_[2])->{link}
}

1;