package Icinga2Tools;

#===============================================================================
#
#         FILE: Icinga2Tools.pm
#      PACKAGE: Icinga2Tools.pm
#
#  DESCRIPTION: Tool set for icinga2
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denis.immoos@soprasteria.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
# ORGANIZATION: Sopra Steria Switzerland
#      VERSION: 1.0
#      CREATED: 11/27/2015 09:44:36 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

my %NagiosStatus = (
	OK       => 0,
	WARNING  => 1,
	CRITICAL => 2,
	UNKNOWN  => 3,

	0       => 'OK',
	1       => 'WARNING',
	2       => 'CRITICAL',
	3       => 'UNKNOWN',
);	




sub new
{
	my $class = shift;
	my $self = {};
	bless $self, $class;
	return $self;
} 


sub error {
	my $caller = shift;
	my $msg = shift || $caller;
	die( "ERROR($caller): $msg" );
}

sub verbose {
	my $caller = shift;
	my $msg = shift || $caller;
	print( "INFO($caller): $msg" . "\n" );
}

sub parse_check_syntax {

	my $self = shift;
	my @input = @_;
	my @in;
    my %output;
    my @output;
    my $in_key;
    my $in_value;

	$output{'nagios_status'} = $NagiosStatus{'OK'};
	$output{'nagios_msg'} = $NagiosStatus{$output{'nagios_status'}};

	foreach my $in (@input) {

		chomp($in);
		@in = split(/\s+/,$in);

        if ( $in =~ /Error/ ) {
			$output{'nagios_status'} = $NagiosStatus{'CRITICAL'};
			$output{'nagios_msg'} = $NagiosStatus{$output{'nagios_status'}};
		}
       
        if ( $in =~ /version/ ) {
			$in_key = 'version';
			$in_value = $in[5];
			$in_value =~ s/\)//g;
			$in_value =~ s/^v//g;
			$output{$in_key} = $in_value;
		}
        
		if ( $in =~ /Checked/) {

             $in_key = $in[3];
             $in_key =~ s/\(s\)/s/g;

			 $in_value = $in[2];
			 chomp($in_value);
			 $output{$in_key} = $in_value;

		}
	}

	return %output;

}

sub check_syntax {

	my $self = shift;
	my $icinga2_config = shift || '/etc/icinga2/icinga2.conf';
	my $icinga2_cmd = shift || '/usr/sbin/icinga2';
	my $caller = (caller(0))[3];
	$icinga2_cmd = "$icinga2_cmd daemon -c $icinga2_config -C";
	my @output;

	open(CHECK,'-|', $icinga2_cmd) or error($caller,$icinga2_cmd); 
	while ( my $line = <CHECK> ) {
		push(@output,$line);
	}
	close(CHECK);

	return @output;
}


1;

__END__

=head1 NAME

Icinga2Tools.pm - Tool set for icinga2 

=head1 SYNOPSIS

use Icinga2Tools.pm;

my $object = Icinga2Tools->new();

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denis.immoos@soprasteria.com>, Senior Linux System Administrator (LPIC3)

=cut


