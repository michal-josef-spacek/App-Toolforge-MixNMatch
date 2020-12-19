package App::Toolforge::MixNMatch;

use strict;
use warnings;

use Error::Pure qw(err);
use Getopt::Std;
use IO::Barf qw(barf);
use JSON::XS;
use LWP::Simple qw(get);
use Perl6::Slurp qw(slurp);
use Readonly;
use Toolforge::MixNMatch::Diff;
use Toolforge::MixNMatch::Print::Catalog;
use Toolforge::MixNMatch::Struct::Catalog;
use Unicode::UTF8 qw(encode_utf8);

# Constants
Readonly::Scalar our $URI_BASE => 'https://mix-n-match.toolforge.org/';
Readonly::Scalar our $URI_CATALOG_DETAIL => $URI_BASE.'api.php?query=catalog_details&catalog=%s';

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my $self = bless {}, $class;

	# Object.
	return $self;
}

sub command_diff {
	my ($json_file1, $json_file2, $print_options) = @_;

	if (! defined $json_file1 || ! -r $json_file1) {
		return (1, "Doesn't exist JSON file #1 for diff.");
	}
	if (! defined $json_file2 || ! -r $json_file2) {
		return (1, "Doesn't exist JSON file #2 for diff.");
	}

	my $opts_hr;
	if (defined $print_options) {
		$opts_hr = {};
		foreach my $print_option (split m/,/, $print_options) {
			$opts_hr->{$print_option} = 1;
		}
	}

	my $json1 = slurp($json_file1);
	my $json2 = slurp($json_file2);

	my $cat1_hr = decode_json($json1);
	my $cat2_hr = decode_json($json2);

	my $obj1 = Toolforge::MixNMatch::Struct::Catalog::struct2obj($cat1_hr->{'data'});
	my $obj2 = Toolforge::MixNMatch::Struct::Catalog::struct2obj($cat2_hr->{'data'});

	my $diff = Toolforge::MixNMatch::Diff::diff($obj1, $obj2);

	my $ret = Toolforge::MixNMatch::Print::Catalog::print($diff, $opts_hr);
	print encode_utf8($ret)."\n";

	return (0, undef);
}

sub command_download {
	my ($catalog_id, $output_file) = @_;

	if (! defined $catalog_id || $catalog_id =~ m/^\d+$/ms) {
		return (1, 'Missing or bad catalog ID.');
	}
	if (! defined $output_file) {
		$output_file = $catalog_id.'.json';
	}

	my $json = download_catalog_detail($catalog_id);
	barf($output_file, $json);

	return (0, undef);
}

sub command_print {
	my ($json_file_or_catalog_id, $print_options) = @_;

	my $json;
	if (-r $json_file_or_catalog_id) {
		$json = slurp($json_file_or_catalog_id);
	} elsif ($json_file_or_catalog_id =~ m/^\d+$/ms) {
		$json = download_catalog_detail($json_file_or_catalog_id);
	} else {
		return (1, "Doesn't exist JSON file or catalog ID for print.");
	}

	my $opts_hr;
	if (defined $print_options) {
		$opts_hr = {};
		foreach my $print_option (split m/,/, $print_options) {
			$opts_hr->{$print_option} = 1;
		}
	}

	my $struct_hr = decode_json($json);
	my $obj = Toolforge::MixNMatch::Struct::Catalog::struct2obj($struct_hr->{'data'});
	my $ret = Toolforge::MixNMatch::Print::Catalog::print($obj, $opts_hr);
	print encode_utf8($ret)."\n";

	return (0, undef);
}

sub download_catalog_detail {
	my $catalog_id = shift;

	my $uri = sprintf $URI_CATALOG_DETAIL, $catalog_id;
	my $json = get($uri);
	if (! defined $json) {
		err "Cannot download '$uri'.";
	}

	return $json;
}

# Run script.
sub run {
	my $self = shift;

	# Process arguments.
	$self->{'_opts'} = {
		'h' => 0,
	};
	if (! getopts('h', $self->{'_opts'}) || $self->{'_opts'}->{'h'}
		|| @ARGV < 1) {

		print STDERR "Usage: $0 [-h] [--version] [command] [command_args ..]\n";
		print STDERR "\t-h\t\tPrint help.\n";
		print STDERR "\t--version\tPrint version.\n";
		print STDERR "\tcommand\t\tCommand (diff, download, print).\n\n";
		print STDERR "\tcommand 'diff' arguments:\n";
		print STDERR "\t\tjson_file1 - JSON file #1\n";
		print STDERR "\t\tjson_file2 - JSON file #2\n";
		print STDERR "\t\t[print_options] - Print options (type, count, year_months, users)\n";
		print STDERR "\tcommand 'download' arguments:\n";
		print STDERR "\t\tcatalog_id - Catalog ID\n";
		print STDERR "\t\t[output_file] - Output file (default is catalog_id.json)\n";
		print STDERR "\tcommand 'print' arguments:\n";
		print STDERR "\t\tjson_file or catalog_id - Catalog ID or JSON file\n";
		print STDERR "\t\t[print_options] - Print options (type, count, year_months, users)\n";
		return 1;
	}
	my $command = shift @ARGV;
	my @command_args = @ARGV;

	my ($return, $error);
	if ($command eq 'diff') {
		($return, $error) = command_diff(@command_args);
	} elsif ($command eq 'download') {
		($return, $error) = command_download(@command_args);
	} elsif ($command eq 'print') {
		($return, $error) = command_print(@command_args);
	} else {
		print STDERR "Command '$command' doesn't supported.\n";
		return 1;
	}
	if ($return == 1) {
		print STDERR $error."\n";
		return 1;
	}

	return 0;
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

App::Toolforge::MixNMatch - Perl class for mix-n-match application.

=head1 SYNOPSIS

 use App::Toolforge::MixNMatch;

 my $obj = App::Toolforge::MixNMatch->new;
 $obj->run;

=head1 METHODS

=over 8

=item C<new()>

 Constructor.

=item C<run()>

 Run.

=back

=head1 ERRORS

 new():
         From Class::Utils:
                 Unknown parameter '%s'.

=head1 EXAMPLE

 use strict;
 use warnings;

 use App::Toolforge::MixNMatch;

 # Run.
 exit App::Toolforge::MixNMatch->new->run;

 # Output:
 # Usage: ./examples/ex1.pl [-h] [--version]
 #         -h              Print help.
 #         --version       Print version.

=head1 DEPENDENCIES

L<Getopt::Std>.

=head1 REPOSITORY

L<https://github.com/tupinek/App-Toolforge-MixNMatch>.

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2020 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.01

=cut
