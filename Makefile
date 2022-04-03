SDK_ROOT=C:\Gowin\Gowin_V1.9.8.05
GO_SH=${SDK_ROOT}\IDE\bin\gw_sh.exe
PROG=${SDK_ROOT}\Programmer\bin\programmer_cli.exe
PWD=$(shell pwd)

TCL_SCRIPT=tiny_mcu.tcl
#SOURCE=$(shell find src -name "*.v")

OUTOPUT_FS=$(abspath impl/pnr/tiny_mcu.fs)
DEVICE=GW1NZ-1
# 2: program sram, 6: program flash
OPERA=2
CABLE=4
FREQ=2MHz


all: ${OUTOPUT_FS}

${OUTOPUT_FS}: ${SOURCE} ${TCL_SCRIPT}
	${GO_SH} ${TCL_SCRIPT}

flash:
	${PROG} --device ${DEVICE} --operation_index ${OPERA} --fsFile "${OUTOPUT_FS}" --cable-index ${CABLE} --frequency ${FREQ}