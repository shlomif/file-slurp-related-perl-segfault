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

# This function was copy+pasted from File::Slurp.
sub read_file {

    my $file_name = shift ;
    my $opts = ( ref $_[0] eq 'HASH' ) ? shift : { @_ } ;

# this is the optimized read_file for shorter files.
# the test for -s > 0 is to allow pseudo files to be read with the
# regular loop since they return a size of 0.

    if ( !ref $file_name && -e $file_name && -s _ > 0 &&
         -s _ < $max_fast_slurp_size && !%{$opts} && !wantarray ) {


        my $fh ;
        unless( sysopen( $fh, $file_name, O_RDONLY ) ) {

            @_ = ( $opts, "read_file '$file_name' - sysopen: $!");
            goto &_error ;
        }

        my $read_cnt = sysread( $fh, my $buf, -s _ ) ;

        unless ( defined $read_cnt ) {

            @_ = ( $opts,
                "read_file '$file_name' - small sysread: $!");
            goto &_error ;
        }

        $buf =~ s/\015\012/\n/g if $is_win32 ;
        return $buf ;
    }

# set the buffer to either the passed in one or ours and init it to the null
# string

    my $buf ;
    my $buf_ref = $opts->{'buf_ref'} || \$buf ;
    ${$buf_ref} = '' ;

    my( $read_fh, $size_left, $blk_size ) ;

# deal with ref for a file name
# it could be an open handle or an overloaded object

    if ( ref $file_name ) {

        my $ref_result = _check_ref( $file_name ) ;

        if ( ref $ref_result ) {

# we got an error, deal with it

            @_ = ( $opts, $ref_result ) ;
            goto &_error ;
        }

        if ( $ref_result ) {

# we got an overloaded object and the result is the stringified value
# use it as the file name

            $file_name = $ref_result ;
        }
        else {

# here we have just an open handle. set $read_fh so we don't do a sysopen

            $read_fh = $file_name ;
            $blk_size = $opts->{'blk_size'} || 1024 * 1024 ;
            $size_left = $blk_size ;
        }
    }

# see if we have a path we need to open

    unless ( $read_fh ) {

# a regular file. set the sysopen mode

        my $mode = O_RDONLY ;

#printf "RD: BINARY %x MODE %x\n", O_BINARY, $mode ;

#       $read_fh = gensym ;
        unless ( sysopen( $read_fh, $file_name, $mode ) ) {
            @_ = ( $opts, "read_file '$file_name' - sysopen: $!");
            goto &_error ;
        }

        if ( my $binmode = $opts->{'binmode'} ) {
            binmode( $read_fh, $binmode ) ;
        }

# get the size of the file for use in the read loop

        $size_left = -s $read_fh ;

#print "SIZE $size_left\n" ;

# we need a blk_size if the size is 0 so we can handle pseudofiles like in
# /proc. these show as 0 size but have data to be slurped.

        unless( $size_left ) {

            $blk_size = $opts->{'blk_size'} || 1024 * 1024 ;
            $size_left = $blk_size ;
        }
    }

# infinite read loop. we exit when we are done slurping

    while( 1 ) {

# do the read and see how much we got

        my $read_cnt = sysread( $read_fh, ${$buf_ref},
                $size_left, length ${$buf_ref} ) ;

# since we're using sysread Perl won't automatically restart the call
# when interrupted by a signal.

        next if $!{EINTR};

        unless ( defined $read_cnt ) {

            @_ = ( $opts, "read_file '$file_name' - loop sysread: $!");
            goto &_error ;
        }

# good read. see if we hit EOF (nothing left to read)

        last if $read_cnt == 0 ;

# loop if we are slurping a handle. we don't track $size_left then.

        next if $blk_size ;

# count down how much we read and loop if we have more to read.

        $size_left -= $read_cnt ;
        last if $size_left <= 0 ;
    }

# fix up cr/lf to be a newline if this is a windows text file

    ${$buf_ref} =~ s/\015\012/\n/g if $is_win32 && !$opts->{'binmode'} ;

    my $sep = $/ ;
    $sep = '\n\n+' if defined $sep && $sep eq '' ;

# see if caller wants lines

    if( wantarray || $opts->{'array_ref'} ) {

        use re 'taint' ;

        my @lines = length(${$buf_ref}) ?
            ${$buf_ref} =~ /(.*?$sep|.+)/sg : () ;

        chomp @lines if $opts->{'chomp'} ;

# caller wants an array ref

        return \@lines if $opts->{'array_ref'} ;

# caller wants list of lines

        return @lines ;
    }

# caller wants a scalar ref to the slurped text

    return $buf_ref if $opts->{'scalar_ref'} ;

# caller wants a scalar with the slurped text (normal scalar context)

    return ${$buf_ref} if defined wantarray ;

# caller passed in an i/o buffer by reference (normal void context)

    return ;
}
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
