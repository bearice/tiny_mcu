# ISA Overview

This document describes a 16-bit microcontroller ISA (Instruction Set Architecture). Key features include:

*   **16-bit Instructions:** All instructions are 16 bits wide.
*   **16 General-Purpose Registers:** It uses 16 general-purpose registers (R0-R15), with specific roles assigned to R12-R15 (FLG, LR, SP, PC).
*   **OpFamily Field:** The primary instruction category and format are determined by the top 4 bits of the instruction, `ir[15:12]` (OpFamily).
*   **2-Operand Destructive ALU:** All Arithmetic Logic Unit (ALU) operations are 2-operand and destructive, meaning the result of an operation overwrites one of the source registers.

## Registers

There are 16 general-purpose 16-bit registers, R0 through R15.

*   **R0-R11:** General-purpose registers.
*   **R12 (FLG):** Flag Register. Stores CPU flags like Carry (C), Zero (Z), Sign (S), Overflow (O). The lower 8 bits are typically used: `{C,Z,S,O,0,0,0,0}` where C is bit 0. This register is updated implicitly by ALU operations.
*   **R13 (LR):** Link Register. Used by the JAL (Jump and Link) instruction to store the return address (PC+1).
*   **R14 (SP):** Stack Pointer. Used to manage the runtime stack. Its usage (e.g., growing direction) is by convention.
*   **R15 (PC):** Program Counter. Always holds the address of the next instruction to be fetched and executed.

## Instruction Set Architecture

All instructions are 16-bit wide. The `OpFam[3:0]` field (`ir[15:12]`) is the primary opcode that determines the instruction category and format.

### Category 1: ALU Register-Register Operations (OpFamily `0000`, `0001`)

Instructions in this category perform arithmetic and logical operations between two registers, where the result overwrites the first source register (Rx_dst_s1).

**Format:** `OpFam[15:12] OpSpecific[11:8] Rx_dst_s1[7:4] Ry_s2[3:0]`

*   `OpFam[15:12]`: Defines the instruction category (e.g., `0000` for primary R-R ALU).
*   `OpSpecific[11:8]`: Specifies the particular ALU operation (e.g., ADD, SUB).
*   `Rx_dst_s1[7:4]`: Specifies the destination register which also serves as the first source operand (R0-R14).
*   `Ry_s2[3:0]`: Specifies the second source operand register (R0-R14).

**OpFamily `0000`:**

*   **`0000 0001 Rx Ry`**: `ADD Rx, Ry`
    *   Action: `Rx <= Rx + Ry`
    *   Updates FLG (R12).
*   **`0000 0010 Rx Ry`**: `SUB Rx, Ry`
    *   Action: `Rx <= Rx - Ry`
    *   Updates FLG (R12).
*   **`0000 0011 Rx Ry`**: `AND Rx, Ry`
    *   Action: `Rx <= Rx & Ry`
    *   Updates FLG (R12).
*   **`0000 0100 Rx Ry`**: `OR  Rx, Ry`
    *   Action: `Rx <= Rx | Ry`
    *   Updates FLG (R12).
*   **`0000 0101 Rx Ry`**: `XOR Rx, Ry`
    *   Action: `Rx <= Rx ^ Ry`
    *   Updates FLG (R12).
*   **`0000 0110 Rx Ry`**: `SHL Rx, Ry` (Logical Shift Left)
    *   Action: `Rx <= Rx << Ry[3:0]` (Shift amount from lower 4 bits of Ry)
    *   Updates FLG (R12).
*   **`0000 0111 Rx Ry`**: `SHR Rx, Ry` (Logical Shift Right)
    *   Action: `Rx <= Rx >> Ry[3:0]` (Shift amount from lower 4 bits of Ry)
    *   Updates FLG (R12).
*   **`0000 1000 Rx Ry`**: `MUL Rx, Ry`
    *   Action: `Rx <= Rx * Ry`
    *   Updates FLG (R12).

**OpFamily `0001`:** Reserved for additional Register-Register ALU operations (e.g., signed shifts, division, modulo).

### Category 2: ALU Register-Immediate Operations (OpFamily `0010` - `0101`)

Instructions in this category perform arithmetic and logical operations between a register and an 8-bit immediate value. The result overwrites the source register (Rx_dst_s1).

**Format:** `OpFam[15:12] Rx_dst_s1[11:8] Imm[7:0]`

*   `OpFam[15:12]`: Defines the ALU operation type (e.g., `0010` for ADDI).
*   `Rx_dst_s1[11:8]`: Specifies the destination register which also serves as the source operand (R0-R14).
*   `Imm[7:0]`: Specifies the 8-bit immediate value (`ir[7:0]`).

**Instructions:**

