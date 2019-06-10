#!/usr/bin/perl -w

use strict;

die("subsample.perl FILE_SCORE FILE_DE FILE_EN OUT") unless scalar(@ARGV) == 4;
my ($FILE_SCORE,$FILE_DE,$FILE_EN,$OUT) = @ARGV;

# collect word count per score
my %SCORE;
open(EN,$FILE_EN);
open(SCORE,$FILE_SCORE);
while(my $e = <EN>) {
  chop($e);
  my $score = <SCORE>; chop($score);
  my $e_length = scalar split(/ /,$e);
  $SCORE{$score} += $e_length;
}
close(EN);
close(SCORE);

# compute thresholds
my %THRESHOLD;
my $count = 0;
foreach my $score (sort {$b <=> $a} (keys %SCORE)) {
  $count += $SCORE{$score};
  $THRESHOLD{$score} = $count;
}
print $count."\n";

# find threshold cutoff values for specified sizes
my @SIZE = (1e7,1e8);
my %THRESHOLD_CUTOFF;
my $size = 0;
foreach my $score (sort {$b <=> $a} (keys %THRESHOLD)) {
  while ($THRESHOLD{$score} > $SIZE[$size]) {
    $THRESHOLD_CUTOFF{$SIZE[$size++]} = $score;
    last if $size == scalar(@SIZE);
  }
  last if $size == scalar(@SIZE);
}

# open files to store subsampled sets
my (%OUT_E,%OUT_F);
foreach my $size (@SIZE) {
  open $OUT_E{$size},"> $OUT.$size.en";
  open $OUT_F{$size},"> $OUT.$size.de";
}

# write out sentence pairs scoring over threshold
open(EN,$FILE_EN);
open(DE,$FILE_DE);
open(SCORE,$FILE_SCORE);
while(my $e = <EN>) {
  chop($e);
  my $f = <DE>; chop($f);
  my $score = <SCORE>; chop($score);
  my $e_length = scalar split(/ /,$e);
  foreach my $size (@SIZE) {
    my $cutoff = $THRESHOLD_CUTOFF{$size};
    if ($score >= $cutoff) {
      my $fh_e = $OUT_E{$size};
      my $fh_f = $OUT_F{$size};
      print $fh_e "$e\n";
      print $fh_f "$f\n";
    }
  }
}
close(SCORE);
close(DE);
close(EN);

