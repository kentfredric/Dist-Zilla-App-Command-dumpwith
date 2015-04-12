use 5.006;
use strict;
use warnings;

package Dist::Zilla::App::Command::dumpwith;

our $VERSION = '0.002004';

# ABSTRACT: Dump all plugins that 'do' a certain role

our $AUTHORITY = 'cpan:KENTNL'; # AUTHORITY













use Dist::Zilla::App '-command';

## no critic ( ProhibitAmbiguousNames)
sub abstract { return 'Dump all plugins that "do" a specific role' }
## use critic

sub opt_spec {
  return ( [ 'color-theme=s', 'color theme to use, ( eg: basic::blue )' ] );
}

sub _has_module {
  my ( undef, $module ) = @_;
  require Module::Runtime;
  require Try::Tiny;
  Try::Tiny::try { Module::Runtime::require_module($module) }
  Try::Tiny::catch {
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
  require Try::Tiny;
  Try::Tiny::try {
    Module::Runtime::require_module($module);
  }
  Try::Tiny::catch {
    require Carp;
    Carp::cluck("The role -$role seems invalid, did you type it right? Is it installed?");
    ## no critic (RequireCarping)
    die $_;
  };
  return;
}

sub validate_args {
  my ( $self, $opt, $args ) = @_;
  for my $arg ( @{$args} ) {
    if ( $arg =~ /\A-(.*)\z/msx ) {
      $self->_has_dz_role($1);
    }
    else {
      $self->_has_module($arg);
    }
  }
  my $theme = $opt->color_theme || 'basic::blue';
#  try {
    $self->_load_color_theme( $theme );
    *STDERR->print("DID NOT FAIL");
#  }
#  catch {
#    my $error = shift;
#    require Carp;
#    my $message = $error . qq[\n\n];
#    $message .= sprintf "^ Was seen attempting to load theme <%s>\n", $theme;
#    $message .= sprintf 'available themes are: %s', ( join q{, }, $self->_available_themes );
#    Carp::croak($message);
#  };
  return 1;
}

sub _available_themes {
  my (undef) = @_;
  require Path::ScanINC;
  my (@theme_dirs) = Path::ScanINC->new()->all_dirs( 'Dist', 'Zilla', 'dumpphases', 'Theme' );
  if ( not @theme_dirs ) {
    require Carp;
    ## no critic (ValuesAndExpressions::RequireInterpolationOfMetachars)
    Carp::cluck('Found no theme dirs in @INC matching Dist/Zilla/dumpphases/Theme/');
  }
  my (%themes);
  require Path::Tiny;
  for my $dir (@theme_dirs) {
    my $it = Path::Tiny->new($dir)->iterator(
      {
        recurse         => 1,
        follow_symlinks => 0,
      },
    );
    while ( my $item = $it->() ) {
      next unless $item =~ /[.]pm\z/msx;
      next if -d $item;
      my $theme_name = $item->relative($dir);
      $theme_name =~ s{[.]pm\z}{}msx;
      $theme_name =~ s{/}{::}msxg;
      $themes{$theme_name} = 1;
    }
  }
  ## no critic (Variables::ProhibitUnusedVarsStricter)
  return ( my (@list) = sort keys %themes );
}
sub _load_color_theme {
  my ( undef, $color_theme ) = @_;
  require Module::Runtime;
  my $theme_module = Module::Runtime::compose_module_name( 'Dist::Zilla::dumpphases::Theme', $color_theme );
  Module::Runtime::require_module($theme_module);
  return $theme_module;
}

sub execute {
  my ( $self, $opt, $args ) = @_;
  my $zilla = $self->zilla;

  my $theme_module = $self->_load_color_theme( $opt->color_theme || 'basic::blue' );
  my $theme = $theme_module->new();

  require Scalar::Util;
  for my $arg ( @{$args} ) {
    $theme->print_section_prelude( 'role: ', $arg );
    for my $plugin ( @{ $zilla->plugins_with($arg) } ) {
      $theme->print_star_assoc( $plugin->plugin_name, Scalar::Util::blessed($plugin) );
    }
  }

  return 0;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Dist::Zilla::App::Command::dumpwith - Dump all plugins that 'do' a certain role

=head1 VERSION

version 0.002004

=head1 SYNOPSIS

  cd $PROJECT;
  dzil dumpwith -VersionProvider

  dzil dumpwith -FileGatherer --color-theme=basic::plain # plain text
  dzil dumpwith -BeforeRelease --color-theme=basic::green # green text

If you are using an HTML-enabled POD viewer, you should see a screenshot of this in action:

( Everyone else can visit L<http://kentnl.github.io/Dist-Zilla-App-Command-dumpwith/media/example_01.png> )

=begin MetaPOD::JSON v1.1.0

{
    "namespace":"Dist::Zilla::App::Command::dumpwith",
    "inherits":"Dist::Zilla::App::Command",
    "interface":"class"
}


=end MetaPOD::JSON

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

=head1 AUTHOR

Kent Fredric <kentnl@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Kent Fredric <kentfredric@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
