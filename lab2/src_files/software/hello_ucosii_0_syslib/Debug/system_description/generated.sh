#!/bin/sh
#
# generated.sh - shell script fragment - not very useful on its own
#
# Machine generated for a CPU named "cpu" as defined in:
# /home/hendrik/uni/ms1/embedded_systems/labs/src/lab2/src_files/software/hello_ucosii_0_syslib/../../DE2_Nios2_Lab2.ptf
#
# Generated: 2014-09-25 16:45:43.491

# DO NOT MODIFY THIS FILE
#
#   Changing this file will have subtle consequences
#   which will almost certainly lead to a nonfunctioning
#   system. If you do modify this file, be aware that your
#   changes will be overwritten and lost when this file
#   is generated again.
#
# DO NOT MODIFY THIS FILE

# This variable indicates where the PTF file for this design is located
ptf=/home/hendrik/uni/ms1/embedded_systems/labs/src/lab2/src_files/software/hello_ucosii_0_syslib/../../DE2_Nios2_Lab2.ptf

# This variable indicates whether there is a CPU debug core
nios2_debug_core=yes

# This variable indicates how to connect to the CPU debug core
nios2_instance=0

# This variable indicates the CPU module name
nios2_cpu_name=cpu

# Include operating system specific parameters, if they are supplied.

if test -f /home/hendrik/applications/altera/nios2eds/components/micrium_uc_osii/build/os.sh ; then
   . /home/hendrik/applications/altera/nios2eds/components/micrium_uc_osii/build/os.sh
fi
