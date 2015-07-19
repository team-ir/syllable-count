use strict;
use warnings;

use feature "say";


##### main

### glob var
## hash huruf vokal
my %vocal = (
    'A' => 1,
    'I' => 1,
    'U' => 1,
    'E' => 1,
    'O' => 1
);
## hash pengganti konsonan 2 kata (fonem)
my %isfonem = (
    "KH" => "1",
    "NG" => "2",
    "NY" => "3",
    "SY" => "4"
);
my %is_K = (
    "K" => "K",
    "1" => "KH",
    "2" => "NG",
    "3" => "NY",
    "4" => "SY"
);
my %is_KV = (
    "KV" => 1,
    "1V" => 1,
    "2V" => 1,
    "3V" => 1,
    "4V" => 1
);
my %decode_K = (
    "1" => "KH",
    "2" => "NG",
    "3" => "NY",
    "4" => "SY"
);

#### input kata
print "word : ";
chomp(my $word = uc <STDIN>);
# my $word = "IDENTITASNYA";
my $res = fsa_uno($word, \%vocal, \%isfonem);
say "Hasil FSA tingkat 1 :\n$res : ".decode($word, $res, \%decode_K);

$res = fsa_dos($res, \%vocal, \%is_KV, \%is_K);
say "\nHasil FSA tingkat 2 :\n$res : ".decode($word, $res, \%decode_K);

$res = fsa_tres($res, \%vocal, \%is_KV, \%is_K);
say "\nHasil FSA tingkat 3 :\n$res : ".decode($word, $res, \%decode_K);

#####


