# check_sapcontrol
## Example ABAPGetWPTable:

### --dump
<pre>
./check_sapcontrol.pl -H hostname --authfile /etc/icinga2/auth/sap_monitor.auth  -F ABAPGetWPTable  --dump
###########################
# $SAPControl->sapcontrol()
###########################
$VAR1 = '11';
$VAR2 = {
          'cpu' => '4',
          'time' => '',
          'status' => 'Wait',
          'table' => '',
          'err' => '',
          'reason' => '',
          'no' => '11',
          'program' => '',
          'client' => '',
          'pid' => '3832',
          'sem' => '',
          'action' => '',
          'user' => '',
          'typ' => 'BTC',
          'start' => 'yes'
        };
$VAR3 = '7';
$VAR4 = {
          'cpu' => '0',
          'time' => '',
          'status' => 'Wait',
          'table' => '',
          'err' => '',
          'reason' => '',
          'no' => '7',
          'program' => '',
          'client' => '',
          'pid' => '4280',
          'sem' => '',
          'action' => '',
          'user' => '',
          'typ' => 'DIA',
          'start' => 'yes'
        };
$VAR5 = '2';
(...)
</pre>

### --percent
<pre>
./check_sapcontrol.pl -H hostname --authfile /etc/icinga2/auth/sap_monitor.auth  -F ABAPGetWPTable --status Ended  --critical 50 --warning 40 --percent --typ DIA
</pre>

### --reverse - CRITICAL if no '--status Wait' found
<pre>
./check_sapcontrol.pl -H hostname  --authfile /etc/icinga2/auth/sap_monitor.auth  -F ABAPGetWPTable  --status Wait   --critical NULL --reverse --typ DIA
</pre>

###   --critical 3  --warning 2
<pre>
./check_sapcontrol.pl -H hostname --authfile  /etc/icinga2/auth/sap_monitor.auth   -F ABAPGetWPTable  --status Ended   --critical 3  --warning 2 --typ DIA
</pre>



## Example GetAlertTree:

<pre>
./check_sapcontrol.pl -H hostname --authfile /etc/icinga2/auth/hostname.auth  --dump
</pre>

The AlertTree is saved in a Perl-Hash.

**Output:**
<pre>
###########################
# $SAPControl->sapcontrol()
###########################
$VAR1 = '559';
$VAR2 = {
          'Time' => '2016 06 24 10',
          'parent' => '556',
          'AlDescription' => '',
          'name' => 'Oldest blocked Spid',
          'VisibleLevel' => 'OPERATOR',
          'description' => '0 Secs',
          'AnalyseToolString' => 'TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN=X;FNAM=IN_TID-MTSYS
ID;FVAL=BWD;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTMCNAME;FVAL=Microsoft SQL
 Server;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTNUMRANGE;FVAL=004;TCODE=rz25;
DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTUID;FVAL=0000383001;TCODE=rz25;DSPMODE=E;UPDMODE
=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTCLASS;FVAL=100;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DY
NPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTINDEX;FVAL=0000001332;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBE
GIN= ;FNAM=IN_TID-EXTINDEX;FVAL=0000000484;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=WHI
CH_TOOL;FVAL=020;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=MTE_NAME;FVAL=\\BWD\\stechsv2
54_BWD_00\\...\\CPU\\Oldest blocked Spid',
          'ActualValue' => 'GREEN',
          'TidString' => 'MTSYSID=BWD;MTMCNAME=Microsoft SQL Server;MTNUMRANGE=004;MTUID=0000383001;MTCLASS=100;MTINDEX=00
00001332;EXTINDEX=0000000484;',
          'AnalyseTool' => {
                             'DYNPRO' => {
                                           '6' => '1000',
                                           '3' => '1000',
                                           '7' => '1000',
                                           '2' => '1000',
                                           '8' => '1000',
                                           '1' => '1000',
                                           '4' => '1000',
                                           '0' => '1000',
                                           '5' => '1000'
                                         },
                             'UPDMODE' => {
                                            '6' => 'S',
                                            '3' => 'S',
                                            '7' => 'S',
                                            '2' => 'S',
                                            '8' => 'S',
                                            '1' => 'S',
                                            '4' => 'S',
                                            '0' => 'S',
                                            '5' => 'S'
                                          },
                             'DYNBEGIN' => {
                                             '6' => '',
                                             '3' => '',
                                             '7' => '',
                                             '2' => '',
                                             '8' => '',
                                             '1' => '',
                                             '4' => '',
                                             '0' => 'X',
                                             '5' => ''
                                           },
                             'TCODE' => {
                                          '6' => 'rz25',
                                          '3' => 'rz25',
                                          '7' => 'rz25',
                                          '2' => 'rz25',
                                          '8' => 'rz25',
                                          '1' => 'rz25',
                                          '4' => 'rz25',
                                          '0' => 'rz25',
                                          '5' => 'rz25'
                                        },
                             'FVAL' => {
                                         '6' => '0000000484',
                                         '3' => '0000383001',
                                         '7' => '020',
                                         '2' => '004',
                                         '8' => '\\BWD\\myhost_BWD_00\\...\\CPU\\Oldest blocked Spid',
                                         '1' => 'Microsoft SQL Server',
                                         '4' => '100',
                                         '0' => 'BWD',
                                         '5' => '0000001332'
                                       },
                             'DSPMODE' => {
                                            '6' => 'E',
                                            '3' => 'E',
                                            '7' => 'E',
                                            '2' => 'E',
                                            '8' => 'E',
                                            '1' => 'E',
                                            '4' => 'E',
                                            '0' => 'E',
                                            '5' => 'E'
                                          },
                             'FNAM' => {
                                         '6' => 'IN_TID-EXTINDEX',
                                         '3' => 'IN_TID-MTUID',
                                         '7' => 'WHICH_TOOL',
                                         '2' => 'IN_TID-MTNUMRANGE',
                                         '8' => 'MTE_NAME',
                                         '1' => 'IN_TID-MTMCNAME',
                                         '4' => 'IN_TID-MTCLASS',
                                         '0' => 'IN_TID-MTSYSID',
                                         '5' => 'IN_TID-MTINDEX'
                                       },
                             'PROGRAM' => {
                                            '6' => 'RSALTLEX',
                                            '3' => 'RSALTLEX',
                                            '7' => 'RSALTLEX',
                                            '2' => 'RSALTLEX',
                                            '8' => 'RSALTLEX',
                                            '1' => 'RSALTLEX',
                                            '4' => 'RSALTLEX',
                                            '0' => 'RSALTLEX',
                                            '5' => 'RSALTLEX'
                                          }
                           },
          'Tid' => {
                     'MTCLASS' => '100',
                     'MTUID' => '0000383001',
                     'EXTINDEX' => '0000000484',
                     'MTMCNAME' => 'Microsoft SQL Server',
                     'MTINDEX' => '0000001332',
                     'MTNUMRANGE' => '004',
                     'MTSYSID' => 'BWD'
                   },
          'AlTime' => '',
          'HighAlertValue' => 'GREEN'
        };