*   **`0010 Rx Imm8`**: `ADDI Rx, imm8` (Add Immediate)
    *   Action: `Rx <= Rx + sign_extend(imm8)`
    *   Updates FLG (R12).
*   **`0011 Rx Imm8`**: `ANDI Rx, imm8` (AND Immediate)
    *   Action: `Rx <= Rx & zero_extend(imm8)`
    *   Updates FLG (R12).
*   **`0100 Rx Imm8`**: `ORI  Rx, imm8` (OR Immediate)
    *   Action: `Rx <= Rx | zero_extend(imm8)`
    *   Updates FLG (R12).
*   **`0101 Rx Imm8`**: `XORI Rx, imm8` (XOR Immediate)
    *   Action: `Rx <= Rx ^ zero_extend(imm8)`
    *   Updates FLG (R12).

*(OpFamilies `0110`, `0111` are reserved for additional Register-Immediate ALU operations).*

### Category 3: Load/Store Operations (OpFamily `1000`, `1001`)

These instructions are used to transfer data between registers and memory.

**LOAD Operation:**

*   **`1000 Rt[11:8] Rs_addr[7:4] Imm[3:0]`**: `LOAD Rt, imm4_offset(Rs_addr)` (Load Word)
    *   Action: `Rt <= MEM[Rs_addr + zero_extend(imm4)]`. The immediate is a 4-bit unsigned byte offset.
    *   `Rt` (destination, R0-R14) is specified by `ir[11:8]`.
    *   `Rs_addr` (base address register, R0-R14) is specified by `ir[7:4]`.
    *   `Imm[3:0]` (4-bit unsigned offset) is `ir[3:0]`.

**STORE Operation:**

*   **`1001 Rt_data[11:8] Rs_addr[7:4] Imm[3:0]`**: `STORE Rt_data, imm4_offset(Rs_addr)` (Store Word)
    *   Action: `MEM[Rs_addr + zero_extend(imm4)] <= Rt_data`. The immediate is a 4-bit unsigned byte offset.
    *   `Rt_data` (source data register, R0-R14) is specified by `ir[11:8]`.
    *   `Rs_addr` (base address register, R0-R14) is specified by `ir[7:4]`.
    *   `Imm[3:0]` (4-bit unsigned offset) is `ir[3:0]`.

*Note: PUSH/POP operations can be synthesized using LOAD/STORE with the Stack Pointer (SP, R14) and appropriate immediate offsets. For example:*
*   *PUSH Rx: `ADDI SP, SP, -2` (if word addressing, or -N for N bytes), then `STORE Rx, 0(SP)`.*
*   *POP Rx: `LOAD Rx, 0(SP)`, then `ADDI SP, SP, 2` (if word addressing, or +N for N bytes).*

### 3.4. Category 4: LUI & Control Flow (OpFamily `1100` - `1111`)

This category includes Load Upper Immediate and various control flow instructions.

-   **`LUI Rt, imm8` (Load Upper Immediate)**
    -   OpFamily: `1100`
    -   Format: `1100 Rt[3:0] Imm[7:0]`
        -   `Rt[3:0]` (destination register) is `ir[11:8]`.
        -   `Imm[7:0]` (8-bit immediate) is `ir[7:0]`.
    -   Action: `Rt[15:8] <= Imm[7:0]`, `Rt[7:0] <= 8'b00000000`.
    -   Constraints: `Rt` can be R0-R14.

-   **`JAL imm12_offset` (Jump and Link)**
    -   OpFamily: `1101`
    -   Format: `1101 Offset[11:0]`
        -   `Offset[11:0]` (12-bit signed offset) is `ir[11:0]`.
    -   Action: `R13 (LR) <= PC + 1` (address of the instruction after JAL), then `PC <= PC + sign_extend(Offset[11:0])`.
    -   Description: Used for subroutine calls. Stores the return address in LR and jumps to a PC-relative target address.

-   **`JR Rs_addr` (Jump Register)**
    -   OpFamily: `1110`
    -   Format: `1110 Rs_addr[3:0] --------` (Lower 8 bits `ir[7:0]` are unused)
        -   `Rs_addr[3:0]` (register containing target address) is `ir[11:8]`.
    -   Action: `PC <= Rs_addr`.
    -   Constraints: `Rs_addr` can be R0-R14.

