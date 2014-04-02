#!/usr/bin/perl
use warnings;
use strict;
use File::Slurp;

my $fh;
open $fh, "<", "words.txt" or die "can't open words set: $!\n";
binmode $fh, ":encoding(UTF-8)";
my @ws =  <$fh>;
chomp @ws;
@ws = map {quotemeta $_} @ws;
close $fh;

my $s = read_file("./DE.txt", binmode => ':utf8');

my %words_table;
for my $w (@ws) {
    my $s_tmp = $s;
    my $offset = 1;
    while ($s_tmp =~ s/\b$w\b//i) {
        $words_table{$offset + $-[0]} = $w;
        $offset += length $w;
    }
}

my @words_sorted = map {$words_table{$_}} sort {$a <=> $b} keys %words_table;

binmode STDOUT, ":encoding(UTF-8)";
print $_, "\n" for @words_sorted;