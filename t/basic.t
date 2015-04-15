use strict;
use warnings;

use Test::More;
use Test::DZil qw( simple_ini );
use Dist::Zilla::Util::Test::KENTNL 1.005000 qw( dztest );

# FILENAME: basic.t
# CREATED: 04/13/15 11:22:34 by Kent Fredric (kentnl) <kentfredric@gmail.com>
# ABSTRACT: Test basic extraction behavior

my $test = dztest();
$test->add_file( 'dist.ini' => simple_ini() );
my $result = $test->run_command( ['dumpwith'] );
ok( ref $result, 'self-test executed with no args' );
is( $result->error,     undef, 'no errors' );
is( $result->exit_code, 0,     'exit == 0' );
note( $result->stdout );

done_testing;