-   **`JCOND cond4, imm8_offset` (Conditional Jump)**
    -   OpFamily: `1111`
    -   Format: `1111 Cond[3:0] Imm[7:0]`
        -   `Cond[3:0]` (condition code) is `ir[11:8]`.
        -   `Imm[7:0]` (8-bit signed offset) is `ir[7:0]`.
    -   Action: `if (condition_met(Cond[3:0], FLG)) PC <= PC + sign_extend(Imm[7:0])`.

    -   **Condition Codes (`Cond[3:0]` field from `ir[11:8]`):**
        | `Cond` | Mnemonic | Condition for Jump     | FLG Bit Checked (Example) |
        | :----- | :------- | :--------------------- | :------------------------ |
        | `0000` | `JZ`     | Jump if Zero (Z=1)     | FLG[1] = 1                |
        | `0001` | `JNZ`    | Jump if Not Zero (Z=0) | FLG[1] = 0                |
        | `0010` | `JC`     | Jump if Carry (C=1)    | FLG[0] = 1                |
        | `0011` | `JNC`    | Jump if No Carry (C=0) | FLG[0] = 0                |
        | `0100` | `JS`     | Jump if Sign (S=1)     | FLG[2] = 1 (Negative)     |
        | `0101` | `JNS`    | Jump if No Sign (S=0)  | FLG[2] = 0 (Non-negative) |
        | `0110` | `JO`     | Jump if Overflow (O=1) | FLG[3] = 1                |
        | `0111` | `JNO`    | Jump if No Overflow (O=0)| FLG[3] = 0                |
        | `1000` | `JMPA`   | Jump Always            | Always true               |
        | `1001`-`1111` |          | Reserved               | N/A                       |

## 4. Opcode Summary

| OpFamily (`ir[15:12]`) | Sub-Op (`ir[11:8]`) | Mnemonic        | Brief Description                                  | Instruction Format Fields                      |
|------------------------|--------------------|-----------------|----------------------------------------------------|------------------------------------------------|
| `0000`                 | `0001`             | `ADD Rx, Ry`    | `Rx <= Rx + Ry`                                    | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0000`                 | `0010`             | `SUB Rx, Ry`    | `Rx <= Rx - Ry`                                    | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0000`                 | `0011`             | `AND Rx, Ry`    | `Rx <= Rx & Ry`                                    | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0000`                 | `0100`             | `OR  Rx, Ry`    | `Rx <= Rx | Ry`                                    | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0000`                 | `0101`             | `XOR Rx, Ry`    | `Rx <= Rx ^ Ry`                                    | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0000`                 | `0110`             | `SHL Rx, Ry`    | `Rx <= Rx << Ry[3:0]`                              | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0000`                 | `0111`             | `SHR Rx, Ry`    | `Rx <= Rx >> Ry[3:0]` (Logical)                    | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0000`                 | `1000`             | `MUL Rx, Ry`    | `Rx <= Rx * Ry`                                    | `OpFam, OpSpec, Rx_dst_s1, Ry_s2`              |
| `0001`                 | *Reserved*         |                 | More R-R ALU ops                                   |                                                |
| `0010`                 | `----`             | `ADDI Rx, imm8` | `Rx <= Rx + sign_extend(imm8)`                     | `OpFam, Rx_dst_s1, Imm8`                       |
| `0011`                 | `----`             | `ANDI Rx, imm8` | `Rx <= Rx & zero_extend(imm8)`                     | `OpFam, Rx_dst_s1, Imm8`                       |
| `0100`                 | `----`             | `ORI  Rx, imm8` | `Rx <= Rx | zero_extend(imm8)`                     | `OpFam, Rx_dst_s1, Imm8`                       |
| `0101`                 | `----`             | `XORI Rx, imm8` | `Rx <= Rx ^ zero_extend(imm8)`                     | `OpFam, Rx_dst_s1, Imm8`                       |
| `0110`-`0111`          | *Reserved*         |                 | More R-I ALU ops                                   |                                                |
| `1000`                 | `----`             | `LOAD Rt, imm4(Rs)`| `Rt <= MEM[Rs + imm4]`                          | `OpFam, Rt, Rs, Imm4`                          |
| `1001`                 | `----`             | `STORE Rt, imm4(Rs)`| `MEM[Rs + imm4] <= Rt`                          | `OpFam, Rt, Rs, Imm4`                          |
| `1100`                 | `----`             | `LUI Rt, imm8`  | `Rt[15:8] <= imm8, Rt[7:0] <= 0`                   | `OpFam, Rt, Imm8`                              |
| `1101`                 | `----`             | `JAL offset12`  | `R13<=PC+1; PC<=PC+offset12`                       | `OpFam, Offset12 (ir[11:0])`                   |
| `1110`                 | `----`             | `JR Rs`         | `PC <= Rs`                                         | `OpFam, Rs_addr (ir[11:8]), Unused (ir[7:0])`    |
| `1111`                 | `Cond[3:0]`        | `JCOND cond, imm8`| `if (cond) PC <= PC + imm8`                      | `OpFam, Cond (ir[11:8]), Imm8 (ir[7:0])`       |

## 5. Memory Mapping

0000-07ff mcu_ram
1000-13ff vram

