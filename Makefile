SDK_ROOT=C:\Gowin\Gowin_V1.9.8.05
GO_SH=${SDK_ROOT}/IDE/bin/gw_sh.exe
PROG=${SDK_ROOT}/Programmer/bin/programmer_cli.exe
MODGEN=${SDK_ROOT}/IDE/bin/GowinModGen.exe
FIND="C:\ProgramData\chocolatey\bin\find.exe"
PYTHON=python3
RM="C:\Program Files\Git\usr\bin\rm.exe"

TCL_SCRIPT=tiny_mcu.tcl
SOURCE=$(shell ${FIND} src -name "*.v")
MODS=mods/font.v mods/vram.v mods/color_palette.v mods/rpll.v mods/mcu_ram.v
MEM_INIT=resource/font.mi resource/vram.mi resource/palette.mi resource/mcu_ram.mi 
CONSTRAINTS=src/tang_nano_9k.cst src/tiny_mcu.sdc


OUTOPUT_FS=$(abspath impl/pnr/tiny_mcu.fs)
DEVICE=GW1NR-9C
# 2: program sram, 6: program flash
OPERA=2
CABLE=4
FREQ=2.5MHz

all: ${OUTOPUT_FS}

resource/vram.mi: resource/vram.py
	${PYTHON} $< > $@

resource/font.mi: resource/font.py
	${PYTHON} $< > $@

resource/palette.mi: resource/palette.py
	${PYTHON} $< > $@

resource/mcu_ram.mi: resource/mcu_ram.py
	${PYTHON} $< > $@

mods/font.v: mods/font.mod resource/font.mi 
	${MODGEN} -do $(abspath $<)
	
mods/vram.v: mods/vram.mod resource/vram.mi 
	${MODGEN} -do $(abspath $<)

mods/mcu_ram.v: mods/mcu_ram.mod resource/mcu_ram.mi 
	${MODGEN} -do $(abspath $<)

mods/color_palette.v: mods/color_palette.mod resource/palette.mi 
	${MODGEN} -do $(abspath $<)

mods/rpll.v: mods/rpll.mod
	${MODGEN} -do $(abspath $<)

${OUTOPUT_FS}: ${SOURCE} ${MODS} ${TCL_SCRIPT} ${CONSTRAINTS}
	${GO_SH} ${TCL_SCRIPT}

flash: all
	${PROG} --device ${DEVICE} --operation_index ${OPERA} --fsFile "${OUTOPUT_FS}" --cable-index ${CABLE} --frequency ${FREQ}

clean:
	${RM} -rf ${OUTOPUT_FS} ${MODS} ${MEM_INIT} impl

.PHONY: all clean flash