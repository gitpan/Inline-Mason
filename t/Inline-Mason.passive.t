use Test::More qw(no_plan);
use Inline::Mason qw(passive as_subs);
Inline::Mason::load_file('t/external_mason');
ok( NIFTY(lang => 'Inline::Mason') =~ /Inline::Mason/ );

__END__
