use Test::More qw(no_plan);
use Inline::Mason 'as_subs';
like(Inline::Mason::generate('HELLO'), qr/hello world/si, 'hello world');
like(Inline::Mason::HELLO(), qr/hello world/si, 'hello world');
like(NIFTY(lang => 'Perl'), qr/Perl/, 'perl is nifty');


__END__

__HELLO__
% my $noun = 'World';
Hello <% $noun %>!
How are ya?


__NIFTY__
<% $ARGS{lang} %> is nifty!

