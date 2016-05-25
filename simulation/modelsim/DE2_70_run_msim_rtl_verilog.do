transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/to300/GIT/ECE4063_Merlin_Tom_Project/Testbench {C:/Users/to300/GIT/ECE4063_Merlin_Tom_Project/Testbench/testbench_Histogram.v}
vlog -vlog01compat -work work +incdir+C:/Users/to300/GIT/ECE4063_Merlin_Tom_Project {C:/Users/to300/GIT/ECE4063_Merlin_Tom_Project/Histo.v}
vlog -vlog01compat -work work +incdir+C:/Users/to300/GIT/ECE4063_Merlin_Tom_Project {C:/Users/to300/GIT/ECE4063_Merlin_Tom_Project/SRAM.v}

