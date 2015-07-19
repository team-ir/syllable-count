use strict;
use warnings;

use feature "say";


##### main

## ketentuan encoding konsonan
# "KH" => "1"
# "NG" => "2"
# "NY" => "3"
# "SY" => "4"

### decode konsonan 2 kata
my %decode_K = (
    "1" => "KH",
    "2" => "NG",
    "3" => "NY",
    "4" => "SY"
);

#### input kata dari file

my $filein = "../dokumen/kata.list";
my $fileout = "../dokumen/hasil.list";

open FILE, $filein or die "can't open file $filein..";
open OUT, ">", $fileout or die "can't open file $fileout..";

while (<FILE>) {
    chomp(my $word = uc $_);
    print OUT lc "$word : ";

    ## FSA tingkat 1
    my $res = fsa_uno($word);
    print OUT lc decode($word, $res, \%decode_K)." : ";

    ## FSA tingkat 2
    $res = fsa_dos($res);
    print OUT lc decode($word, $res, \%decode_K)." : ";

    ## FSA tingkat 3
    $res = fsa_tres($res);
    say OUT lc decode($word, $res, \%decode_K);
}

close FILE;
close OUT;

say "Done.";

#####


## cek huruf vokal
sub is_vocal {
    my $word = shift;
    if ($word =~ /^(A|I|U|E|O)$/) {
        return 1;
    }
    return 0;
}
## encode huruf konsonan 2 kata
sub consonant {
    my %consonant = (
        "KH" => "1",
        "NG" => "2",
        "NY" => "3",
        "SY" => "4"
    );
    my $word = shift;
    return $consonant{$word};
}
## cek konsonan
sub is_K {
    my $word = shift;
    if ($word =~ /^(K|1|2|3|4)$/) {
        return 1;
    }
    return 0;
}
## cek konsonan + vokal
sub is_KV {
    my $word = shift;
    if ($word =~ /^(K|1|2|3|4)V$/) {
        return 1;
    }
    return 0;
}
## cek konsonan + konsonan + vokal
sub is_KKV {
    my $word = shift;
    if ($word =~ /^(K|1|2|3|4)(K|1|2|3|4)V$/) {
        return 1;
    }
    return 0;
}
## cek konsonan + konsonan + konsonan + vokal
sub is_KKKV {
    my $word = shift;
    if ($word =~ /^(K|1|2|3|4)(K|1|2|3|4)(K|1|2|3|4)V$/) {
        return 1;
    }
    return 0;
}
## cek konsonan + vokal + konsonan
sub is_KVK {
    my $word = shift;
    if ($word =~ /^(K|1|2|3|4)V(K|1|2|3|4)$/) {
        return 1;
    }
    return 0;
}
## cek konsonan + konsonan + vokal + konsonan
sub is_KKVK {
    my $word = shift;
    if ($word =~ /^(K|1|2|3|4)(K|1|2|3|4)V(K|1|2|3|4)$/) {
        return 1;
    }
    return 0;
}

### tingkat 1
## param 1 : input word
## return  : pola hasil pemenggalan kata
sub fsa_uno {
    ## split kata dalam array 1 huruf
    my @char = split //, $_[0];
    ## hasil fsa
    my $res = '';

    for (my $i = 0; $i <= $#char; $i++) {
        ## pemisah
        if ($i > 0) { $res .= "-"; }
        ## proses fsa
        if (is_vocal($char[$i])) {
            ## V
            $res .= "V";
        }
        elsif ($char[$i] eq 'N') {
            ## K
            if ($i < $#char) {
                if (is_vocal($char[$i+1])) {
                    ## KV
                    $res .= "KV";
                    $i+=1;
                } elsif ($char[$i+1] eq 'G') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if (is_vocal($char[$i+2])) {
                            ## KV
                            $res .= consonant("NG")."V";
                            $i+=2;
                        } else {
                            $res .= consonant("NG");
                            $i+=1;
                        }
                    } else {
                        $res .= consonant("NG");
                        $i+=1;
                    }
                } elsif ($char[$i+1] eq 'Y') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if (is_vocal($char[$i+2])) {
                            ## KV
                            $res .= consonant("NY")."V";
                            $i+=2;
                        } else {
                            $res .= consonant("NY");
                            $i+=1;
                        }
                    } else {
                        $res .= consonant("NY");
                        $i+=1;
                    }
                } else {
                    $res .= "K";
                }
            } else {
                $res .= "K";
            }
        }
        elsif ($char[$i] eq 'K') {
            ## K
            if ($i < $#char) {
                if (is_vocal($char[$i+1])) {
                    ## KV
                    $res .= "KV"; $i+=1;
                } elsif ($char[$i+1] eq 'H') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if (is_vocal($char[$i+2])) {
                            ## KV
                            $res .= consonant("KH")."V";
                            $i+=2;
                        } else {
                            $res .= consonant("KH");
                            $i+=1;
                        }
                    } else {
                        $res .= consonant("KH");
                        $i+=1;
                    }
                } else {
                    $res .= "K";
                }
            } else {
                $res .= "K";
            }
        }
        elsif ($char[$i] eq 'S') {
            ## K
            if ($i < $#char) {
                if (is_vocal($char[$i+1])) {
                    ## KV
                    $res .= "KV"; $i+=1;
                } elsif ($char[$i+1] eq 'Y') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if (is_vocal($char[$i+2])) {
                            ## KV
                            $res .= consonant("SY")."V";
                            $i+=2;
                        } else {
                            $res .= consonant("SY");
                            $i+=1;
                        }
                    } else {
                        $res .= consonant("SY");
                        $i+=1;
                    }
                } else {
                    $res .= "K";
                }
            } else {
                $res .= "K";
            }
        }
        else {
            ## K
            if ($i < $#char) {
                if (is_vocal($char[$i+1])) {
                    ## KV
                    $res .= "KV";
                    $i+=1;
                } else {
                    $res .= "K";
                }
            } else {
                $res .= "K";
            }
        }
    }
    return $res;
}


