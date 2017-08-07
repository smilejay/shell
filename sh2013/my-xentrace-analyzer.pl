#!/usr/bin/perl

#    Copyright Xingchang Jiang <xingchang.jiang@intel.com>. GPL.
#    Perform x86 xentrace raw data analysis.
#    Many thanks to Yang Xiaowei's review <xiaowei.yang@intel.com>
#    Modified by: Yongjie Ren <yongjie.ren@intel.com> , 2013

#    some usage example steps:
#    # start Xen HVM guest before this tracing
#    [root@jay-linux ~]# xentrace -D -e 0x81000 -T 30 trace.data
#    [root@jay-linux ~]# cat trace.data | xentrace_format xen.git/tools/xentrace/formats | ./my-xentrace-analyzer.pl

my @VM_ENTYR;
my @VM_SUB;
my @XEN_ERROR;
my @GUEST_ERROR;
my @left;
my @VECTOR;

my $cpuid;
my $tsc;
my $diff;
my $flag;
my $starttsc;
my $endtsc;
my $tscdiff;
my $totaltsc;
my $total_count;
my $generate_table;
my $sub_table;
my $exit_flag;
my $startcpuid;
my $endcpuid;
my $typeid;
my $errorcode;
my $vector;
my $subtypeid;
my $useless;
my $start;
my $end;
my $startlag;

# change this frequency to your actual freq of your running CPU
my $freq = 2693574000;

# the following defination is from Intel SDM 3C Appendix C "VMX Basic Exit Reasons"
$VM_ENTRY[0] = ["NMI or Exception"];
$VM_ENTRY[1] = ["External Interrupt"];
$VM_ENTRY[2] = ["Triple fault"];
$VM_ENTRY[3] = ["Init signal"];
$VM_ENTRY[4] = ["Startup IPI"];
$VM_ENTRY[5] = ["I/O SMI"];
$VM_ENTRY[6] = ["Other SMI"];
$VM_ENTRY[7] = ["Interrupt window"];
$VM_ENTRY[8] = ["nmi window"];
$VM_ENTRY[9] = ["Task Switch"];
$VM_ENTRY[10] = ["CPUID"];
$VM_ENTRY[11] = ["getsec"];
$VM_ENTRY[12] = ["HLT"];
$VM_ENTRY[13] = ["INVD"];
$VM_ENTRY[14] = ["INVLPG"];
$VM_ENTRY[15] = ["RDPMC"];
$VM_ENTRY[16] = ["RDTSC"];
$VM_ENTRY[17] = ["RSM"];
$VM_ENTRY[18] = ["VMCALL"];
$VM_ENTRY[19] = ["VMCLEAR"];
$VM_ENTRY[20] = ["VMLAUNCH"];
$VM_ENTRY[21] = ["VMPTRLD"];
$VM_ENTRY[22] = ["VMPTRST"];
$VM_ENTRY[23] = ["VMREAD"];
$VM_ENTRY[24] = ["VMRESUME"];
$VM_ENTRY[25] = ["VMWRITE"];
$VM_ENTRY[26] = ["VMXOFF"];
$VM_ENTRY[27] = ["VMXON"];
$VM_ENTRY[28] = ["CR access"];
$VM_ENTRY[29] = ["MOV DR"];
$VM_ENTRY[30] = ["I/O Instruction"];
$VM_ENTRY[31] = ["RDMSR"];
$VM_ENTRY[32] = ["WRMSR"];
$VM_ENTRY[33] = ["VM-entry failure due to invalid guest state"];
$VM_ENTRY[34] = ["VM-entry failure due to MSR loading"];
$VM_ENTRY[35] = [""];
$VM_ENTRY[36] = ["MWAIT"];
$VM_ENTRY[37] = ["monitor trap"];
$VM_ENTRY[38] = [""];
$VM_ENTRY[39] = ["MONITOR"];
$VM_ENTRY[40] = ["PAUSE"];
$VM_ENTRY[41] = ["VM-entry failure due to machine check"];
$VM_ENTRY[42] = [""];
$VM_ENTRY[43] = ["TPR below threshold"];
$VM_ENTRY[44] = ["APIC access"];
$VM_ENTRY[45] = ["Virtualized EOI"];
$VM_ENTRY[46] = ["Access GDTR/IDTR"];
$VM_ENTRY[47] = ["Access LDTR/TR"];
$VM_ENTRY[48] = ["EPT violation"];
$VM_ENTRY[49] = ["EPT misconfiguration"];
$VM_ENTRY[50] = ["invept"];
$VM_ENTRY[51] = ["rdtscp"];
$VM_ENTRY[52] = ["vmx-preemption timer expired"];
$VM_ENTRY[53] = ["invvpid"];
$VM_ENTRY[54] = ["wbinvd"];
$VM_ENTRY[55] = ["xsetbv"];
$VM_ENTRY[56] = ["APIC write"];
$VM_ENTRY[57] = ["rdrand"];
$VM_ENTRY[58] = ["invpcid"];
$VM_ENTRY[59] = ["vmfunc"];

