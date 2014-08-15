use 5.008;    # utf8
use strict;
use warnings;
use utf8;

package Dist::Zilla::App::Command::dumpwith;

our $VERSION = '0.002002';

# ABSTRACT: Dump all plugins that 'do' a certain role

# AUTHORITY

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::App::Command::dumpwith",
    "inherits":"Dist::Zilla::App::Command",
    "interface":"class"
}

=end MetaPOD::JSON

=cut

use Dist::Zilla::App '-command';
use Moose::Autobox;
use Try::Tiny qw( try catch );
use Scalar::Util qw( blessed );

## no critic ( ProhibitAmbiguousNames)
sub abstract { return 'Dump all plugins that "do" a specific role' }
## use critic

sub opt_spec {
  return ( [ 'color-theme=s', 'color theme to use, ( eg: basic::blue )' ] );
}

sub _has_module {
  my ( undef, $module ) = @_;
  require Module::Runtime;
  try { Module::Runtime::require_module($module) }
  catch {
    require Carp;
    Carp::cluck("The module $module seems invalid, did you type it right? Is it installed?");
    ## no critic (RequireCarping)
    die $_;
  };
  return;
}

sub _has_dz_role {
  my ( undef, $role ) = @_;
  require Module::Runtime;
  my $module = Module::Runtime::compose_module_name( 'Dist::Zilla::Role', $role );
  try {
    Module::Runtime::require_module($module);
  }
  catch {
    require Carp;
    Carp::cluck("The role -$role seems invalid, did you type it right? Is it installed?");
    ## no critic (RequireCarping)
    die $_;
  };
  return;
}

sub validate_args {
  my ( $self, undef, $args ) = @_;
  for my $arg ( @{$args} ) {
    if ( $arg =~ /\A-(.*)\z/msx ) {
      $self->_has_dz_role($1);
    }
    else {
      $self->_has_module($arg);
    }
  }
  return 1;
}

sub _get_color_theme {
  my ( undef, $opt, $default ) = @_;
  return $default unless $opt->color_theme;
  return $opt->color_theme;
}

sub _get_theme_instance {
  my ( undef, $theme ) = @_;
  require Module::Runtime;
  my $theme_module = Module::Runtime::compose_module_name( 'Dist::Zilla::dumpphases::Theme', $theme );
  Module::Runtime::require_module($theme_module);
  return $theme_module->new();
}

sub execute {
  my ( $self, $opt, $args ) = @_;
  my $zilla = $self->zilla;

  my $theme = $self->_get_theme_instance( $self->_get_color_theme( $opt, 'basic::blue' ) );

  for my $arg ( @{$args} ) {
    $theme->print_section_prelude( 'role: ', $arg );
    for my $plugin ( @{ $zilla->plugins_with($arg) } ) {
      $theme->print_star_assoc( $plugin->plugin_name, blessed($plugin) );
    }
  }

  return 0;
}

1;

=head1 SYNOPSIS

  cd $PROJECT;
  dzil dumpwith -VersionProvider

  dzil dumpwith -FileGatherer --color-theme=basic::plain # plain text
  dzil dumpwith -BeforeRelease --color-theme=basic::green # green text

If you are using an HTML-enabled POD viewer, you should see a screenshot of this in action:

( Everyone else can visit L<http://kentnl.github.io/Dist-Zilla-App-Command-dumpwith/media/example_01.png> )

=for html <center><img src="http://kentnl.github.io/Dist-Zilla-App-Command-dumpwith/media/example_01.png" alt="Screenshot" width="806" height="438"/></center>

=head1 DESCRIPTION

This command, like its sibling L<< C<dumpphases>|Dist::Zilla::App::Command::dumpphases >>, exists to help make understanding
what is going on in C<Dist::Zilla> a little easier.

At least, having this command means debugging certain kinds of problems is more obvious.

If you want to see all plugins that are adding files to your dist?

    dzil dumpwith -FileGatherer

Though, of course, this requires some knowledge of what roles are applicable.

If you want to turn colors off, use L<< C<Term::ANSIcolor>'s environment variable|Term::ANSIColor >>
C<ANSI_COLORS_DISABLED>. E.g.,

    ANSI_COLORS_DISABLED=1 dzil dumpphases

Alternatively, specify a color-free theme:

    dzil dumpwith -VersionProvider --color-theme=basic::plain

=cut
