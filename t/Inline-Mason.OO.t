package MY::Mason;
use ExtUtils::testlib;
use Inline::Mason::OO;
our @ISA = qw(Inline::Mason::OO);


package main;

use strict;
use Test::More qw(no_plan);

my $m = new MY::Mason ('t/external_mason');
like( $m->HELLO(), qr/Hello/s, 'oo hello');
like( $m->NIFTY(lang => 'Perl'), qr/Perl/s, 'oo nifty');
$m->load_mason
    (
     BEATLES
     =>
     'Nothing\'s gonna change my <% $ARGS{what} %>',
     );
like($m->BEATLES(what => 'world'), qr/world/, 'beatles');


__END__

__HELLO__
% my $noun = 'World';
Hello <% $noun %>!
How are ya?
