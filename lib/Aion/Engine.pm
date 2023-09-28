package Aion::Str::Util;
use 5.22.0;
use common::sense;

our $VERSION = "0.0.0-prealpha";

# как mkdir -p
sub mkpath ($;$) {
	my ($path, $mode) = @_;
	$mode //= 0755;
	mkdir $`, $mode while $path =~ m!/!g;
	$path
}

# считать файл, если он ещё не был считан
our %FILE_INC;
sub require_file ($) {
	my ($file) = @_;
	return undef if exists $FILE_INC{$file};
	my $x = read_file($file);
	$FILE_INC{$file} = 1;
	$x
}

# Считывает файл в указанной кодировке
sub read {
    my ($file, $layer) = @_;
	$layer //= ":utf8";
	open my $f, "<$layer", $file or die "read $file: $!";
	read $f, my $x, -s $f;
	close $f;
	$x
}

# записать файл
sub write_file (@) {
	my ($file, $s, $layer) = @_;
	$layer //= ":utf8";
	open my $f, ">$layer", $file or die "> $file: $!";
	print $f $s;
	close $f;
	wantarray? ($file, $s, $layer): $file
}

# Вернуть время модификации файла
sub mtime($) {
	(stat shift())[9]
}

# Вернуть время модификации файла
sub find($;@) {
	my ($file, @filters) = @_;
    my @S = ref $file? @$file: $file;
    
}

# 
sub noenter(&@) {

}

# 
sub exec(&@) {

}

# 
sub replace(&@) {

}


# Вернуть время модификации файла
sub sprintf($;@) {
	my $format = shift;
    
    
}

# Вернуть время модификации файла
sub printf($;@) {
	my $format = shift;
    
}

# Проводит соответствия
#
# replacement "...", qr/.../ => sub {...}, ...
#
sub replacement(@) {
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


1;
