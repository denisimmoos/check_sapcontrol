#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: check_sapcontrol.pl
#
#        USAGE: ./check_sapcontrol.pl  
#
#  DESCRIPTION: nagios/icinga check for sapcontrol
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Denis Immoos (<denisimmoos@gmail.com>)
#    AUTHORREF: Senior Linux System Administrator (LPIC3)
# ORGANIZATION: Sopra Steria Switzerland
#      VERSION: 1.0
#      CREATED: 11/20/2015 03:21:31 PM
#     REVISION: ---
#
#===============================================================================

use strict;
use warnings;
use utf8;
use Data::Dumper;
use Module::Load;

use lib '/opt/contrib/plugins/check_sapcontrol/lib';

#===============================================================================
# OPTIONS
#===============================================================================

my %Options = ();
$Options{'sapcontrolcmd'} = '/usr/lib64/nagios/plugins/soprasteria/bin/sapcontrol';
#$Options{'sapcontrolcmd'} = '/home/monitor/check_sapcontrol/bin/sapcontrol';

my @functions =( 'GetAlertTree','GetProcessList','ABAPGetWPTable' ); 

$Options{'functions'} = \@functions; 
$Options{'function'} = 'GetAlertTree';
$Options{'nr'} = '00';
$Options{'format'} = 'script';
$Options{'criteria'} = 'description';
$Options{'overwrite_ActualValue'} = 'OK';

#===============================================================================
# SYGNALS 
#===============================================================================

# You can get all SIGNALS by:
# perl -e 'foreach (keys %SIG) { print "$_\n" }'
# $SIG{'INT'} = 'DEFAULT';
# $SIG{'INT'} = 'IGNORE';

sub INT_handler {
    my($signal) = @_;
    chomp $signal;
    use Sys::Syslog;
    my $msg = "INT: int($signal)\n";
    print $msg;
    syslog('info',$msg);
    exit(0);
}
$SIG{INT} = 'INT_handler';

sub DIE_handler {
    my($signal) = @_;
    chomp $signal;
    use Sys::Syslog;
    my $msg = "DIE: die($signal)\n";
    syslog('info',$msg);
}
$SIG{__DIE__} = 'DIE_handler';

sub WARN_handler {
    my($signal) = @_;
    chomp $signal;
    use Sys::Syslog;
    my $msg = "WARN: warn($signal)\n";
    syslog('info',$msg);
}
$SIG{__WARN__} = 'WARN_handler';


#===============================================================================
# OPTIONS
#===============================================================================

use Getopt::Long;
Getopt::Long::Configure ("bundling");
GetOptions(\%Options,
	'v',    'verbose', 
	'h',    'help',
	'H:s',  'hostname:s',
	'A:s',  'authfile:s',
	'W:s',  'warning:s',
	'C:s',  'critical:s',
	'O:s',  'ok:s',
	'U:s',  'unknown:s',
	'M:s',  'match:s',
	'F:s',  'function:s',
	        'criteria:s',
	        'dump',
	        'reverse', # reverses the logic for ABAPGetWPTable 
	        'dumpall',
	        'dumpmatch',
	        'percent',
	        'noperfdata',
	        'pid:i',      
	        'name:s',
	        'typ:s',
	        'reason:s',
	        'status:s',
	        'description:s',
	        'sapcontrolcmd:s',
            'username:s',
	        'password:s',
	        'format:s',
	        'nr:s',
);

#===============================================================================
# PARSE OPTIONS
#===============================================================================

my $ParseOptions = 'SAPControl::ParseOptions';
load $ParseOptions;
$ParseOptions = $ParseOptions->new();
%Options = $ParseOptions->parse(\%Options);

#===============================================================================
# SAPControl
#===============================================================================

my $SAPControl = "SAPControl::$Options{'function'}";
load $SAPControl;
$SAPControl = $SAPControl->new();
my %SAPControl = $SAPControl->sapcontrol(\%Options);

if ( $Options{'dump'} ) {
	print '###########################' . "\n";
	print '# $SAPControl->sapcontrol()' . "\n";
	print '###########################' . "\n";
	print Dumper(%SAPControl);
	exit 0;
}

if ($Options{'dumpall'} ) {
	print '###########################' . "\n";
	print '# $SAPControl->sapcontrol()' . "\n";
	print '###########################' . "\n";
	print Dumper(%SAPControl);
}

# find a match
%SAPControl = $SAPControl->match(\%Options,\%SAPControl);

if ( $Options{'dumpmatch'} or $Options{'dumpall'} ) {
	print '###########################' . "\n";
	print '# $SAPControl->match()' . "\n";
	print '###########################' . "\n";
	print Dumper(%SAPControl);
}

$SAPControl->out_nagios(\%Options,\%SAPControl);

#===============================================================================
# MAIN
#===============================================================================

__END__


=head1 NAME

check_sapcontrol.pl - nagios/icinga check for sapcontrol

=head1 SYNOPSIS

./check_sapcontrol.pl 

=head1 DESCRIPTION

This description does not exist yet, it
was made for the sole purpose of demonstration.

=head1 LICENSE

This is released under the GPL3.

=head1 AUTHOR

Denis Immoos <denisimmoos@gmail.com>,
Senior Linux System Administrator (LPIC3)

