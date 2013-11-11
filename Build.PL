
use strict;
use warnings;

use Module::Build 0.3601;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.4008"
  },
  "configure_requires" => {
    "Module::Build" => "0.4008"
  },
  "dist_abstract" => "Dump all plugins that 'do' a certain role",
  "dist_author" => [
    "Kent Fredric <kentfredric\@gmail.com>"
  ],
  "dist_name" => "Dist-Zilla-App-Command-dumpwith",
  "dist_version" => "0.001000",
  "license" => "perl",
  "module_name" => "Dist::Zilla::App::Command::dumpwith",
  "recommends" => {},
  "recursive_test_files" => 1,
  "requires" => {
    "Carp" => 0,
    "Dist::Zilla::App" => 0,
    "Dist::Zilla::dumpphases::Theme::basic::blue" => 0,
    "Module::Runtime" => 0,
    "Moose::Autobox" => 0,
    "Scalar::Util" => 0,
    "Try::Tiny" => 0,
    "perl" => "5.006",
    "strict" => 0,
    "warnings" => 0
  },
  "script_files" => [],
  "test_requires" => {
    "Test::More" => "1.001002"
  }
);


my %fallback_build_requires = (
  "Module::Build" => "0.4008",
  "Test::More" => "1.001002"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;
