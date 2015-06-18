package Devel::Confess::Tiny;

# DATE
# VERSION

#BEGIN IFBUILT
use strict;
use warnings;
#END IFUNBUILT

# BEGIN_BLOCK: stacktrace_printer
sub _longmess {
    my $mess = $_[0];
    my $i = 2;
    {
        package DB;
        while (my @caller = caller($i)) {
            $mess .= "\t";
            if ($i > 1 && $caller[3]) { # subroutine
                $mess .= "$caller[3](";
                if ($caller[4]) { # has_args
                    my $j = 0;
                    for my $arg0 (@DB::args) {
                        my $arg = $arg0; # copy
                        if ($j++) { $mess .= ", " }
                        if (!defined($arg)) { $arg = "undef" }
                        elsif (ref($arg)) { }
                        else { $arg =~ s/([\\'])/\\$1/g; $arg = "'$arg'" }
                        $mess .= $arg;
                    }
                }
                $mess .= ") called ";
            }
            $mess .= "at $caller[1] line $caller[2]\n";
            $i++;
        }
    }
    $mess;
}

my %OLD_SIG;
BEGIN {
    @OLD_SIG{qw/__DIE__ __WARN__/} = @SIG{qw/__DIE__ __WARN__/};
    $SIG{__DIE__}  = sub { die @_ if ref($_[0]); die &_longmess };
    $SIG{__WARN__} = sub { warn &_longmess };
}

END {
    @SIG{qw/__DIE__ __WARN__/} = @OLD_SIG{qw/__DIE__ __WARN__/};
}
# END_BLOCK: stacktrace_printer

1;
# ABSTRACT: Include stack traces on all warnings and errors (with as little code as possible)

=head1 SYNOPSIS

 use Devel::Confess::Tiny;


=head1 DESCRIPTION

Provides a very simple and lightweight stacktrace printer. Does not require
I<any> module and code is suitable for embedding/copy-pasting. Does not support
fancy stuffs that other stacktrace printer might provide, e.g. dumping of
complex function arguments, colors, handling level trickery (like in L<Carp>),
etc. It just shows each level's filename/line number/function name with argument
list.


=head1 SEE ALSO

L<Devel::Confess>

L<Carp::Always> (also: L<Carp::Always::Color>, L<Carp::Source::Always>, etc)
