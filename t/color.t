use strict;
use warnings;

use Test::More;
use Test::DZil qw( simple_ini );
use Dist::Zilla::Util::Test::KENTNL qw( dztest );

# FILENAME: basic.t
# CREATED: 04/13/15 11:22:34 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Test basic extraction behavior

delete local $ENV{ANSI_COLORS_DISABLED};
{
  note "<< Testing -VersionProvider with AutoVersion + --color-theme";
  require Dist::Zilla::Plugin::AutoVersion;
  my $test = dztest();
  $test->add_file( 'dist.ini' => simple_ini( ['AutoVersion'] ) );
  my $result = $test->run_command( [ 'dumpwith', '-VersionProvider', '--color-theme=basic::green' ] );
  ok( ref $result, 'self-test executed with no args' );
  is( $result->error,     undef, 'no errors' );
  is( $result->exit_code, 0,     'exit == 0' );
  note( $result->stdout );
  like( $result->stdout, qr/AutoVersion.*?=>.*?Dist::Zilla::Plugin::AutoVersion/, "report module with version provider" );
}
{
  note "<< Testing invalid --color-theme";
  require Dist::Zilla::Plugin::AutoVersion;
  my $test = dztest();
  $test->add_file( 'dist.ini' => simple_ini( ['AutoVersion'] ) );
  my $result = $test->run_command( [ 'dumpwith', '--color-theme=FAKE::FAKE' ] );
  ok( ref $result, 'self-test executed with no args' );
  isnt( $result->error,     undef, 'errors found' ) and note explain $result->error;
  isnt( $result->exit_code, 0,     'exit != 0' );
  like( $result->error, qr/available themes are/, "reports avail themes" );
}
done_testing;

