use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'Toolforge Mix\'n\'match tool app.';
author 'Michal Josef Spacek <skim@cpan.org>';
author_requires 'English' => 0;
author_requires 'File::Object' => 0.05;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
install_script 'bin/mix-n-match';
license 'bsd';
name 'App-Toolforge-MixNMatch';
perl_version 5.006002;
readme_from 'MixNMatch.pm';
recursive_author_tests('xt');
requires 'Class::Utils' => 0.03;
requires 'Error::Pure' => 0.15;
requires 'Exporter' => 0;
requires 'Mo' => 0;
requires 'List::MoreUtils' => 0;
requires 'Readonly' => 0;
requires 'Unicode::UTF8' => 0;
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/App-Toolforge-MixNMatch/issues',
resources 'homepage' => 'https://github.com/michal-josef-spacek/App-Toolforge-MixNMatch';
resources 'repository' => 'git://github.com/michal-josef-spacek/App-Toolforge-MixNMatch';
test_requires 'English' => 0;
test_requires 'Error::Pure::Utils' => 0;
test_requires 'Test::MockObject' => 0;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
