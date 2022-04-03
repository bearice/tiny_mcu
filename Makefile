SDK_ROOT=C:\Gowin\Gowin_V1.9.8.05
GO_SH=${SDK_ROOT}/IDE/bin/gw_sh.exe
PROG=${SDK_ROOT}/Programmer/bin/programmer_cli.exe
MODGEN=${SDK_ROOT}/IDE/bin/GowinModGen.exe
FIND="C:\ProgramData\chocolatey\bin\find.exe"
PYTHON=python3
RM="C:\Program Files\Git\usr\bin\rm.exe"

TCL_SCRIPT=tiny_mcu.tcl
SOURCE=$(shell ${FIND} src -name "*.v")
MODS=mods/font.v mods/vram.v mods/color_palette.v mods/rpll.v
MEM_INIT=resource/font.mi resource/vram.mi resource/palette.mi 

OUTOPUT_FS=$(abspath impl/pnr/tiny_mcu.fs)
DEVICE=GW1NZ-1
# 2: program sram, 6: program flash
OPERA=2
CABLE=4
FREQ=2MHz

all: ${OUTOPUT_FS}

resource/vram.mi: resource/vram.py
	${PYTHON} $< > $@

resource/font.mi: resource/font.py
	${PYTHON} $< > $@

resource/palette.mi: resource/palette.py
	${PYTHON} $< > $@

mods/font.v: mods/font.mod resource/font.mi 
	${MODGEN} -do $(abspath $<)
	
mods/vram.v: mods/vram.mod resource/vram.mi 
	${MODGEN} -do $(abspath $<)

mods/color_palette.v: mods/color_palette.mod resource/palette.mi 
	${MODGEN} -do $(abspath $<)

mods/rpll.v: mods/rpll.mod
	${MODGEN} -do $(abspath $<)

${OUTOPUT_FS}: ${SOURCE} ${MODS} ${TCL_SCRIPT}
	${GO_SH} ${TCL_SCRIPT}

flash: all
	${PROG} --device ${DEVICE} --operation_index ${OPERA} --fsFile "${OUTOPUT_FS}" --cable-index ${CABLE} --frequency ${FREQ}

clean:
	${RM} -f ${OUTOPUT_FS} ${MODS} ${MEM_INIT}

.PHONY: all clean flash