$VM_SUB[0] = ["PF_XEN"];
$VM_SUB[1] = ["PF_INJECT"];
$VM_SUB[2] = ["INJ_EXC"];
$VM_SUB[3] = ["INJ_VIRQ"];
$VM_SUB[4] = ["REINJ_VIRQ"];
$VM_SUB[5] = ["IO_READ"];
$VM_SUB[6] = ["IO_WRITE"];
$VM_SUB[7] = ["CR_READ"];
$VM_SUB[8] = ["CR_WRITE"];
$VM_SUB[9] = ["DR_READ"];
$VM_SUB[10] = ["DR_WRITE"];
$VM_SUB[11] = ["MSR_READ"];
$VM_SUB[12] = ["MSR_WRITE"];
$VM_SUB[13] = ["CPUID"];
$VM_SUB[14] = ["INTR"];
$VM_SUB[15] = ["NMI"];
$VM_SUB[16] = ["SMI"];
$VM_SUB[17] = ["VMMCALL"];
$VM_SUB[18] = ["HLT"];
$VM_SUB[19] = ["INVLPG"];
$VM_SUB[20] = ["NODEVICE"];
$VM_SUB[21] = ["GUEST_FAULT"];

my $SHADOW_FAULT_count = 0;
my $SHADOW_FAULT_totaltime = 0;
#Error code of PAGE_FAULT
#
#THE FAULT WAS CAUSED BY A NOT-PRESENT PAGE.
#THE ACCESS CAUSING THE FAULT WAS A READ.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN SUPERVISOR MODE.
my $PAGE_FAULT_ERROR_CODE0_count = 0;
my $PAGE_FAULT_ERROR_CODE0_totaltime = 0;
#THE FAULT WAS CAUSED BY A PAGE-LEVEL PROTECTION VIOLATION.
#THE ACCESS CAUSING THE FAULT WAS A READ.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN SUPERVISOR MODE.
my $PAGE_FAULT_ERROR_CODE1_count = 0;
my $PAGE_FAULT_ERROR_CODE1_totaltime = 0;
#THE FAULT WAS CAUSED BY A NOT-PRESENT PAGE.
#THE ACCESS CAUSING THE FAULT WAS A WRITE.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN SUPERVISOR MODE.
my $PAGE_FAULT_ERROR_CODE2_count = 0;
my $PAGE_FAULT_ERROR_CODE2_totaltime = 0;
#THE FAULT WAS CAUSED BY A PAGE-LEVEL PROTECTION VIOLATION.
#THE ACCESS CAUSING THE FAULT WAS A WRITE.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN USER MODE.
my $PAGE_FAULT_ERROR_CODE3_count = 0;
my $PAGE_FAULT_ERROR_CODE3_totaltime = 0;
#THE FAULT WAS CAUSED BY A NOT-PRESENT PAGE.
#THE ACCESS CAUSING THE FAULT WAS A READ.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN USER MODE.
my $PAGE_FAULT_ERROR_CODE4_count = 0;
my $PAGE_FAULT_ERROR_CODE4_totaltime = 0;
#THE FAULT WAS CAUSED BY A PAGE-LEVEL PROTECTION VIOLATION.
#THE ACCESS CAUSING THE FAULT WAS A READ.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN USER MODE.
my $PAGE_FAULT_ERROR_CODE5_count = 0;
my $PAGE_FAULT_ERROR_CODE5_totaltime = 0;
#THE FAULT WAS CAUSED BY A NOT-PRESENT PAGE.
#THE ACCESS CAUSING THE FAULT WAS A WRITE.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN USER MODE.
my $PAGE_FAULT_ERROR_CODE6_count = 0;
my $PAGE_FAULT_ERROR_CODE6_totaltime = 0;
#THE FAULT WAS CAUSED BY A PAGE-LEVEL PROTECTION VIOLATION.
#THE ACCESS CAUSING THE FAULT WAS A WRITE.
#THE ACCESS CAUSING THE FAULT ORIGINATED WHEN THE
#PROCESSOR WAS EXECUTING IN USER MODE.
my $PAGE_FAULT_ERROR_CODE7_count = 0;
my $PAGE_FAULT_ERROR_CODE7_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE8_count = 0;
my $PAGE_FAULT_ERROR_CODE8_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE9_count = 0;
my $PAGE_FAULT_ERROR_CODE9_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE10_count = 0;
my $PAGE_FAULT_ERROR_CODE10_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE11_count = 0;
my $PAGE_FAULT_ERROR_CODE11_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE12_count = 0;
my $PAGE_FAULT_ERROR_CODE12_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE13_count = 0;
my $PAGE_FAULT_ERROR_CODE13_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE14_count = 0;
my $PAGE_FAULT_ERROR_CODE14_totaltime = 0;

