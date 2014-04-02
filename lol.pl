#!/usr/bin/perl

use warnings;
use strict;

my @ws = map { quotemeta } split(/\n/, <<'EOF_WORDS');
de
een
het
ik
jij
je
u
hij
zij
ze
wij
we
zij
mij
me
jou
uw
hem
haar
ons
hen
mijn
jouw
uw
zijn
haar
onze
hun
van mij
van jou
van u
van hem
van haar
van ons
van hun
kleuren
zwart
blauw
bruin
grijs
groen
oranje
paars
rood
wit
geel
maten
groot
diep
lang
smal
kort
klein
hoog
lang
dik
dun
breed
vormen
rond
cirkelvormig
recht
vierkant
driehoekig
smaken
bitter
fris
zout
zuur
gekruid
zoet
eigenschappen
slecht
schoon
donker
moeilijk
vuil
droog
gemakkelijk
leeg
duur
snel
buitenlands
volledig
goed
hard
moeilijk
zwaar
goedkoop
licht
lokaal
plaatselijk
nieuw
lawaaierig
oud
krachtig
rustig
stil
correct
traag
langzaam
zacht
zeer
erg
zwak
nat
verkeerd
jong
hoeveelheden
weinig
weinig
veel
veel
deel
sommige
een paar
geheel
gisteren
vandaag
morgen
nu
dan
later
nu
gisteravond
deze ochtend
vanmorgen
volgende week
onlangs
de laatste tijd
spoedig
snel
onmiddellijk
meteen
nog
nog steeds
nog
geleden
hier
er
daar
daarginds
overal
overal
thuis
weg
uit
zeer
heel
erg
nogal
vrij
echt
snel
goed
hard
langzaam
traag
voorzichtig
nauwelijks
nauwelijks
merendeels
bijna
absoluut
samen
alleen
altijd
vaak
soms
af en toe
zelden
zelden
nooit
over
boven
over
na
tegen
onder
rond
als
op
voor
achter
onder
onder
naast
tussen
buiten
achter
maar
door
ondanks
naar beneden
gedurende
tijdens
behalve
voor
uit
van
in
binnen
in
nabij
volgende
van
op
tegenover
uit
buiten
over
per
plus
rond
sinds
dan
via
door
tot
totdat
aan
in de richting van
onder
anders
tot
totdat
omhoog
via
met
binnen
zonder
volgens
vanwege
dicht bij
dankzij
door
met uitzondering van
verre van
binnenin
in
in plaats van
in de buurt van
naast
buiten
voorafgaande aan
tot aan
evenals
in aanvulling op
voor
ondanks
namens
bovenop
dit
deze
dat
die
deze
die
nee
niet
geen
Vragen
hoe
wat
wie
waarom
waar
EOF_WORDS

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
