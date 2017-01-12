package SAPControl::GetProcessList;

#===============================================================================
#
#         FILE: GetProcessList.pm
#      PACKAGE: SAPControl::GetProcessList
#
#  DESCRIPTION: The SAPControl::GetProcessList module
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
# ORGANIZATION: Sopra Steria Switzerland
#      VERSION: 1.0
#      CREATED: 11/20/2015 03:25:01 PM
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

sub sapcontrol {

	my $self = shift;
	my $ref_Options = shift;
	my %Options = %{ $ref_Options };
	my $caller = (caller(0))[3];
	my $linecount = 0;
	my $hash_nr;
	my $hash_key;
	my $hash_value;
    my @sapcontrol;
    my %sapcontrol;

	open(SAPCONTROL,"$Options{'sapcontrolcmd'} -host $Options{'hostname'} -user $Options{'username'} $Options{'password'} -nr $Options{'nr'} -function $Options{'function'} -format $Options{'format'} |") or &error($caller,'open(SAPCONTROL)');

	while ( my $line = <SAPCONTROL> ) {

		++$linecount;
		chomp($line);

		&verbose($caller,'$line[' . $linecount . ']: ' . $line ) if ( $Options{'v'} or $Options{'verbose'} );

		# conditions
		if (!defined $line){ next; };

		# error
		if ( $linecount == 4 ) {
			if ( $line !~ /^OK/) {
				&error($caller,$line);
			}
		}

		if ($line !~ /^[0-9]+\ / ){ next; };

		# get the record set number
		$hash_nr = ( split(/\ /,$line))[0];

		# cut leeding and ending whitespaces
		$hash_nr =~ s/^\s+|\s+$//g;

		# split it to an array
		@sapcontrol = ( split(/^[0-9]+\ /,$line));

		# split key value pairs
		@sapcontrol = ( split(/\:/,$sapcontrol[1]) );

		# clean \n
		chomp(@sapcontrol);

		# cut leeding and ending whitespaces
		$hash_key = $sapcontrol[0];
		$hash_key =~ s/^\s+|\s+$//g;

		# cut leeding and ending whitespaces
		$hash_value = $sapcontrol[1];
		$hash_value =~ s/^\s+|\s+$//g;

	    $sapcontrol{$hash_nr}{$hash_key} = $hash_value;
	}

#	close(SAPCONTROL) or &error($caller,'close(SAPCONTROL)');

	return %sapcontrol;

}

sub match {

	my $self = shift;
	my $ref_Options = shift;
	my $ref_SAPControl = shift;
	my %Options = %{ $ref_Options };
	my %SAPControl = %{ $ref_SAPControl };
	my $caller = (caller(0))[3];
	my $hash_nr;
	my $hash_key;
	my $hash_value;
	my @hash_nr =();
	my %SAPControlMatch;

	foreach $hash_nr (keys(%SAPControl)) {

		# 
		# suchen nach match 
		#
		if (defined($Options{'pid'})) {
		   push(@hash_nr,$hash_nr) if ( $Options{'pid'} eq $SAPControl{$hash_nr}{'pid'} );
        }
		if (defined($Options{'name'})) {
		  push(@hash_nr,$hash_nr) if ( $Options{'name'} eq $SAPControl{$hash_nr}{'name'} );
        }
		if (defined($Options{'description'})) {
		  push(@hash_nr,$hash_nr) if ( $Options{'description'} eq $SAPControl{$hash_nr}{'description'} );
	    }
	}

	@hash_nr = keys { map { $_ => 1 } @hash_nr };

    &error($caller,'$Options{pid}/$Options{name}/$Options{description} not found (try: --dump)') if ( scalar(@hash_nr) != 1 );	

	$hash_nr = (@hash_nr)[0];

	# catch the match
	$SAPControlMatch{$hash_nr} = $SAPControl{$hash_nr};

	return %SAPControlMatch;

}


sub out_nagios {

	my $self = shift;
	my $ref_Options = shift;
	my $ref_SAPControl = shift;
	my %Options = %{ $ref_Options };
	my %SAPControl = %{ $ref_SAPControl };
	my $caller = (caller(0))[3];
	my $hash_nr;
	my $hash_key;
	my $count = 0;
	my $status; 
    

	my %NagiosStatus = (
		GREEN    => 'OK',
		RED      => 'CRITICAL',
		#GRAY     => 'UNKNOWN',
		GRAY     => 'CRITICAL',
		YELLOW   => 'WARNING',
        
		OK       => 0,
		WARNING  => 1,
		CRITICAL => 2,
		UNKNOWN  => 3,
	);

	if ($Options{'ok'}) {
		$NagiosStatus{$Options{'ok'}} = 'OK';
	}
	
	if ($Options{'critical'}) {
		$NagiosStatus{$Options{'critical'}} = 'CRITICAL';
	}
	
	if ($Options{'warning'}) {
		$NagiosStatus{$Options{'warning'}} = 'WARNING';
	}

	if ($Options{'unknown'}) {
		$NagiosStatus{$Options{'unknown'}} = 'UNKNOWN';
	}

	foreach $hash_nr (keys(%SAPControl) ) {

	    $status = $NagiosStatus{$SAPControl{$hash_nr}{'dispstatus'}};

		print "$status - $SAPControl{$hash_nr}{'textstatus'}" ."\n";

		print "function: $Options{'function'}" . "\n" if ($count == 0 );
		++$count;

		foreach $hash_key ( sort ( keys(%{ $SAPControl{$hash_nr} } )))  {
			 print "$hash_key :  $SAPControl{$hash_nr}{$hash_key}"  ."\n";
		}	
	}

	# return 0,1,2,3
	$status = $NagiosStatus{$status};
	exit $status;

}


1;
__END__

=head1 NAME

SAPControl::GetProcessList - SAPControl::GetProcessList module

=head1 SYNOPSIS

use SAPControl::GetProcessList;

my $object = SAPControl::GetProcessList->new();

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

=cut