my $PAGE_FAULT_ERROR_CODE15_count = 0;
my $PAGE_FAULT_ERROR_CODE15_totaltime = 0;

#other cases
my $PAGE_FAULT_ERROR_CODE16_count = 0;
my $PAGE_FAULT_ERROR_CODE16_totaltime = 0;


for ($i=0;$i<256;$i++){
	$VECTOR[$i]->[0]=$i;
}

$generate_table = undef;
$exit_flag = 0;
$startflag = 0;
$errorcode = -1;
$port = -1;
$intr = 0;

$sub_table = $VM_SUB[5];
for($i=0;$i<65536;$i++)
{
	$sub_table->[$i] = 0;
}

$sub_table = $VM_SUB[6];
for($i=0;$i<65536;$i++)
{
	$sub_table->[$i] = 0;
}

while ( <> ) {
	chomp;
	($cpuid, $tsc, $diff, $useless, $flag, @left) = split /\s+/;
	if ($flag eq "VMENTRY") {
		next if($exit_flag != 1);
		$exit_flag = 0;

		$endtsc = $tsc;
		$end = $tsc;
		$tscdiff = $endtsc - $starttsc;
		$totaltsc += $tscdiff;
		$totalcount += 1;
		$generate_table->[1] += $tscdiff;
		$generate_table->[2] += 1;

		next if(! defined $sub_table);

		if($intr == 1) {
			$sub_table->[1] += $tscdiff;
			$sub_table->[2] += 1;
			$intr = 0;
		}
		elsif($errorcode >= 0) {
			$sub_table->[1] += $tscdiff;
			$sub_table->[2] += 1;
			update_errorcode($errorcode,$tscdiff);
			$errorcode = -1;
	 	}
		elsif($port != -1) {
	 		$sub_table->[$port] += 1;
			$port = -1;
	 	}
		else {
			$sub_table->[1] += $tscdiff;
			$sub_table->[2] += 1;
		}
	}
        # If there are lost records, restart from next VMEXIT
        elsif ($flag eq "lost_records") {
                printf("lost_records...\n");
		$exit_flag = 0;
        }
	elsif ($flag eq "VMEXIT") {
		$typeid = get_typeid(\@left);
		$generate_table = $VM_ENTRY[$typeid];
		$starttsc = $tsc;
		$exit_flag = 1;
		$sub_table = undef;
		if ($startflag == 0) {
			$start = $tsc;
			$startflag = 1;
		}
	}
	elsif ($flag eq "PF_XEN") {
		$sub_table = $VM_SUB[0];
		$errorcode = get_errorcode(\@left);
	}
	elsif ($flag eq "INTR") {
		$vector = get_vector(\@left);
		$sub_table = $VECTOR[$vector];
		$intr = 1;
	}
	elsif ($flag eq "IO_READ") {
		$port = get_port(\@left);
		$sub_table = $VM_SUB[5];
	}
	elsif ($flag eq "IO_WRITE") {
		$port = get_port(\@left);
		$sub_table = $VM_SUB[6];
	}
	elsif ($flag eq "NODEVICE") {
		$sub_table = $VM_SUB[20];
	}
	elsif ($flag eq "GUEST_FAULT") {
		$sub_table = $VM_SUB[21];
	}
}

&generate_report;

