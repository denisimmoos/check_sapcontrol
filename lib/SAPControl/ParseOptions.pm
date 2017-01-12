package SAPControl::ParseOptions;

#===============================================================================
#
#         FILE: ParseOptions.pm
#      PACKAGE: SAPControl::ParseOptions
#
#  DESCRIPTION: ParseOptions for SAPControl
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
# ORGANIZATION: Sopra Steria Switzerland
#      VERSION: 1.0
#      CREATED: 11/22/2015 03:11:47 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

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


sub parse {
	my $self = shift;
	my $ref_Options = shift;
	my %Options = %{ $ref_Options };
	my $caller = (caller(0))[3];


	foreach my $opt (keys(%Options)) {
		&error($caller,'$Options{' . $opt . '} not defined') if not ($Options{$opt}); 
	    &verbose($caller,'$Options{' . $opt . '} defined') if ( $Options{'v'} or $Options{'verbose'} ); 
	}

	#
	# critical,ok,warning,unknown
	#
	if ($Options{'ok'}) { $Options{'O'} = $Options{'ok'} };
	if ($Options{'O'}) { $Options{'ok'} = $Options{'O'} };

	if ($Options{'warning'}) { $Options{'W'} = $Options{'warning'} };
	if ($Options{'W'}) { $Options{'warning'} = $Options{'W'} };

	if ($Options{'critical'}) { $Options{'C'} = $Options{'critical'} };
	if ($Options{'C'}) { $Options{'critical'} = $Options{'C'} };

	if ($Options{'unknown'}) { $Options{'U'} = $Options{'unknown'} };
	if ($Options{'U'}) { $Options{'unknown'} = $Options{'U'} };

	if ($Options{'match'}) { $Options{'M'} = $Options{'match'} };
	if ($Options{'M'}) { $Options{'match'} = $Options{'M'} };


    # 
	# hostname
	#
	&error($caller,'$Options{hostname} must be defined') if not ( $Options{'H'} or $Options{'hostname'} ); 
	if ($Options{'H'}) { $Options{'hostname'} = $Options{'H'} };
	if ($Options{'hostname'}) { $Options{'H'} = $Options{'hostname'} };
	&verbose($caller,'$Options{hostname} = ' . $Options{'hostname'}  ) if ( $Options{'v'} or $Options{'verbose'} ); 

	#
	# sapcontrolcmd
	#
 
	&error($caller,'$Options{sapcontrolcmd} not a file') if not ( -f $Options{'sapcontrolcmd'} ); 
	&verbose($caller,'$Options{sapcontrolcmd} = ' . $Options{'sapcontrolcmd'}) if ( $Options{'v'} or $Options{'verbose'} ); 

	#
	# function
	#
	&error($caller,'$Options{function} must be defined') if not ($Options{'function'} or $Options{'F'} ); 
	if ($Options{'F'}) { $Options{'function'} = $Options{'F'} };
	if ($Options{'function'}) { $Options{'F'} = $Options{'function'} };
	&error($caller,$Options{function} . ' must be in $Options{functions}') if not (grep(/^$Options{'function'}$/, @{ $Options{functions} } ));
	&verbose($caller,'$Options{function} = ' . $Options{'function'}) if ( $Options{'v'} or $Options{'verbose'} ); 

	#
	# authfile
	#
	if ( not ( $Options{'username'} and  $Options{'password'} )) {
	
		&error($caller,'$Options{authfile} must be defined') if not ($Options{'authfile'} or $Options{'A'} ); 
	    if ($Options{'A'}) { $Options{'authfile'} = $Options{'A'} };
	    if ($Options{'authfile'}) { $Options{'A'} = $Options{'authfile'} };
		&error($caller,'$Options{authfile} not a file') if not ( -f $Options{'authfile'} ); 
		&error($caller,'$Options{authfile} cannot be defined together with --username') if ( $Options{'username'} ); 
		&error($caller,'$Options{authfile} cannot be defined together with --password') if ( $Options{'password'} ); 
		&verbose($caller,'$Options{authfile} = ' . $Options{'authfile'}) if ( $Options{'v'} or $Options{'verbose'} ); 

		open(AUTHFILE,$Options{'authfile'}) or &error($caller,'open(' . $Options{authfile} .')');
		my @authfile;
		while (my $row = <AUTHFILE>) {
				chomp $row;
				push(@authfile,$row);
		}
		$Options{'username'} = $authfile[0];
		$Options{'password'} = $authfile[1];

		&error($caller,'$Options{authfile} format error') if ( scalar(@authfile) != 2 ); 
		close(AUTHFILE) or &error($caller,'close(' . $Options{authfile} .')');
	}

	#
	# username
	#
	&error($caller,'$Options{username} must be defined') if not ($Options{'username'} ); 
	&verbose($caller,'$Options{username} = ' . $Options{'username'}) if ( $Options{'v'} or $Options{'verbose'} ); 

	#
	# password
	#
	&error($caller,'$Options{password} must be defined') if not ($Options{'password'} ); 
	&verbose($caller,'$Options{password} = ' . $Options{'password'}) if ( $Options{'v'} or $Options{'verbose'} ); 

	#
	# format
	#
	&error($caller,'$Options{format} must be script') if ($Options{'format'} ne  'script'); 
	&verbose($caller,'$Options{format} = ' . $Options{'format'}) if ( $Options{'v'} or $Options{'verbose'} ); 
	
	#
	# nr
	#
	&error($caller,'$Options{nr} must be defined') if not ($Options{'nr'}); 
	&verbose($caller,'$Options{nr} = ' . $Options{'nr'}) if ( $Options{'v'} or $Options{'verbose'} ); 

	#
	# GetProcessList
	#
	if($Options{'function'} eq 'GetProcessList' ) {

	    # name or pid or description
		&error($caller,'$Options{pid} or $Options{name} or $Options{description} must be defined (try: --dump)') if not (( $Options{'pid'} or $Options{'name'} or $Options{'description'}) or $Options{'dump'}); 
		&verbose($caller,'$Options{description} = ' . $Options{'description'}) if (($Options{'v'} or $Options{'verbose'}) and $Options{'description'} ); 
		&verbose($caller,'$Options{pid} = ' . $Options{'pid'}) if (($Options{'v'} or $Options{'verbose'}) and $Options{'pid'} ); 
		&verbose($caller,'$Options{name} = ' . $Options{'name'}) if (($Options{'v'} or $Options{'verbose'}) and $Options{'name'} ); 
	}
	#
	# GetAlertTree
	#
	if($Options{'function'} eq 'GetAlertTree' ) {

		#match
		&error($caller,'$Options{match} must be defined (try: --dump)') if not ($Options{'match'} or $Options{'dump'}); 
		&verbose($caller,'$Options{match} = ' . $Options{'match'}) if (($Options{'v'} or $Options{'verbose'}) and $Options{'match'} ); 

		# criteria
		&error($caller,'$Options{criteria} must be defined (try: --dump)') if not ( $Options{'criteria'} or $Options{'dump'} ); 
	}


	#
	# ABAPGetWPTable
	#
	if($Options{'function'} eq 'ABAPGetWPTable' ) {
	
		&error($caller,'$Options{status} or $Options{reason} must be defined (try: --dump)') if not ( $Options{'status'} or $Options{'reason'} or $Options{'dump'}); 
		&verbose($caller,'$Options{status} = ' . $Options{'status'}) if (($Options{'v'} or $Options{'verbose'}) and $Options{'status'} ); 
		&verbose($caller,'$Options{resaon} = ' . $Options{'resaon'}) if (($Options{'v'} or $Options{'verbose'}) and $Options{'resaon'} ); 


		&error($caller,'$Options{critical} must be defined and a numeric value or NULL') if not ( $Options{'critical'} or $Options{'dump'}); 
		&verbose($caller,'$Options{critical} = ' . $Options{'critical'}) if (($Options{'v'} or $Options{'verbose'}) and $Options{'critical'} ); 
		&error($caller,'$Options{typ} must be defined together with $Options{percent}') if (defined($Options{'percent'}) and not defined($Options{'typ'}));

		&error($caller,'$Options{reason} and $Options{status} can not ibe used together') if (defined($Options{'status'}) and defined($Options{'reason'}));
	
	}
	
	#
	# percent ;)
	#

	if (defined($Options{'percent'})) {
		  &error($caller,'$Options{warning} must be lower than 100%') if ( $Options{'warning'} >  100 );
		  &error($caller,'$Options{critical} must be equal or lower than 100%') if ( $Options{'critical'} >= 100 );
		  if ($Options{'reverse'}) {
		      &error($caller,'$Options{warning} must be greater than $Options{critical}') if ( $Options{'critical'} >= $Options{'warning'} );
		  } else {
		      &error($caller,'$Options{critical} must be greater than $Options{warning}') if ( $Options{'critical'} <= $Options{'warning'} );
		  }
	}
	

	return %Options;
}

1;

__END__

=head1 NAME

SAPControl::ParseOptions - ParseOptions for SAPControl 

=head1 SYNOPSIS

use SAPControl::ParseOptions;

my $object = SAPControl::ParseOptions->new();

my %HASH = $object->parse(\%HASH);

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>,
Senior Linux System Administrator (LPIC3)

=cut


