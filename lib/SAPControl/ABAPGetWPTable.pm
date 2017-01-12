package SAPControl::ABAPGetWPTable;

#===============================================================================
#
#         FILE: ABAPGetWPTable.pm
#      PACKAGE: SAPControl::ABAPGetWPTable
#
#  DESCRIPTION: The SAPControl::ABAPGetWPTable module
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
# ORGANIZATION: Sopra Steria Switzerland
#      VERSION: 1.1
#               --reason
#               --status
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

		# alles in klein 
		$hash_key =~ tr/A-Z/a-z/;

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
	my @hash_nr_status =();
	my @hash_nr_reason =();
	my @hash_nr_total =();
	my $hash_count =();
	my %SAPControlMatch;

	foreach $hash_nr (keys(%SAPControl)) {

		push(@hash_nr_total,$hash_nr);

		# 
		# suchen nach match 
		#
		if ( $Options{'typ'} eq $SAPControl{$hash_nr}{'typ'} 
			 and 
		     $Options{'reason'}
	       ){ 
			   push(@hash_nr,$hash_nr)        if ( $Options{'reason'} eq $SAPControl{$hash_nr}{'reason'} ); 
			   push(@hash_nr_reason,$hash_nr) if ( $Options{'reason'} ne $SAPControl{$hash_nr}{'reason'} );

        } # END typ - reason

        elsif ( 
			$Options{'typ'} eq $SAPControl{$hash_nr}{'typ'}
		    and	
			$Options{'status'} 
		) {
           
			push(@hash_nr,$hash_nr)        if ( $Options{'status'} eq $SAPControl{$hash_nr}{'status'} );
			push(@hash_nr_status,$hash_nr) if ( $Options{'status'} ne $SAPControl{$hash_nr}{'status'} );

		} # END type - status

	    elsif ( not $Options{'typ'} ) {
			# ohne type alles zählen
			if($Options{'status'}) {
			   push(@hash_nr,$hash_nr) if ( $Options{'status'} eq $SAPControl{$hash_nr}{'status'} );
			}

			if($Options{'reason'}) {
			   push(@hash_nr,$hash_nr) if ( $Options{'reason'} eq $SAPControl{$hash_nr}{'reason'} );
			}
		} # END else
	} # END foreach

	# 
	# uniq - dont think this is necessary ;)
	#
	@hash_nr        = keys { map { $_ => 1 } @hash_nr };
	@hash_nr_total  = keys { map { $_ => 1 } @hash_nr_total };
	@hash_nr_reason = keys { map { $_ => 1 } @hash_nr_reason };
	@hash_nr_status = keys { map { $_ => 1 } @hash_nr_status };

	#
	# count them
	#
	$SAPControlMatch{'hash_count'}        = scalar(@hash_nr);
	$SAPControlMatch{'hash_count_total'}  = scalar(@hash_nr_total);
	$SAPControlMatch{'hash_count_reason'} = scalar(@hash_nr_reason);
	$SAPControlMatch{'hash_count_status'} = scalar(@hash_nr_status);


	# 
	# percent
	#
	if ( 
		$Options{'percent'} 
		and $Options{'typ'} 
		and $Options{'reason'} 
	) {
		# :) division by zero -> for morons
		if ($SAPControlMatch{'hash_count_reason'} == 0 ) { $SAPControlMatch{'hash_count_percent'} = 100; }
		else {
			$SAPControlMatch{'hash_count_percent'} = 
			( $SAPControlMatch{'hash_count'} * 100)/ ( $SAPControlMatch{'hash_count_reason'} + $SAPControlMatch{'hash_count'} );
		}
	} 
	
	elsif (
		$Options{'percent'}
		and $Options{'typ'} 
		and $Options{'status'} 
	) {
		# :) division by zero -> for morons
		if ( $SAPControlMatch{'hash_count_status'} == 0) { $SAPControlMatch{'hash_count_percent'} = 100; }
		else {
			$SAPControlMatch{'hash_count_percent'} = 
			( $SAPControlMatch{'hash_count'} * 100)/ ( $SAPControlMatch{'hash_count_status'} + $SAPControlMatch{'hash_count'} );
		}
	} 


	#print "hash_count -> $SAPControlMatch{'hash_count'}" . "\n";
	#print "hash_count_total -> $SAPControlMatch{'hash_count_total'}" . "\n";
	#print "hash_count_reason -> $SAPControlMatch{'hash_count_reason'}" . "\n";
	#print "hash_count_status -> $SAPControlMatch{'hash_count_status'}" . "\n";
	#print "hash_count_percent -> $SAPControlMatch{'hash_count_percent'}" . "\n";

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
	my $compare = 0;
	my $count = 0;
	my $count_reason = 0;
	my $count_status = 0;
	my $count_total = 0;
	my $count_percent = 0;
	my $count_msg = 0;
	my $percent_sign = '';
	my $status; 
	my $msg; 
    

	my %NagiosStatus = (
		GREEN    => 'OK',
		RED      => 'CRITICAL',
		GRAY     => 'UNKNOWN',
		YELLOW   => 'WARNING',
        
		OK       => 0,
		WARNING  => 1,
		CRITICAL => 2,
		UNKNOWN  => 3,
	);

	# default
    $status = $NagiosStatus{'OK'};
    $msg = 'OK';

	$count         = $SAPControl{'hash_count'};
	$count_reason  = $SAPControl{'hash_count_reason'};
	$count_status  = $SAPControl{'hash_count_status'};
	$count_total   = $SAPControl{'hash_count_total'};
	$count_percent = $SAPControl{'hash_count_percent'};

	# :) 
	if ($Options{'percent'}) {
        $compare =  $count_percent;	
	} else {
        $compare =  $count;	
	}

	# reverse the logic 
	# 
	# CRITICAL if no more "Wait" statuses available
	#
	# ./check_sapcontrol.pl -H 10.122.4.75 --authfile /etc/icinga2/auth/hostname.auth  -F ABAPGetWPTable  --status Wait  --critical NULL --reverse --typ DIA
	#
	# Note the --reverse option.
	#
	# CRITICAL if one status "Ended"
	# ./check_sapcontrol.pl -H 10.122.4.75 --authfile /etc/icinga2/auth/hostname.auth  -F ABAPGetWPTable  --status Ended  --critical 1 
	# 
	if ($Options{'reverse'}) {

		if ($Options{'warning'} ) {
			if ( $compare <= $Options{'warning'} ) {
				$status = $NagiosStatus{'WARNING'};
				$msg = 'WARNING';
			} 
		}

		if ( $Options{'critical'} ne 'NULL' ) {
			if ($compare <= $Options{'critical'} ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			}
		} else {
			if ($compare <= 0 ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			
			}
		}
	
	} else { 

		if ( $Options{'warning'} ) {
			if ($compare >= $Options{'warning'} ) {
				$status = $NagiosStatus{'WARNING'};
				$msg = 'WARNING';
			} 
		}

		if ( $Options{'critical'} ne 'NULL' ) {
			if ($compare >= $Options{'critical'} ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			}
		} else {
			if ($compare > 0 ) {
				$status = $NagiosStatus{'CRITICAL'};
				$msg = 'CRITICAL';
			
			}
		}
	
	
	}	


	# ;) 
	if( not $Options{'warning'} ){ $Options{'warning'}='-'; }
	if( not $Options{'reverse'} ){ $Options{'reverse'} = '0'; }
	if( not $Options{'typ'} ){ $Options{'typ'} = 'ALL'; }

	if ($Options{'typ'}) {
	  
	  # formating 
	  if ($Options{'percent'} and $Options{'reason'} ) {

		  $count_total = $count + $count_reason;
		  
	      
		  print "$msg | count=$count percent=$count_percent\%;$Options{'warning'};$Options{'critical'};0;100" . "\n\n" 
		  . 'typ => '   . $Options{'typ'} . "\n"
		  . 'reason => '   . $Options{'reason'} . "\n"
		  . 'count => '     . "[$count/$count_total]" . "\n"
		  . 'warning => '  . $Options{'warning'} . '%' . "\n"
		  . 'critical => ' . $Options{'critical'} . '%' . "\n"
		  . 'percent => '  . $count_percent . '%' . "\n"
		  . 'reverse => '  . "$Options{'reverse'}" . "\n"
		  . "\n";
		  
	  } 

	  elsif ($Options{'percent'} and $Options{'status'} ) {
	      
		  $count_total = $count + $count_status;
		  print "$msg | count=$count percent=$count_percent\%;$Options{'warning'};$Options{'critical'};0;100" . "\n\n" 
		  
		  . 'typ => '       . $Options{'typ'}                 . "\n"
		  . 'status => '    . $Options{'status'}              . "\n"
		  . 'count => '     . "[$count/$count_total]"         . "\n"
		  . 'warning => '   . $Options{'warning'} . '%'       . "\n"
		  . 'critical => '  . $Options{'critical'} . '%'      . "\n"
		  . 'percent => '   . $count_percent . '%'            . "\n"
		  . 'reverse => '   . "$Options{'reverse'}"           . "\n"
		  . "\n";
	  } 
	  
	  elsif ($Options{'status'} ) {

          if ( $Options{'typ'} ne 'ALL' ) {
		    $count_total = $count + $count_status;
          }
	      
		  print "$msg | count=$count"                    . "\n\n" 
		  . 'typ => '       . $Options{'typ'}            . "\n"
		  . 'status => '    . $Options{'status'}         . "\n"
		  . 'count => '     . "[$count/$count_total]"    . "\n"
		  . 'warning => '   . $Options{'warning'}        . "\n"
		  . 'critical => '  . $Options{'critical'}       . "\n"
		  . 'reverse => '   . "$Options{'reverse'}"      . "\n"
		  . "\n";
	  } 
	  
	  elsif ($Options{'reason'} ) {
	      
          if ( $Options{'typ'} ne 'ALL' ) {
		    $count_total = $count + $count_status;
          }

		  print "$msg | count=$count"                    . "\n\n" 
		  . 'typ => '       . $Options{'typ'}            . "\n"
		  . 'reason => '    . $Options{'reason'}         . "\n"
		  . 'count => '     . "[$count/$count_total]"    . "\n"
		  . 'warning => '   . $Options{'warning'}        . "\n"
		  . 'critical => '  . $Options{'critical'}       . "\n"
		  . 'reverse => '   . "$Options{'reverse'}"      . "\n"
		  . "\n";
	  } 


	}

	# return 0,1,2,3
	$status = $NagiosStatus{$status};
	exit $status;

}


1;
__END__

=head1 NAME

SAPControl::ABAPGetWPTable - SAPControl::ABAPGetWPTable module

=head1 SYNOPSIS

use SAPControl::ABAPGetWPTable;

my $object = SAPControl::ABAPGetWPTable->new();

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

=cut


