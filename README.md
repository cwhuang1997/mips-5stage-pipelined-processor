# 5-Stage Pipelined MIPS Processor with Hazard Handling

This project implements a **classic 5-stage pipelined MIPS processor**
(IF → ID → EX → MEM → WB) with complete hazard handling support.

Supported hazard mechanisms include:
- **RAW data hazards resolved by forwarding**
- **Load-use hazards resolved by stalling and bubble insertion**
- **Control hazards resolved by stall and flush**

All behaviors are verified by waveform simulations.

---

## Pipeline Overview

- **Pipeline stages**: IF / ID / EX / MEM / WB
- **Execution model**: In-order, single-issue
- **Register write-back**: WB stage only
- **Branch decision**: ID stage
- **Hazard handling units**:
  - Forwarding Unit
  - Hazard Detection Unit

---

## Pipeline Datapath

![5-Stage Pipelined MIPS Datapath](datapath.jpg)

The datapath follows a standard 5-stage MIPS pipeline architecture:

- Pipeline registers: IF/ID, ID/EX, EX/MEM, MEM/WB
- ALU used for arithmetic, logic and address calculation
- Forwarding paths from EX/MEM and MEM/WB to EX stage
- Hazard detection logic controls PC write, IF/ID write, and ID/EX flush
- Branch resolution performed in the ID stage, with wrong-path instruction flush

---

## Project Structure

```text
Pipelined-CPU/
├── IF/                     # Instruction Fetch
│   ├── IF.v
│   ├── IF_ID.v
│   └── instruction_memory.v
│
├── ID/                     # Instruction Decode
│   ├── ID.v
│   ├── decoder.v
│   ├── reg_file.v
│   ├── sign_extend.v
│   └── ID_EX.v
│
├── EX/                     # Execute
│   ├── ALU.v
│   ├── EX.v
│   └── EX_MEM.v
│
├── MEM/                    # Memory Access
│   ├── data_memory.v
│   └── MEM_WB.v
│
├── WB/                     # Write Back
│   └── WB.v
│
├── common/                 # Hazard handling units
│   ├── forwarding_unit.v
│   └── hazard_detection_unit.v
│
├── result/                 # Waveforms and figures
│   ├── forwarding.jpg
│   ├── load-use-hazard.jpg
│   └── branch-hazard.jpg
│
├── datapath.jpg            # Pipelined datapath diagram
├── instruction1.txt        # RAW hazard (forwarding)
├── instruction2.txt        # Load-use hazard
├── instruction3.txt        # Control hazard (branch)
├── top_module.v
├── testbench.v
├── cpu.vcd
└── README.md
```

This structure mirrors the actual pipeline datapath and control logic.

---

## RAW Data Hazard (Forwarding)

### Instruction Sequence
```asm
addi $1,$0,5
addi $2,$0,7
add  $3,$1,$2
add  $4,$3,$3
```

### Description

- ALU results are produced at the end of the EX stage
- Data is forwarded from **EX/MEM or MEM/WB to EX**
- **No pipeline stall is required**

**Waveform**  
![RAW hazard resolved by forwarding](result/forwarding.jpg)

---

## Load-Use Hazard (Stall + Bubble)

### Instruction Sequence
```asm
addi $1,$0,5
sw   $1,4($0)
lw   $1,4($0)
add  $2,$1,$1
```

### Description

- Load data becomes available only after the MEM stage
- Pipeline behavior:
  - PC and IF/ID stalled for one cycle
  - Bubble inserted via ID/EX flush
  - Forwarding resumes after data becomes available

**Waveform**  
![Load-use hazard](result/load-use-hazard.jpg)

---

## Control Hazard (Branch)

### Instruction Sequence
```asm
addi $1,$0,5
beq  $1,$1,+2
addi $2,$0,9   # flushed
addi $2,$0,8   # flushed
addi $2,$0,7   # branch target
```

### Description

- Branch decision resolved in the ID stage
- While unresolved:
  - PC and IF/ID are stalled
- When branch is taken:
  - Wrong-path instruction is flushed
  - PC redirected to branch target

**Waveform**  
![Control hazard due to branch](result/branch-hazard.jpg)

---

## Hazard Summary

| Hazard Type | Cause | Resolution |
|------------|------|------------|
| RAW hazard | ALU dependency | Forwarding |
| Load-use hazard (RAW) | Load latency | Stall + bubble |
| Control hazard | Branch decision | Stall + flush |

