# Multi-Cycle MIPS (MCI) Implementation

A Verilog-based, multi-cycle CPU implementing a subset of the MIPS ISA. This repository contains the datapath, control FSM, memories, and a testbench to verify the design over multiple cycles per instruction.

---

## Overview
This multi-cycle MIPS core breaks each instruction into several cycles, sharing hardware resources to save area. The control FSM sequences states for:

1. Instruction fetch
2. Instruction decode / register fetch
3. ALU execution / address calculation
4. Memory access
5. Write-back

The design supports the same instruction subset as the single-cycle version, but each instruction may take 3–5 cycles.

---

## Instruction Set Supported

| Type    | Instruction | Description                              |
|---------|-------------|------------------------------------------|
| **R**   | `add`       | Add two registers                       |
|         | `sub`       | Subtract two registers                  |
|         | `and`       | Bitwise AND                             |
|         | `or`        | Bitwise OR                              |
|         | `slt`       | Set if less than                        |
|         | `srl`       | Logical shift right                     |
| **I**   | `lw`        | Load word                               |
|         | `sw`        | Store word                              |
|         | `beq`       | Branch if equal                         |
|         | `bne`       | Branch if not equal                     |
|         | `sltiu`     | Set if less than immediate (unsigned)   |
|         | `lhu`       | Load halfword unsigned                  |
| **J**   | `j`         | Jump                                    |
|         | `jal`       | Jump and link                           |

---

## Files Description

- **PC.v**: Program counter register with synchronous enable.
- **IMEM.v**: Instruction memory loaded via `$readmemh`.
- **RAM.v**: Unified memory for instructions and data (word-aligned).
- **reg_en.v**: Register enable logic to support multi-cycle writes.
- **RegisterFile.v**: 32×32 register file without a reset port.
- **se_sl.v**: Sign-extend and shift-left unit for immediates.
- **alu_control.v**: FSM that generates ALU operation codes.
- **alu.v**: ALU performing arithmetic and logical operations.
- **control_fsm.v**: Main finite-state machine controlling the multi-cycle sequence.
- **MCI.v**: Top-level multi-cycle CPU integrating datapath and control FSM.
- **inst_and_data.hex**: Combined memory image (instructions + data) for testbench preload.
- **tb_MCI.v**: Testbench forcing initial register values, loading memory, and tracing cycles.

---

## Simulation

### Prerequisites
- Verilog simulator: Icarus Verilog, ModelSim, Vivado, etc.