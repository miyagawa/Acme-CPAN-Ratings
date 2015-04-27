package Acme::CPAN::Ratings;

use strict;
use 5.008_005;
our $VERSION = '0.01';

use Config;

__PACKAGE__->review;

sub loaded_from_bin {
    $_[1] =~ /^$Config{sitebinexp}\//;
}

sub review {
    my $class = shift;

    if ($class->loaded_from_bin($0)) {
        require File::Basename;
        my $bin = File::Basename::basename($0);
        my $dist = $class->find_dist($0);
        print <<EOF;
#####################################################################
# Rate $dist
#####################################################################

If you enjoy using $bin from $dist, would you mind taking a moment to
rate it? It won't take more than a minute. Thanks for your support!

Rate it now?    [Y]
Remind Me Later [r]
No, Thanks      [n]

EOF
        chomp(my $input = <STDIN>);
        if (lc $input eq 'y' or $input eq '') {
            system 'open', "http://cpanratings.perl.org/dist/$dist";
        }
    }
}

sub lines_of {
    open my $fh, "<", $_[0];
    map { chomp; $_ } <$fh>;
}

sub find_dist {
    my($class, $bin) = @_;

    require File::Find;

    my %pack_rev;
    File::Find::find({
        no_chdir => 1,
        wanted => sub {
            return unless m!/\.packlist$!;
            $pack_rev{$_} = $File::Find::name for lines_of $File::Find::name;
        },
    }, @INC);

    if ($pack_rev{$bin}) {
        (my $dist = $pack_rev{$bin}) =~ s!.*/auto/(.*?)/\.packlist$!$1!;
        $dist =~ s!/!-!g;
        $dist;
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Acme::CPAN::Ratings - Open ratings prompt for CPAN scripts

=head1 SYNOPSIS

  PERL5OPT=-MAcme::CPAN::Ratings 

=head1 DESCRIPTION



=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 COPYRIGHT

Copyright 2015- Tatsuhiko Miyagawa

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
