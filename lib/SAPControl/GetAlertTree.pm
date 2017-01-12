package SAPControl::GetAlertTree;

#===============================================================================
#
#         FILE: GetAlertTree.pm
#      PACKAGE: SAPControl/GetAlertTree
#
#  DESCRIPTION: The SAPControl/GetAlertTree module
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
	my $tcodecount = -1;
	my $hash_nr;
	my $hash_key;
	my $hash_value;
	my $sub_hash_key;
	my $sub_hash_value;
    my @sapcontrol;
    my @subsapcontrol;
    my %sapcontrol;

	#print "$Options{'sapcontrolcmd'} -host $Options{'hostname'} -user $Options{'username'} $Options{'password'} -nr $Options{'nr'} -function $Options{'function'} -format $Options{'format'}";
	#die;
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


		if ( $hash_key eq 'Tid' or  $hash_key eq 'AnalyseTool' ) {
		#if ( $hash_key eq 'Tid' ) {

			$sapcontrol{$hash_nr}{$hash_key . 'String'} = $hash_value;

			@sapcontrol = ( split( /\;/,$hash_value) );
			#  clean \n 
			chomp(@sapcontrol);

			foreach my $value (@sapcontrol) {
				@subsapcontrol = ( split( /\=/,$value) ); 
				$sub_hash_key = $subsapcontrol[0];
				$sub_hash_key =~ s/^\s+|\s+$//g;
				$sub_hash_value = $subsapcontrol[1];
				$sub_hash_value =~ s/^\s+|\s+$//g;
				chomp($sub_hash_key);
				chomp($sub_hash_value);

				# counter +1
				if ( $hash_key eq 'AnalyseTool') { 

					++$tcodecount if ( $sub_hash_key eq 'TCODE' );
					$sapcontrol{$hash_nr}{$hash_key}{$sub_hash_key}{$tcodecount} = $sub_hash_value; }

				else { $sapcontrol{$hash_nr}{$hash_key}{$sub_hash_key} = $sub_hash_value; }

			}

			# ;) reset counter
			$tcodecount = -1;


		} else {
			$sapcontrol{$hash_nr}{$hash_key} = $hash_value;
	    }
	}

	close(SAPCONTROL) or &error($caller,'close(SAPCONTROL)');

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
		foreach $hash_key ( keys( %{ $SAPControl{$hash_nr} } )) {
			    
				if ( grep(/$Options{'match'}/,$SAPControl{$hash_nr}{$hash_key} )) {
					push( @hash_nr,$hash_nr);
				}
		}
    }

    @hash_nr = keys { map { $_ => 1 } @hash_nr };

    &error($caller,'$Options{match} not found or not uniq (try: --dump)') if ( scalar(@hash_nr) != 1 );

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
    my $perfvar;
    my $criteria;
	my $status = 0;


    my %NagiosStatus = (
		GREEN    => 0,
		YELLOW   => 1,
		RED      => 2,
		GRAY     => 3,

        OK       => 0,
        WARNING  => 1,
        CRITICAL => 2,
        UNKNOWN  => 3,

        0       => 'OK',
        1       => 'WARNING',
        2       => 'CRITICAL',
        3       => 'UNKNOWN',
    );


    foreach $hash_nr (keys(%SAPControl)) {

		# parse them later on
		$criteria = $SAPControl{$hash_nr}{"$Options{'criteria'}"};
		$perfvar = $criteria;

		&error($caller,'$Options{criteria} not found or undef (try: --dump)') if not ($criteria);
		&verbose($caller,'$Options{criteria} (' . $criteria . ')' ) if ( $Options{'v'} or $Options{'verbose'} );

		# ----------------------------------------------------------
		# RULE: minutes  or percentage
		# ----------------------------------------------------------
		if( $criteria =~ /%/ or $criteria =~ /\/min/ or $criteria =~ /Pg\/S/) {


			# spilt value
			$criteria = (split(/\s+/,$criteria))[0];
			$criteria =~ s/^\s+|\s+$//g;
			$criteria =~ s/-/0/g;

			# split var
			$perfvar = (split(/\s+/,$perfvar))[1];
			$perfvar =~ s/^\s+|\s+$//g;
			$perfvar =~ s/\///g;
			$perfvar =~ s/%/percent/g;

			#print $criteria . "\n";
			#print $perfvar . "\n";
			#die;
		    
			#
			# Allgemeingueltig
			#
			&error($caller,'$Options{critical} not defined') if not ($Options{'critical'});
			&error($caller,'$Options{critical} must be an integer') if ( $Options{'critical'} !~ /^-?\d+$/ );
			&error($caller,'$Options{warning} must be an integer') if ( $Options{'warning'} !~ /^-?\d+$/ and $Options{'warning'} );

			#
			# Prozent :)
			#
			if( $perfvar eq 'percent') {
				&error($caller,'$Options{critical} must be an integer lower 100') if ( $Options{'critical'} > 100 );
				&error($caller,'$Options{warning} must be an integer lower 100') if ( $Options{'warning'} > 100 );
				&error($caller,'$Options{warning} must be lower than $Options{critical}') if ( $Options{'warning'} > $Options{critical} and  $Options{'warning'} );
			}

			# :) Actual value
			if ($Options{'overwrite_ActualValue'} ) {
				$status = $Options{'overwrite_ActualValue'};
			} else {
				$status = $SAPControl{$hash_nr}{'ActualValue'};
			}

			$status = $NagiosStatus{$status};


			# test
			#$criteria = 40;


			if ($Options{'warning'}) {
				if ( $criteria >=  $Options{'warning'} ){
					$status = $NagiosStatus{'WARNING'};
					$SAPControl{$hash_nr}{'ActualValue'} .=  ' overwritten by $Options{warning}'; 
				} 
			}


			if ( $criteria >=  $Options{'critical'} ){
				$status = $NagiosStatus{'CRITICAL'};
                
				if ($Options{'warning'}) {
			        $SAPControl{$hash_nr}{'ActualValue'} .=  ' and $Options{critical}';
			    } else {
			        $SAPControl{$hash_nr}{'ActualValue'} .=  ' overwritten by $Options{critical}'; 
				}
			} 


			if ($Options{'noperfdata'}) {
				print $NagiosStatus{"$status"} . "\n"; 
			} else {
				if ( $perfvar eq 'percent' ) {
				     print $NagiosStatus{"$status"} . " | $perfvar=$criteria\%" . "\n\n"; 
				 } else {
				     print $NagiosStatus{"$status"} . " | $perfvar=$criteria" . "\n\n"; 
				 }
            }

		}

		# ----------------------------------------------------------
		# RULE DEFAULT
		# ----------------------------------------------------------

		elsif ( $criteria =~ /^(RED|GREEN|YELLOW|GRAY)$/ ) {
			
			&error($caller,'$Options{warning} cannot be defined in this context. Only $Options{critical} allowed') if ($Options{'warning'});

			$status = $NagiosStatus{$criteria};
			# inversion perversion
			if ( $Options{'critical'} eq $criteria ){
			     $status = $NagiosStatus{'CRITICAL'}
			} else {
				$status = $NagiosStatus{'OK'};
			}
		    
			print $NagiosStatus{$status} . "\n\n";
		} else {
			print $NagiosStatus{'3'} . " - $caller -> No rule defined \n\n";
		}


		print "function: $Options{'function'}" . "\n";
		print "criteria: $Options{'criteria'}" . "\n";
		foreach $hash_key ( sort ( keys(%{ $SAPControl{$hash_nr} } )))  {
		  next if ( $hash_key eq 'Tid');
		  next if ( $hash_key eq 'AnalyseTool');
		  print "$hash_key :  $SAPControl{$hash_nr}{$hash_key}"  . "\n";
		}

    }
	# ----------------------------------------------------------
	# END: percentage
	# ----------------------------------------------------------

	exit $status;
}


# this is the end my friend

1;
__END__

=head1 NAME

SAPControl::GetAlertTree - SAPControl::GetAlertTree module

=head1 SYNOPSIS

use SAPControl::GetAlertTree;

my $object = SAPControl::GetAlertTree->new();

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos - <denisimmoos@gmail.com>, Senior Linux System Administrator (LPIC3)

=cut


