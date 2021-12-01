VFLAGS= -Wall -g2005

mii: verilog/mii_tb.v verilog/mii.v
	iverilog $(VFLAGS) -Iverilog -o $@ $^
	@./$@
	@rm $@


mii2mii: verilog/mii2mii_top_tb.v verilog/mii2mii_top.v verilog/mii.v
	iverilog $(VFLAGS) -Iverilog -o $@ $^
	@./$@
	@rm $@


.PHONY: xst ngdbuild map par trce bitgen sim program clean

xst:
	cd synth && xst -intstyle ise -ifn RGMIIulator_top.xst -ofn RGMIIulator_top.syr

ngdbuild:
	cd synth && ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc ../numatoMimas.ucf -p xc6slx9-tqg144-2 RGMIIulator_top.ngc RGMIIulator_top.ngd

map:
	cd synth && map -intstyle ise -p xc6slx9-tqg144-2 -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o RGMIIulator_top_map.ncd RGMIIulator_top.ngd RGMIIulator_top.pcf

par:
	cd synth && par -w -intstyle ise -ol high -mt off RGMIIulator_top_map.ncd RGMIIulator_top.ncd RGMIIulator_top.pcf

trce:
	cd synth && trce -intstyle ise -v 3 -s 2 -n 3 -fastpaths -xml RGMIIulator_top.twx RGMIIulator_top.ncd -o RGMIIulator_top.twr RGMIIulator_top.pcf

bitgen:
	cd synth && bitgen -intstyle ise -f RGMIIulator_top.ut RGMIIulator_top.ncd


program:
	openocd \
	-f /usr/local/share/openocd/scripts/interface/altera-usb-blaster.cfg \
	-f /usr/local/share/openocd/scripts/cpld/xilinx-xc6s.cfg \
	-c "init; xc6s_program xc6s.tap; pld load 0 ./synth/MIIulatorTop.bit ; exit"

clean:
	rm *.vcd a.out