(...)

</pre>

### Step 2: 
<pre>
./check_sapcontrol.pl -H hostname --authfile /etc/icinga2/auth/hostname.auth  --match 'PrivMode Utilisation' --criteria description --critical 60 --warning 20

OK | percent=0%

function: GetAlertTree
criteria: description
ActualValue :  GREEN
AlDescription :
AlTime :
AnalyseToolString :  TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN=X;FNAM=IN_TID-MTSYSID;FVAL=BWD;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTMCNAME;FVAL=stechsv254_BWD_00;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTNUMRANGE;FVAL=010;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTUID;FVAL=0000008990;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTCLASS;FVAL=100;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-MTINDEX;FVAL=0000000260;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=IN_TID-EXTINDEX;FVAL=0000000150;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=WHICH_TOOL;FVAL=020;TCODE=rz25;DSPMODE=E;UPDMODE=S;PROGRAM=RSALTLEX;DYNPRO=1000;DYNBEGIN= ;FNAM=MTE_NAME;FVAL=\BWD\stechsv254_BWD_00\...\Dialog\PrivMode Utilisation
HighAlertValue :  GREEN
TidString :  MTSYSID=BWD;MTMCNAME=stechsv254_BWD_00;MTNUMRANGE=010;MTUID=0000008990;MTCLASS=100;MTINDEX=0000000260;EXTINDEX=0000000150;
Time :  2016 06 23 17
VisibleLevel :  DEVELOPER
description :  0 %
name :  PrivMode Utilisation
parent :  209
</pre>


## Example GetProcessList:

### Step 1: 

<pre>
 ./check_sapcontrol.pl  --hostname hostanme  --sid SID --authfile /etc/icinga2/auth/hostname.auth -F GetProcessList --dump
 
###########################
# $SAPControl->sapcontrol()
###########################
$VAR1 = '1';
$VAR2 = {
          'pid' => '4844',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'igswd.EXE',
          'description' => 'IGS Watchdog',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
$VAR3 = '0';
$VAR4 = {
          'pid' => '6988',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'disp+work.EXE',
          'description' => 'Dispatcher',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
$VAR5 = '3';
$VAR6 = {
          'pid' => '2736',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'icman',
          'description' => 'ICM',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
$VAR7 = '2';
$VAR8 = {
          'pid' => '6456',
          'textstatus' => 'Running',
          'starttime' => '2016 06 23 11',
          'name' => 'gwrd',
          'description' => 'Gateway',
          'elapsedtime' => '5',
          'dispstatus' => 'GREEN'
        };
</pre>

### Step 2:
<pre>
./check_sapcontrol.pl  --hostname hostname --sid SID  --authfile /etc/icinga2/auth/hostname.auth -F GetProcessList --description Gateway
OK - Running
function: GetProcessList
description :  Gateway
dispstatus :  GREEN
elapsedtime :  5
name :  gwrd
pid :  6456
starttime :  2016 06 23 11
textstatus :  Running
</pre>
