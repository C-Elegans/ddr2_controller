VPATH = ../rtl:../rtl/IP

dump.vcd: a.out
	vvp a.out

a.out: controller.v controller_tb.v ddr2.v ddr2_mcp.v ddrbank.v ODDR.v IOBUF.v IDDR.v
	iverilog -I ../rtl -DSIM -s controller_tb $^ 

clean:
	rm -f a.out
	rm -f dump.vcd