### tingkat 1
## param 1 : input word
## param 2 : hash huruf vokal
## param 3 : hash pengganti konsonan encode
## return  : pola hasil pemenggalan kata
sub fsa_uno {
    ## split kata dalam array 1 huruf
    my @char = split //, $_[0];
    my $vocal = %{ $_[1] };
    my $isfonem = %{ $_[2] };
    ## hasil fsa
    my $res = '';

    for (my $i = 0; $i <= $#char; $i++) {
        ## pemisah
        if ($i > 0) { $res .= "-"; }
        ## proses fsa
        if ( exists($vocal{ $char[$i] }) ) {
            ## V
            $res .= "V";
        }
        elsif ($char[$i] eq 'N') {
            ## K
            if ($i < $#char) {
                if ( exists($vocal{ $char[$i+1] }) ) {
                    ## K
                    $res .= "KV";
                    $i+=1;
                } elsif ($char[$i+1] eq 'G') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if ( exists($vocal{ $char[$i+2] }) ) {
                            ## K - V
                            $res .= $isfonem{"NG"}."V";
                            $i+=2;
                        } else {
                            $res .= $isfonem{"NG"};
                            $i+=1;
                        }
                    } else {
                        $res .= $isfonem{"NG"};
                        $i+=1;
                    }
                } elsif ($char[$i+1] eq 'Y') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if ( exists($vocal{ $char[$i+2] }) ) {
                            ## K - V
                            $res .= $isfonem{"NY"}."V";
                            $i+=2;
                        } else {
                            $res .= $isfonem{"NY"};
                            $i+=1;
                        }
                    } else {
                        $res .= $isfonem{"NY"};
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
                if ( exists($vocal{ $char[$i+1] }) ) {
                    ## KV
                    $res .= "KV"; $i+=1;
                } elsif ($char[$i+1] eq 'H') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if ( exists($vocal{ $char[$i+2] }) ) {
                            ## K - V
                            $res .= $isfonem{"KH"}."V";
                            $i+=2;
                        } else {
                            $res .= $isfonem{"KH"};
                            $i+=1;
                        }
                    } else {
                        $res .= $isfonem{"KH"};
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
                if ( exists($vocal{ $char[$i+1] }) ) {
                    ## KV
                    $res .= "KV"; $i+=1;
                } elsif ($char[$i+1] eq 'Y') {
                    ## K
                    ## CUSTOM
                    if ($i < $#char-1) {
                        if ( exists($vocal{ $char[$i+2] }) ) {
                            ## K - V
                            $res .= $isfonem{"SY"}."V";
                            $i+=2;
                        } else {
                            $res .= $isfonem{"SY"};
                            $i+=1;
                        }
                    } else {
                        $res .= $isfonem{"SY"};
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
                if ( exists($vocal{ $char[$i+1] }) ) {
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
## param 2 : hash huruf vokal
## param 3 : hash pengganti konsonan decode
## param 4 : hash pengganti konsonan decode 2
## return  : pola hasil pemenggalan kata
sub fsa_dos {
    ## split kata dalam array dipisah dengan `-`
    my @part = split /\-/, $_[0];
    my $vocal = %{ $_[1] };
    ## hash pengganti konsonan
    my %is_KV = %{ $_[2] };
    my %is_K = %{ $_[3] };
    ## hasil fsa
    my $res = '';

    for (my $i = 0; $i <= $#part; $i++) {
        ## pemisah
        if ($i > 0) { $res .= "-"; }

        if ($part[$i] eq "V") {
            ## V
            if ($i < $#part) {
                if ( exists($is_K{ $part[$i+1] }) ) {
                    ## V - K
                    $res .= "V".$part[$i+1];
                    $i+=1;
                } else {
                    $res .= "V";
                }
            } else {
                $res .= "V";
            }
        } elsif ( exists($is_K{ $part[$i] }) ) {
            ## K
            if ($i < $#part) {
                if ( exists($is_K{ $part[$i+1] }) ) {
                    ## K - K
                    if ($i < $#part-1) {
                        if ( exists($is_KV{ $part[$i+2] }) ) {
                            ## K - K - KV
                            if ($i < $#part-2) {
                                if ( exists($is_K{ $part[$i+3] }) ) {
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
                } elsif ( exists($is_KV{ $part[$i+1] }) ) {
                    ## K - KV
                    if ($i < $#part-1) {
                        if ( exists($is_K{ $part[$i+2] }) ) {
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
                ## CUSTOM-MADE
                } elsif ($part[$i+1] eq "V") {
                    ## K - V
                    if ($i < $#part-1) {
                        if ( exists($is_K{ $part[$i+2] }) ) {
                            ## K - V - K
                            $res .= $part[$i]."V".$part[$i+2];
                            $i+=2;
                        } elsif ($part[$i+2] eq "V") {
                            ## K - V - V
                            $res .= $part[$i]."VV";
                            $i+=2;
                        } else {
                            $res .= $part[$i].$part[$i+1];
                            $i+=1;
                        }
                    } else {
                        $res .= $part[$i]."V";
                        $i+=1;
                    }
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } elsif ( exists($is_KV{ $part[$i] }) ) {
            ## KV
            if ($i < $#part) {
                if ( exists($is_K{ $part[$i+1] }) ) {
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
## param 2 : hash huruf vokal
## param 3 : hash pengganti konsonan decode
## param 4 : hash pengganti konsonan decode 2
## return  : pola hasil pemenggalan kata
sub fsa_tres {
    ## split kata dalam array dipisah dengan `-`
    my @part = split /\-/, $_[0];
    my $vocal = %{ $_[1] };
    ## hash pengganti konsonan
    my %is_KV = %{ $_[2] };
    my %is_K = %{ $_[3] };
    my %is_KVK = (
        "KVK" => 1,
        "1VK" => 1,
        "2VK" => 1,
        "3VK" => 1,
        "4VK" => 1
    );
    my %is_KKVK = (
        "KKVK" => 1,
        "K1VK" => 1,
        "K2VK" => 1,
        "K3VK" => 1,
        "K4VK" => 1
    );
    my %is_KKV = (
        "KKV" => 1,
        "K1V" => 1,
        "K2V" => 1,
        "K3V" => 1,
        "K4V" => 1
    );
    my %is_KKKV = (
        "KKKV" => 1,
        "KK1V" => 1,
        "KK2V" => 1,
        "KK3V" => 1,
        "KK4V" => 1
    );
    ## hasil fsa
    my $res = '';

    for (my $i = 0; $i <= $#part; $i++) {
        ## pemisah
        if ($i > 0) { $res .= "-"; }

        if ($part[$i] eq "VK") {
            ## VK
            if ($i < $#part) {
                if ( exists($is_K{ $part[$i+1] }) ) {
                    ## VK - K
                    $res .= "VK".$part[$i+1];
                    $i+=1;
                } else {
                    $res .= "VK";
                }
            } else {
                $res .= "VK";
            }
        } elsif ( exists($is_KVK{ $part[$i] }) ) {
            ## KVK
            if ($i < $#part) {
                if ( exists($is_K{ $part[$i+1] }) ) {
                    ## KVK - K
                    $res .= $part[$i].$part[$i+1];
                    $i+=1;
                } else {
                    $res .= $part[$i];
                }
            } else {
                $res .= $part[$i];
            }
        } elsif ( exists($is_KKVK{ $part[$i] }) ) {
            ## KKVK
            if ($i < $#part) {
                if ( exists($is_K{ $part[$i+1] }) ) {
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
        } elsif ( exists($is_KV{ $part[$i] }) ) {
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
        } elsif ( exists($is_KKV{ $part[$i] }) ) {
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
        } elsif ( exists($is_KKKV{ $part[$i] }) ) {
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
## param 3 : hash pengganti konsonan encode
## param 4 : hash pengganti konsonan decode
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
