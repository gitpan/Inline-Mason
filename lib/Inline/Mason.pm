package Inline::Mason;

use strict;

our $VERSION = '0.03';

use AutoLoader;
our @EXPORT = qw(AUTOLOAD);
our @ISA = qw(AutoLoader);

use Text::MicroMason qw(execute);
use Inline::Files::Virtual;

our $template;
our %tatoo_word = map{$_=>1} qw(import load_mason generate AUTOLOAD);

our $as_subs;

sub import {
    shift;
    my @ext_files;
    foreach my $t (@_){	
	if($t eq 'as_subs'){
	    $as_subs = 1;
	}
	elsif(ref($t) eq 'ARRAY'){
	    @ext_files = @$t;
	}
    }

    my ($pkg, $script_name) = (caller(0))[0,1];
    foreach my $real_file ($script_name, @ext_files){
	my @virtual_filenames = vf_load($real_file, qr/^__\w+__\n/);
	local $/;
	foreach my $vfile (@virtual_filenames){
	    my $marker = vf_marker($vfile);
	    $marker =~ s/\n+//so;
	    $marker =~ s/^__(.+?)__/$1/so;
	    die "This word '$marker' is forbidden" if $tatoo_word{$marker};
	    vf_open(my $F, $vfile) or die "$! ==> $marker";
	    my $content = <$F>;
	    next unless $content;
	    next if defined $template->{$marker};
	    $template->{$marker} = $content;
	    no strict;
	    *{"${pkg}::$marker"} = \&{"Inline::Mason::$marker"} if $as_subs;
	    vf_close $F;
	}
    }
}

sub load_mason {
    my %arg = @_;
    my ($pkg) = (caller(0))[0];
    no strict;
    while(my($marker, $content) = each %arg){
	die "This word '$marker' is forbidden" if $tatoo_word{$marker};
	$template->{$marker} = $content unless defined $template->{$marker};
	*{"${pkg}::$marker"} = \&{"Inline::Mason::$marker"} if $as_subs;
    }
}

sub generate {
    my $name = shift;
    my %args = @_;
    execute($template->{$name}, %args);
}

sub AUTOLOAD{
    use vars '$AUTOLOAD';
    $AUTOLOAD =~ /.+::(.+)/o;
    if(defined $template->{$1}){
	execute($template->{$1}, @_);
    }
    else {
	die "$1 does not exist.\n";
    }
}



1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Inline::Mason - Inline Mason Script

=head1 SYNOPSIS

    use Inline::Mason 'as_subs';

    print Inline::Mason::generate('HELLO');
    print Inline::Mason::HELLO();
    print HELLO();
    print NIFTY(lang => 'Perl');

    Inline::Mason::load_mason
    (
     BEATLES
     =>
     'Nothing\'s gonna change my <% $ARGS{what} %>',
     # ... ... ...
     );

    print BEATLES(what => 'world');

    __END__

    __HELLO__
    % my $noun = 'World';
    Hello <% $noun %>!
    How are ya?

    __NIFTY__
    <% $ARGS{lang} %> is nifty!


=head1 DESCRIPTION

This module enables you to embed mason scripts in your perl code. Using it is simple, much is shown in the above.

I<as_subs> is an option. Invoking Inline::Mason with it may let you treat virtual files as subroutines and call them directly.

I<load_mason> lets you create mason scripts in place, and you can pass a list of pairs.


=head1 EXTERNAL MASON

You can also use mason scripts which reside in external files. All you need to do is pass their names when you use the module.

  use Inline::Mason 'as_subs', [qw(external_mason.pl)];

When duplication happens, in-file mason is picked first.

=head1 SEE ALSO

This module uses L<Text::MicroMason> as its backend instead of L<HTML::Mason>, because it is much lighter and more accessible for this purpose. Please go to L<Text::MicroMason> for details and its limitations.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Yung-chung Lin (a.k.a. xern) E<lt>xern@cpan.orgE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself

=cut
