#!/usr/bin/perl -w
use 5.010;
use warnings;
use strict;
use File::Path;
use File::Copy;

BEGIN {
    unshift @INC, "/proj/cranegsoc/wa/fengyangwu/jupiter11/etc/perl_local_lib"; #ParseExcel module installed in this directory
}
use File::Find;
use Getopt::Long;
print "------------ready to list the dir--------------\n";

my $dir_tree;
my $item;
my @caseid = qw//;

sub parse_args {
  Getopt::Long::GetOptions (
    "dir_tree=s"      => \$dir_tree,
  );
}

parse_args();

opendir DIR, "$dir_tree" or die "can't open it";
while (my $f = readdir (DIR))    {
    if ($f =~ /\./) {
        next;    
    } elsif ( $f =~ /\../) {
        next;
    } else {
        print "$f\t";
        push @caseid, $f;   
    }
}

foreach $item (@caseid) {
    chdir "$dir_tree"."/"."$item";       
    system "mv packet0000 pkt0";
    chdir "$dir_tree/$item/pkt0";
    ##system "mkdir OFDM_MOD";
    ##system "cp FFTOutput.txt $dir_tree/$item/pkt0/OFDM_MOD";
    system "mkdir 11b_Modem";
    system "cp TN03_DATA.txt $dir_tree/$item/pkt0/11b_Modem";
    system "cp -r $dir_tree/$item/pkt0/TV/* $dir_tree/$item/pkt0";
}