#### tingkat 2
## param 1 : input word
## return  : pola hasil pemenggalan kata
sub fsa_dos {
    ## split kata dalam array dipisah dengan `-`
    my @part = split /\-/, $_[0];
    ## hasil fsa
    my $res = '';

    for (my $i = 0; $i <= $#part; $i++) {
        ## pemisah
        if ($i > 0) { $res .= "-"; }

        if ($part[$i] eq "V") {
            ## V
            if ($i < $#part) {
                if (is_K($part[$i+1])) {
                    ## V - K
                    $res .= "V".$part[$i+1];
                    $i+=1;
                } else {
                    $res .= "V";
                }
            } else {
                $res .= "V";
            }
        } elsif (is_K($part[$i])) {
            ## K
            if ($i < $#part) {
                if (is_K($part[$i+1])) {
                    ## K - K
                    if ($i < $#part-1) {
                        if (is_KV($part[$i+2])) {
                            ## K - K - KV
                            if ($i < $#part-2) {
                                if (is_K($part[$i+3])) {
                                    ## K - K - KV - K
                                    $res .= $part[$i].$part[$i+1].$part[$i+2].$part[$i+3];
                                    $i+=3;
                                } else {
                                    $res .= $part[$i].$part[$i+1].$part[$i+2];
                                    $i+=2;
                                }
                            } else {
                                $res .= $part[$i].$part[$i+1].$part[$i+2];
                                $i+=2;
                            }
                        } else {
                            $res.= $part[$i];
                        }
                    } else {
                        $res.= $part[$i];
                    }
                } elsif (is_KV($part[$i+1])) {
                    ## K - KV
                    if ($i < $#part-1) {
                        if (is_K($part[$i+2])) {
                            # K - KV - K
                            $res .= $part[$i].$part[$i+1].$part[$i+2];
                            $i+=2;
                        } else {
                            $res .= $part[$i].$part[$i+1];
                            $i+=1;
                        }
                    } else {
                        $res .= $part[$i].$part[$i+1];
                        $i+=1;
                    }
                }
            } else {
                $res .= $part[$i];
            }
        } elsif (is_KV($part[$i])) {
            ## KV
            if ($i < $#part) {
                if (is_K($part[$i+1])) {
                    ## KV - K
                    $res .= $part[$i].$part[$i+1];
                    $i+=1;
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } else {
            $res .= $part[$i];
        }
    }
    return $res;
}

#### tingkat 3
## param 1 : input word
## return  : pola hasil pemenggalan kata
sub fsa_tres {
    ## split kata dalam array dipisah dengan `-`
    my @part = split /\-/, $_[0];
    ## hasil fsa
    my $res = '';

    for (my $i = 0; $i <= $#part; $i++) {
        ## pemisah
        if ($i > 0) { $res .= "-"; }

        if ($part[$i] eq "VK") {
            ## VK
            if ($i < $#part) {
                if (is_K($part[$i+1])) {
                    ## VK - K
                    $res .= "VK".$part[$i+1];
                    $i+=1;
                } else {
                    $res .= "VK";
                }
            } else {
                $res .= "VK";
            }
        } elsif (is_KVK($part[$i])) {
            ## KVK
            if ($i < $#part) {
                if (is_K($part[$i+1])) {
                    ## KVK - K
                    $res .= $part[$i].$part[$i+1];
                    $i+=1;
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } elsif (is_KKVK($part[$i])) {
            ## KKVK
            if ($i < $#part) {
                if (is_K($part[$i+1])) {
                    ## KKVK - K
                    $res .= $part[$i].$part[$i+1];
                    $i+=1;
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } elsif ($part[$i] eq "V") {
            ## V
            $res .= "V";
        } elsif (is_KV($part[$i])) {
            ## KV
            if ($i < $#part) {
                if ($part[$i+1] eq "V") {
                    ## KV - V
                    $res .= $part[$i]."V"; $i+=1;
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } elsif (is_KKV($part[$i])) {
            ## KKV
            if ($i < $#part) {
                if ($part[$i+1] eq "V") {
                    ## KKV - V
                    $res .= $part[$i]."V"; $i+=1;
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } elsif (is_KKKV($part[$i])) {
            ## KKKV
            if ($i < $#part) {
                if ($part[$i+1] eq "V") {
                    ## KKKV - V
                    $res .= $part[$i]."V"; $i+=1;
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } else {
            $res .= $part[$i];
        }
    }
    return $res;
}

#### ubah V, K menjadi huruf dalam bentuk asli (teks input)
## param 1 : input word
## param 2 : pola kata yang terpenggal
## param 3 : hash pengganti konsonan decode
## return  : hasil pengubahan
sub decode {
    my @source = split //, $_[0];
    my $text = $_[1];
    my %cons = %{ $_[2] };
    my $result = '';

    my $i = 0;
    foreach my $part (split /-/, $text) {
        if ($i > 0) { $result .= "-"; }

        foreach my $ch (split //, $part) {
            if (exists( $cons{$ch} )) {
                $result .= $cons{$ch};
                ++$i;
            } else {
                $result .= $source[$i];
            }
            ++$i;
        }
    }
    return $result;
}
