use strict;
use warnings;

use feature "say";
use Data::Dumper qw (Dumper);


#### Main Program

my $doc = "../dokumen/Koleksi2.txt";
my $stw = "../dokumen/stopwords_ina.txt";
my $res = "../dokumen/kata.list";

my %termfreq = filter($doc, $stw, $res);
say "Done.";


sub filter {
    ## open dokumen awal
    open(FILE, "$_[0]") or die "can't open ";
    ## open stopwords file
    open(STOP,"$_[1]") or die "can't open ";
    ## open file list kata
    open(LIST,"> $_[2]") or die "can't open ";

    my %stopwords=();
    while(<STOP>) {
        chomp;
        $stopwords{$_} = 1;
    }
    ## frekuensi kata seluruh dokumen
    my %termfreq = ();

    while(<FILE>) {
        chomp;
        s/\s+/ /gi;

        if(/<TITLE>/../<\/DOC>/) {
            chomp;

            s/<.*?>/ /gi;
            s/[#\%\$\&\/\\,\.;:!?\@+`'"\*()_{}^=|\-]/ /g;
            tr/[A-Z]/[a-z]/;

            s/\s+/ /gi;
            s/^\s+//;
            s/\s+$//;

            ## tokenisasi
            my @splitKorpus = split;

            foreach my $kata (@splitKorpus) {
                ## filter awalan kata dan isi kata
                if (not $kata =~ /\d+/ and $kata =~ /^[i-p]/) {
                    unless (exists( $stopwords{$kata} )) {
                        $termfreq{$kata} += 1;
                    }
                }
            }
        }
    }

    #print INDEX Dumper %result;
    foreach my $word (sort keys %termfreq) {
        say LIST "$word";
    }

    ## tutup file
    close STOP;
    close FILE;
    close LIST;

    return %termfreq;
}
