package Inline::Mason;

use strict;

our $VERSION = '0.01';

use AutoLoader;
our @EXPORT = qw(AUTOLOAD);
our @ISA = qw(AutoLoader);

use Text::MicroMason qw(execute);
use Inline::Files::Virtual;

our $template;

sub import {
    shift;
    my $as_subs;
    $as_subs = 1 if $_[0] eq 'as_subs';
    my ($pkg, $script_name) = (caller(0))[0,1];
    my @virtual_filenames = vf_load($script_name, qr/^__\w+__\n/);
    local $/;
    foreach my $vfile (@virtual_filenames){
	my $marker = vf_marker($vfile);
	$marker =~ s/\n+//so;
	$marker =~ s/^__(.+?)__/$1/so;
	vf_open(my $F, $vfile) or die "$! ==> $marker";
	my $content = <$F>;
	next unless $content;
	$template->{$marker} .= $content;
	no strict;
	*{"${pkg}::$marker"} = \&{"Inline::Mason::$marker"} if $as_subs;
	vf_close $F;
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
    execute($template->{$1}, @_);
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

    __END__

    __HELLO__
    % my $noun = 'World';
    Hello <% $noun %>!
    How are ya?

    __NIFTY__
    <% $ARGS{lang} %> is nifty!


=head1 DESCRIPTION

This module enables you to embed mason scripts in your perl code. Using it is simple, much is shown in the above.

'as_subs' is an option. Invoking Inline::Mason with it may let you treat virtual files as subroutines and call them directly.

This module uses L<Text::MicroMason> as its backend instead of L<HTML::Mason>, because it is much lighter and more accessible for this purpose. Please go to L<Text::MicroMason> for details and its limitations.

=head1 AUTHOR

xern <xern@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by xern

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself

=cut
