# 🧠 5-Stage Pipelined MIPS CPU — Hazard Handling

This project implements a **classic 5-stage pipelined MIPS CPU**  
(IF → ID → EX → MEM → WB) with complete hazard handling, including:

- **RAW data hazards resolved by forwarding**
- **Load-use hazards resolved by stalling and bubble insertion**
- **Control hazards due to branch instructions resolved by stalling and flushing**

The following waveform figures demonstrate correct pipeline behavior under each hazard scenario.

---

## 📌 Pipeline Overview

- **Pipeline stages**: IF / ID / EX / MEM / WB  
- **Execution model**: In-order, single-issue  
- **Register write-back**: WB stage only  
- **Branch decision**: ID stage  
- **Hazard handling units**:
  - Forwarding Unit
  - Hazard Detection Unit (stall / flush control)

---

## 1️⃣ RAW Data Hazard (Resolved by Forwarding)

### Instruction Sequence
```asm
00100000000000010000000000000101 // 0x00: addi $1,$0,5   ; $1 = 5
00100000000000100000000000000111 // 0x04: addi $2,$0,7   ; $2 = 7
00000000001000100001100000100000 // 0x08: add  $3,$1,$2  ; $3 = 12
00000000011000110010000000100000 // 0x0C: add  $4,$3,$3  ; $4 = 24
```

### Description

This sequence introduces **RAW (Read-After-Write) data hazards**, where subsequent instructions depend on results produced by previous ALU operations.

- ALU results are produced at the **end of the EX stage**
- The next instruction requires operands in its **EX stage**
- **Forwarding paths (EX/MEM → EX and MEM/WB → EX)** supply the correct data
- **No stalling is required**

### Result

- Pipeline proceeds without interruption
- Correct values are forwarded directly to the ALU inputs

📷 **Waveform**: ![RAW hazard resolved by forwarding](result/forwarding.jpg)  
**RAW hazard resolved by forwarding**

---

## 2️⃣ Load-Use Hazard (Stall + Bubble Insertion)

### Instruction Sequence
```asm
00100000000000010000000000000101 // addi $1,$0,5
10101100000000010000000000000100 // sw   $1,4($0)
10001100000000010000000000000100 // lw   $1,4($0)   ; load-use hazard source
00000000001000010001000000100000 // add  $2,$1,$1   ; uses lw result → stall
```

### Description

This sequence demonstrates a **load-use RAW hazard**, a special case of data hazard:

- Load data becomes available **only after the MEM stage**
- The dependent `add` instruction needs the value in its **EX stage**
- Forwarding alone is insufficient

### Hazard Handling

- **PC and IF/ID are stalled for 1 cycle**
- A **bubble (NOP)** is injected into the pipeline via ID/EX flush
- After one cycle, forwarding supplies the loaded data

### Result

- Exactly **one stall cycle**
- Correct execution without incorrect data usage

📷 **Waveform**: ![Load-use hazard with stall and bubble](result/load-use-hazard.jpg)
  
**Load-use RAW hazard requiring stall + bubble**

---

## 3️⃣ Control Hazard Due to Branch (Stall + Flush)

### Instruction Sequence
```asm
00100000000000010000000000000101 // addi $1,$0,5
00010000001000010000000000000010 // beq  $1,$1,+2   ; branch taken
00100000000000100000000000001001 // addi $2,$0,9   ; flushed
00100000000000100000000000001000 // addi $2,$0,8   ; flushed (offset)
00100000000000100000000000000111 // addi $2,$0,7   ; branch target
```

### Description

This sequence demonstrates a **control hazard caused by a branch instruction**.

- Branch decision is made in the **ID stage**
- Until the outcome is known, the pipeline cannot safely fetch the next instruction

### Hazard Handling

- **PC and IF/ID are stalled** while waiting for branch resolution
- Once the branch is confirmed taken:
  - The incorrectly fetched instruction is **flushed**
  - PC is redirected to the branch target

### Result

- Correct control flow
- No execution of wrong-path instructions

📷 **Waveform**: ![Control hazard due to branch](result/branch-hazard.jpg)  
**Control hazard due to branch with stall and flush**

---

## 🧩 Hazard Classification Summary

| Hazard Type | Cause | Resolution |
|------------|------|------------|
| RAW hazard | ALU result dependency | Forwarding |
| Load-use RAW hazard | Load data latency | Stall + bubble |
| Control hazard | Branch decision uncertainty | Stall + flush |

> **Note**  
> All data hazards in this design are **RAW hazards**.  
> Load-use hazards are a special case of RAW hazards where forwarding is insufficient.

---

## ✅ Key Takeaways

- Hazard **causes** and **resolution mechanisms** are clearly separated
- Stalls are applied **only when strictly necessary**
- Bubble insertion and flushing are handled cleanly via control logic
- Waveforms verify **timing-correct pipeline behavior**

This project demonstrates a complete and correct implementation of hazard handling in a classic **5-stage pipelined MIPS CPU**.