sub generate_report {
	my $i;
	printf("Start record TSC: %d\nEnd record TSC: %d\nTSC Offset: %d (%.2fs)\n\n",$start,$end,$end-$start,($end-$start)/$freq);
	printf("VMExit TSC: %d\nTSC Ratio: %.2f\n\nVMExit Count: %d\n", $totaltsc, ($totaltsc/($end-$start)),$totalcount);
	printf("%20s%15s%15s%15s%15s%15s\n","Type","Total TSC","TSC Ratio","Total Count","Count Ratio","Avg TSC");
	for ($i=0; $i<60; $i++) {
		$generate_table=$VM_ENTRY[$i];

		next if ($generate_table->[0] eq "");
		next if ($generate_table->[2] == 0);
		if (defined $generate_table->[2]) {
			printf("%20s%15d%15.2f%15d%15.2f%15d\n", $generate_table->[0], $generate_table->[1], $generate_table->[1]/$totaltsc, $generate_table->[2], $generate_table->[2]/$totalcount, $generate_table->[1]/$generate_table->[2]);
		}
		else {
			printf("%20s%15d%15.2f%15d%15.2f%15d\n", $generate_table->[0], $generate_table->[1], $generate_table->[1]/$totaltsc, $generate_table->[2], $generate_table->[2]/$totalcount, 0);
		}
	}

	$generate_table = $VM_ENTRY[0];
	$sub_table = $VM_SUB[0];
	if ($generate_table->[1] !=0) {
		printf("\n\nPF_XEN:\ncounts:%d\t\tTSC:%d\t\tTSC ratio of NMI/Exception=%.2f\n",$sub_table->[2],$sub_table->[1],$sub_table->[1]/$generate_table->[1]);
	}

	printf("\n\nPAGE_FAULT_CODE details:\n");
	printf("CODE\t\tTSC\tCount\tTSC ratio\tAverage TSC\n");
	if($PAGE_FAULT_ERROR_CODE0_count != 0){
		printf("0: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE0_totaltime,$PAGE_FAULT_ERROR_CODE0_count,$PAGE_FAULT_ERROR_CODE0_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE0_totaltime/$PAGE_FAULT_ERROR_CODE0_count);
	}
	if($PAGE_FAULT_ERROR_CODE1_count != 0){
		printf("1: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE1_totaltime,$PAGE_FAULT_ERROR_CODE1_count,$PAGE_FAULT_ERROR_CODE1_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE1_totaltime/$PAGE_FAULT_ERROR_CODE1_count);
	}
	if($PAGE_FAULT_ERROR_CODE2_count != 0){
		printf("2: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE2_totaltime,$PAGE_FAULT_ERROR_CODE2_count,$PAGE_FAULT_ERROR_CODE2_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE2_totaltime/$PAGE_FAULT_ERROR_CODE2_count);
	}
	if($PAGE_FAULT_ERROR_CODE3_count != 0){
		printf("3: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE3_totaltime,$PAGE_FAULT_ERROR_CODE3_count,$PAGE_FAULT_ERROR_CODE3_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE3_totaltime/$PAGE_FAULT_ERROR_CODE3_count);
	}
	if($PAGE_FAULT_ERROR_CODE4_count != 0){
		printf("4: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE4_totaltime,$PAGE_FAULT_ERROR_CODE4_count,$PAGE_FAULT_ERROR_CODE4_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE4_totaltime/$PAGE_FAULT_ERROR_CODE4_count);
	}
	if($PAGE_FAULT_ERROR_CODE5_count != 0){
		printf("5: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE5_totaltime,$PAGE_FAULT_ERROR_CODE5_count,$PAGE_FAULT_ERROR_CODE5_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE5_totaltime/$PAGE_FAULT_ERROR_CODE5_count);
	}
	if($PAGE_FAULT_ERROR_CODE6_count != 0){
		printf("6: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE6_totaltime,$PAGE_FAULT_ERROR_CODE6_count,$PAGE_FAULT_ERROR_CODE6_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE6_totaltime/$PAGE_FAULT_ERROR_CODE6_count);
	}
	if($PAGE_FAULT_ERROR_CODE7_count != 0){
		printf("7: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE7_totaltime,$PAGE_FAULT_ERROR_CODE7_count,$PAGE_FAULT_ERROR_CODE7_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE7_totaltime/$PAGE_FAULT_ERROR_CODE7_count);
	}
	if($PAGE_FAULT_ERROR_CODE8_count != 0){
		printf("8: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE8_totaltime,$PAGE_FAULT_ERROR_CODE8_count,$PAGE_FAULT_ERROR_CODE8_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE8_totaltime/$PAGE_FAULT_ERROR_CODE8_count);
	}
	if($PAGE_FAULT_ERROR_CODE9_count != 0){
		printf("9: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE9_totaltime,$PAGE_FAULT_ERROR_CODE9_count,$PAGE_FAULT_ERROR_CODE9_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE9_totaltime/$PAGE_FAULT_ERROR_CODE9_count);
	}
	if($PAGE_FAULT_ERROR_CODE10_count != 0){
		printf("10: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE10_totaltime,$PAGE_FAULT_ERROR_CODE10_count,$PAGE_FAULT_ERROR_CODE10_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE10_totaltime/$PAGE_FAULT_ERROR_CODE10_count);
	}
	if($PAGE_FAULT_ERROR_CODE11_count != 0){
		printf("11: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE11_totaltime,$PAGE_FAULT_ERROR_CODE11_count,$PAGE_FAULT_ERROR_CODE11_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE11_totaltime/$PAGE_FAULT_ERROR_CODE11_count);
	}
	if($PAGE_FAULT_ERROR_CODE12_count != 0){
		printf("12: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE12_totaltime,$PAGE_FAULT_ERROR_CODE12_count,$PAGE_FAULT_ERROR_CODE12_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE12_totaltime/$PAGE_FAULT_ERROR_CODE12_count);
	}
	if($PAGE_FAULT_ERROR_CODE13_count != 0){
		printf("13: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE13_totaltime,$PAGE_FAULT_ERROR_CODE13_count,$PAGE_FAULT_ERROR_CODE13_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE13_totaltime/$PAGE_FAULT_ERROR_CODE13_count);
	}
	if($PAGE_FAULT_ERROR_CODE14_count != 0){
		printf("14: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE14_totaltime,$PAGE_FAULT_ERROR_CODE14_count,$PAGE_FAULT_ERROR_CODE14_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE14_totaltime/$PAGE_FAULT_ERROR_CODE14_count);
	}
	if($PAGE_FAULT_ERROR_CODE15_count != 0){
		printf("15: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE15_totaltime,$PAGE_FAULT_ERROR_CODE15_count,$PAGE_FAULT_ERROR_CODE15_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE15_totaltime/$PAGE_FAULT_ERROR_CODE15_count);
	}
	if($PAGE_FAULT_ERROR_CODE16_count != 0){
		printf("Others: \t%10d\t%6d\t%6.2f\t%15d\n",$PAGE_FAULT_ERROR_CODE16_totaltime,$PAGE_FAULT_ERROR_CODE16_count,$PAGE_FAULT_ERROR_CODE16_totaltime/$SHADOW_FAULT_totaltime,$PAGE_FAULT_ERROR_CODE16_totaltime/$PAGE_FAULT_ERROR_CODE16_count);
	}

        printf("\n\nGuest fault details:\n");
	printf("Total TSC\tcounts\tAverage TSC\n");
        $sub_table = $VM_SUB[21];
        if ($sub_table->[2] != 0) {
		printf("%10d\t%6d\t%15d\n", $sub_table->[1], $sub_table->[2], $sub_table->[1]/$sub_table->[2]);
        }

        printf("\n\nNo device details:\n");
	printf("Total TSC\tcounts\tAverage TSC\n");
        $sub_table = $VM_SUB[20];
        if ($sub_table->[2] != 0) {
		printf("%10d\t%6d\t%15d\n", $sub_table->[1], $sub_table->[2], $sub_table->[1]/$sub_table->[2]);
        }

	printf("\n\nInterrupt details:\n");
	printf("vector\tcounts\tcount ratio\tTSC\tTSC ratio\tAverage TSC\n");
	$generate_table = $VM_ENTRY[1];
	for($i=0;$i<256;$i++){
		$sub_table = $VECTOR[$i];
		next if ($sub_table->[2] eq undef);
		printf("#0x%x\t%5d\t%5.2f\t%10d\t%5.2f\t%15d\n",$sub_table->[0],$sub_table->[2],$sub_table->[2]/$generate_table->[2],$sub_table->[1],$sub_table->[1]/$generate_table->[1],$sub_table->[1]/$sub_table->[2]);
	}
	printf("\n\nIO details:\n");
	printf("IO read:\n");
	printf("port\tcounts\n");
	$sub_table = $VM_SUB[5];
	for($i=0;$i<65536;$i++){
		next if($sub_table->[$i] eq 0);
		printf("0x%x\t%d\n",$i,$sub_table->[$i]);
	}
	printf("\nIO write:\n");
	printf("port\tcounts\n");
	$sub_table = $VM_SUB[6];
	for($i=0;$i<65536;$i++){
		next if($sub_table->[$i] eq 0);
		printf("0x%x\t%d\n",$i,$sub_table->[$i]);
	}
}

sub get_typeid {
	my ($temp1, $temp2) = split /exitcode\ \=\ /, "@{$_[0]}";
	($temp1) = split /\ /, $temp2;
	return hex $temp1;
}

sub get_errorcode{
	my ($temp1, $temp2) = split /errorcode\ \=\ /, "@{$_[0]}";
	($temp1) = split /\ /, $temp2;
	return hex $temp1;
}

sub get_vector{
	my ($temp1, $temp2) = split /vector\ \=\ /,"@{$_[0]}";
	($temp1) = split /\ /, $temp2;
	return hex $temp1;
}

sub get_port{
	my ($temp1, $temp2) = split /port\ \=\ /,"@{$_[0]}";
	($temp1) = split /\,/, $temp2;
	return hex $temp1;
}


sub update_errorcode{
	my $code = $_[0];
	my $time = $_[1];

	$SHADOW_FAULT_count += 1;
	$SHADOW_FAULT_totaltime += $time;

	if($code eq 0){
		$PAGE_FAULT_ERROR_CODE0_count += 1;
		$PAGE_FAULT_ERROR_CODE0_totaltime += $time;
	}
	elsif($code eq 1){
		$PAGE_FAULT_ERROR_CODE1_count += 1;
		$PAGE_FAULT_ERROR_CODE1_totaltime += $time;
	}
	elsif($code eq 2){
		$PAGE_FAULT_ERROR_CODE2_count += 1;
		$PAGE_FAULT_ERROR_CODE2_totaltime += $time;
	}
	elsif($code eq 3){
		$PAGE_FAULT_ERROR_CODE3_count += 1;
		$PAGE_FAULT_ERROR_CODE3_totaltime += $time;
	}
	elsif($code eq 4){
		$PAGE_FAULT_ERROR_CODE4_count += 1;
		$PAGE_FAULT_ERROR_CODE4_totaltime += $time;
	}
	elsif($code eq 5){
		$PAGE_FAULT_ERROR_CODE5_count += 1;
		$PAGE_FAULT_ERROR_CODE5_totaltime += $time;
	}
	elsif($code eq 6){
		$PAGE_FAULT_ERROR_CODE6_count += 1;
		$PAGE_FAULT_ERROR_CODE6_totaltime += $time;
	}
	elsif($code eq 7){
		$PAGE_FAULT_ERROR_CODE7_count += 1;
		$PAGE_FAULT_ERROR_CODE7_totaltime += $time;
	}
	elsif($code eq 8){
		$PAGE_FAULT_ERROR_CODE8_count += 1;
		$PAGE_FAULT_ERROR_CODE8_totaltime += $time;
	}
	elsif($code eq 9){
		$PAGE_FAULT_ERROR_CODE9_count += 1;
		$PAGE_FAULT_ERROR_CODE9_totaltime += $time;
	}
	elsif($code eq 10){
		$PAGE_FAULT_ERROR_CODE10_count += 1;
		$PAGE_FAULT_ERROR_CODE10_totaltime += $time;
	}
	elsif($code eq 11){
		$PAGE_FAULT_ERROR_CODE11_count += 1;
		$PAGE_FAULT_ERROR_CODE11_totaltime += $time;
	}
	elsif($code eq 12){
		$PAGE_FAULT_ERROR_CODE12_count += 1;
		$PAGE_FAULT_ERROR_CODE12_totaltime += $time;
	}
	elsif($code eq 13){
		$PAGE_FAULT_ERROR_CODE13_count += 1;
		$PAGE_FAULT_ERROR_CODE13_totaltime += $time;
	}
	elsif($code eq 14){
		$PAGE_FAULT_ERROR_CODE14_count += 1;
		$PAGE_FAULT_ERROR_CODE14_totaltime += $time;
	}
	elsif($code eq 15){
		$PAGE_FAULT_ERROR_CODE15_count += 1;
		$PAGE_FAULT_ERROR_CODE15_totaltime += $time;
	}
	else{
		$PAGE_FAULT_ERROR_CODE16_count += 1;
		$PAGE_FAULT_ERROR_CODE16_totaltime += $time;
	}
}
