#!/usr/bin/perl -w

# Generate syscall.h, syscalltable.h, syscall.asm or usys.asm. These are the header and assembly
# files for system calls.
#
# Generating these files from one script avoids them getting out of sync. 
# 
# Specify an argument of -h to generate syscall.h
# Specify an argument of -c to generate syscalltable.h
# Specify an argument of -a to generate usys.asm
# Specify an argument of -i to generate syscall.asm
#
# Note that you also need to update user.h with the declarations for these functions that
# user programs will use.  This ensures that the C compiler generates the correct code to 
# push the parameters on to the stack. 

my @syscalls = (
				"fork", 
				"exit", 
				"wait", 
				"pipe", 
				"read", 
				"kill", 
				"exec", 
				"fstat",
				"dup", 
				"getpid",
				"sbrk", 
				"sleep", 
				"uptime", 
				"open", 
				"write", 
				"close",
				"chdir",
				"getcwd"
			   );

my $i;			   
if ($#ARGV == -1)
{
	print 'Error: No argument supplied to syscalls.pl';
	exit(1);
}
if (($ARGV[0] ne '-h') && ($ARGV[0] ne '-a') && ($ARGV[0] ne '-c') && ($ARGV[0] ne '-i'))
{
	print 'Error: Invalid argument to syscalls.pl';
	exit(1);
}
if ($ARGV[0] eq '-h'|| $ARGV[0] eq '-c')
{
	print "// Generated by syscalls.pl.  Do not edit.\n";
	print "// To change syscall numbers or add new syscalls, edit syscalls.pl\n";
	print "\n";
}
else
{
	print "; Generated by syscalls.pl.  Do not edit.\n";
	print "; To change syscall numbers or add new syscalls, edit syscalls.pl\n";
	print "\n";
}
for ($i = 0; $i < scalar(@syscalls); $i++)
{
	my $index = $i + 1;
	if ($ARGV[0] eq '-h')
	{
		print "#define SYS_$syscalls[$i]\t\t$index\n";
	}
	elsif ($ARGV[0] eq '-c')
	{
		print "extern int sys_$syscalls[$i](void);\n";
	}
	elsif ($ARGV[0] eq '-i')
	{
		print "\%assign SYS_$syscalls[$i]\t\t$index\n";	
	}
}
if ($ARGV[0] eq '-a')
{
	print "%include \"syscall.asm\"\n";
	print "\n";
	print "\%macro SYSCALL 1\n";
	print "global _\%1\n"; 
	print "_\%1:\n"; 
    print "\tmov\teax, SYS_\%1\n"; 
    print "\tint\t64\n"; 
    print "\tret\n";
	print "\n";
	print "\%endmacro\n";
	print "\n";
	for ($i = 0; $i < scalar(@syscalls); $i++)
	{
		print "SYSCALL $syscalls[$i]\n";
	}
}
elsif ($ARGV[0] eq '-c')
{
	print "\n";
	print "static int(*syscalls[])(void) = {\n";
	for ($i = 0; $i < scalar(@syscalls); $i++)
	{
		print "[SYS_$syscalls[$i]]\tsys_$syscalls[$i],\n";
	}
	print "};\n"
}
