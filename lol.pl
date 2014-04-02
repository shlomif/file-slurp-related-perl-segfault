#!/usr/bin/perl

use warnings;
use strict;

use Fcntl qw( O_RDONLY ) ;

my $max_fast_slurp_size = 1024 * 100 ;
my $is_win32 = $^O =~ /win32/i ;

my $fh;
open $fh, "<", "words.txt" or die "can't open words set: $!\n";
binmode $fh, ":encoding(UTF-8)";
my @ws =  <$fh>;
chomp @ws;
@ws = map {quotemeta $_} @ws;
close $fh;

sub _utf8_slurp
{
    my $filename = shift;

    open my $in, '<', $filename
        or die "Cannot open '$filename' for slurping - $!";

    binmode $in, ':utf8';
    local $/;
    my $contents = <$in>;

    close($in);

    return $contents;
}

my $s = _utf8_slurp('DE.txt');

my %words_table;
for my $w (@ws) {
    my $s_tmp = $s;
    while ($s_tmp =~ s/\b$w\b//i) {
        $words_table{$-[0]} = $w;
    }
}
