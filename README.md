<div align="center">

  # 8086 Assembly Language Programs

  [![License: MIT](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)
  ![Status](https://img.shields.io/badge/Status-Completed-2EA043)
  [![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20DOS-00838F)](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)
  [![Technology](https://img.shields.io/badge/Technology-Assembly%208086-0071C5)](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)
  [![Developed by](https://img.shields.io/badge/Developed%20by-Amey%20Thakur-0969DA)](https://github.com/Amey-Thakur)

  A comprehensive collection of **525 professionally documented 8086 Assembly programs**, featuring an **interactive web-based emulator**, smart error detection, _“Did you mean?”_ suggestions, and **step-by-step debugging**.

  **[Microprocessor Lab](https://github.com/Amey-Thakur/MICROPROCESSOR-AND-MICROPROCESSOR-LAB)** &nbsp;·&nbsp; **[Source Code](Source%20Code/)** &nbsp;·&nbsp; **[Technical Specification](docs/SPECIFICATION.md)** &nbsp;·&nbsp; **[Live Demo](https://amey-thakur.github.io/8086-ASSEMBLY-LANGUAGE-PROGRAMS/)**

</div>

---

<div align="center">

  [Author](#author) &nbsp;·&nbsp; [Overview](#overview) &nbsp;·&nbsp; [Features](#features) &nbsp;·&nbsp; [Structure](#project-structure) &nbsp;·&nbsp; [Quick Start](#quick-start) &nbsp;·&nbsp; [Program Details](#program-details) &nbsp;·&nbsp; [Roadmap](#learning-roadmap) &nbsp;·&nbsp; [Best Practices](#best-practices-for-assembly) &nbsp;·&nbsp; [Specifications](#interrupt-vector-specifications) &nbsp;·&nbsp; [Debugging](#debugging--error-analysis) &nbsp;·&nbsp; [Resources](#useful-resources) &nbsp;·&nbsp; [Contributing](#contributing) &nbsp;·&nbsp; [Usage Guidelines](#usage-guidelines) &nbsp;·&nbsp; [License](#license) &nbsp;·&nbsp; [About](#about-this-repository) &nbsp;·&nbsp; [Acknowledgments](#acknowledgments)

</div>

---

<!-- AUTHORS -->
<div align="center">

  ## Author

  **Terna Engineering College | Computer Engineering | Batch of 2022**

| <a href="https://github.com/Amey-Thakur"><img src="https://github.com/Amey-Thakur.png" width="150" height="150" alt="Amey Thakur"></a><br>[**Amey Thakur**](https://github.com/Amey-Thakur)<br><br>[![ORCID](https://img.shields.io/badge/ORCID-0000--0001--5644--1575-A6CE39.svg)](https://orcid.org/0000-0001-5644-1575) |
| :---: |

</div>

---

<!-- OVERVIEW -->
## Overview

The **8086 Assembly Language Programs** repository is a curated collection of low-level assembly code designed to verify and strengthen the understanding of the 8086 microprocessor architecture. It demonstrates the practical implementation of instruction sets, memory management, and hardware simulation using the **Emu8086** emulator.

> [!NOTE]
> This repository contains **525 professionally documented programs** covering every aspect of 8086 assembly programming. All programs were developed, verified, and documented during my undergraduate studies (2018-2022) to master the 8086 architecture.

### Repository Purpose

This repository represents a comprehensive archive of hands-on coding experiments. The primary motivation for creating and maintaining this archive is simple yet profound: **to preserve knowledge for continuous learning and future reference**.

As a computer engineer, understanding the underlying hardware-software interface is crucial for low-level system design and performance optimization. This repository serves as my intellectual reference point: a resource I can return to for relearning concepts, reviewing methodologies, and strengthening understanding when needed.

**Why this repository exists:**

- **Knowledge Preservation**: To maintain organized access to tested assembly programs beyond the classroom.
- **Continuous Learning**: To support lifelong learning by enabling easy revisitation of fundamental 8086 concepts.
- **Academic Documentation**: To authentically document my learning journey through 8086 assembly programming.
- **Community Contribution**: To provide a structured and verified code reference for fellow engineering students.

> [!TIP]
> **Emulation Environments**
> 
> To achieve full execution fidelity, it is recommended to use the **Emu8086** emulator or **DOSBox** with the **TASM/MASM** assembler suite. These environments provide comprehensive debugging capabilities, including real-time register monitoring and memory segment inspection, which are essential for mastering 16-bit architecture.

---

<!-- FEATURES -->
## Features

| Feature | Description |
|---------|-------------|
| **Instruction Implementation** | The complete 8086 instruction set: arithmetic, transfer, logic, shifts, rotates, string operations, and every conditional branch |
| **Addressing Modes** | One program for each: immediate, register, direct, register indirect, based, indexed, based indexed, with displacement, segment override, string, and relative |
| **System Interfacing** | Port-driven hardware simulation for traffic lights, stepper motors, relay banks, seven segment displays, and analogue sensors |
| **Memory Management** | Block transfer, fill, compare, scan, checksum, overlapping moves, and hexadecimal dumps |
| **File System Operations** | Create, open, read, write, seek, rename, and delete through the DOS handle services, including every documented error path |
| **Graphics Programming** | Text mode drawing, VGA mode 13h pixel plotting, Bresenham lines, bitmap sprites, and the colour attribute table |
| **Data Conversion** | Hexadecimal, BCD, binary, octal, ASCII, and seven segment, in both directions |
| **Algorithm Design** | Bubble, selection, insertion, cocktail, gnome, counting, merge, **quick, heap and radix** sorts, with linear, binary, jump, exponential and ternary search |
| **Modular Programming** | `MACRO` with `LOCAL`, `REPT` unrolling, conditional assembly, macro libraries, and the three ways a macro surprises its author |
| **Interrupt Handling** | DOS (`INT 21h`), BIOS (`INT 10h`, `16h`, `1Ah`, `15h`), the vector table, and the carry flag error convention |
| **Array Processing** | Summation, reversal, minimum and maximum, insertion, deletion, rotation, and searching |
| **Bitwise Logic** | AND, OR, XOR, NOT, shifts, rotates, field packing, sets held in a word, branchless selection, and the identities worth knowing |
| **Control Structures** | Loops, guard clauses, jump tables, nested loops with early exit, and table-driven state machines |
| **Data Structures** | Stack, queue, deque, linked list, binary tree, binary search tree, hash table, priority queue, and set operations |
| **Mathematical Computation** | Factorial, Fibonacci, GCD, LCM, powers, integer roots, 32-bit arithmetic, quadratic roots, and determinants |
| **Matrix Operations** | Addition, transpose, multiplication, and the 3×3 determinant |
| **Pattern Generation** | Pyramids, diamonds, triangles, and geometric figures |
| **String Manipulation** | Length, reverse, palindrome, anagram, case conversion, substring search, run-length encoding, and longest common prefix |
| **System Utilities** | Delays, passwords, sound, screen clearing, calendars, and pseudorandom numbers |
| **Console I/O** | Characters, strings, buffered lines, signed and unsigned decimal, hexadecimal, and validated numeric input |

### What the simulator does

| Capability | Detail |
|------------|--------|
| **Assembler** | Two passes with forward references, `MACRO`/`LOCAL`, `REPT`, conditional assembly, `LABEL`, `DUP`, full segment definitions (`DATA SEGMENT`/`ASSUME`), and constant expressions with `$`, `OFFSET`, `SEG` and folded arithmetic |
| **Processor** | All nine flags, 8- and 16-bit register aliasing, segmented addressing that wraps as the hardware does, and the 8086 behaviours later chips changed — `PUSH SP`, unmasked shift counts, `LOOP` from zero |
| **Devices** | 64K port space with a write journal, an in-memory file store, a fixed clock, a pixel plane for the graphics modes, and an interrupt vector table laid out as an IBM PC left it |
| **Diagnostics** | Every error carries a line number. *“Did you mean?”* corrects typing slips including transpositions, and recognises instructions that are real but belong to a later processor — `MOVZX` is told it arrived with the 80386, not guessed at as a misspelling |
| **Interface** | Resizable panels, keyboard shortcuts, light and dark themes, a personalised loading screen and 404 page, an audible bell, and a search that adapts to the width it is given |
| **Verification** | Twelve suites. One assembles and runs every program in the repository; one compares every program's output against a recorded golden file; one throws malformed source at the engine and insists it never crashes |

### Tech Stack

- **Architecture** → Intel 8086 (16-bit)
- **Assembler** → MASM / TASM syntax, both the simplified directives and full segment definitions
- **Emulator** → Emu8086 (native) · 8086 Microprocessor Simulator (browser)
- **Language** → Assembly (ASM)
- **Simulator** → JavaScript (ES2020 modules), no dependencies and no build step
- **Verification** → 2010 conformance tests across 12 suites, run with `npm test`
- **Maintenance** → `npm run index` rebuilds the program list, `npm run counts` and `npm run structure` rewrite every published figure and the tree above from the repository itself, so none of them can drift

---

<!-- STRUCTURE -->
## Project Structure

```python
8086-ASSEMBLY-LANGUAGE-PROGRAMS/
│
├── docs/                                    # Formal documentation
│   └── SPECIFICATION.md                     # Technical architecture and specification
│
├── Source Code/                             # 8086 assembly programs (525 files, 39 categories)
│   ├── Addressing Modes/                 # Every way the 8086 can name an operand (12)
│   ├── Arithmetic/                       # Add, subtract, multiply, divide, and BCD (14)
│   ├── Array Operations/                 # Sum, min and max, insert, delete, rotate, search (20)
│   ├── BIOS Services/                    # INT 10h, 16h and 1Ah: video, keyboard, clock (12)
│   ├── Bit Manipulation/                 # Counting, isolating, reversing and rounding bits (13)
│   ├── Bitwise Operations/               # AND, OR, XOR, NOT, shifts, rotates, masks (12)
│   ├── Conditional Jumps/                # The signed and unsigned branch families (12)
│   ├── Control Flow/                     # Loops, guards, jump tables, state machines (12)
│   ├── Conversion/                       # Hex, BCD, binary, octal, ASCII, seven segment (23)
│   ├── Data Structures/                  # Stack, queue, deque, list, tree, hash, heap (15)
│   ├── Data Transfer/                    # MOV, XCHG, LEA, LDS, LES, XLAT, PUSH, POP (12)
│   ├── DOS Services/                     # INT 21h: console, buffered input, files, clock (12)
│   ├── Expression/                       # Factorial, Fibonacci, GCD, power, quadratic (14)
│   ├── External Devices/                 # Traffic lights, stepper motor, relays, sensors (12)
│   ├── File Operations/                  # Create, open, read, write, seek, rename, delete (12)
│   ├── Flags/                            # All nine flags, and what each one answers (12)
│   ├── Graphics/                         # Text mode drawing, VGA pixels, Bresenham, sprites (12)
│   ├── Input Output/                     # Reading and printing decimal, hex, binary, strings (12)
│   ├── Interrupts/                       # The vector table, service conventions, BIOS and DOS (12)
│   ├── Introduction/                     # Hello World, the syntax, the first instructions (15)
│   ├── Loops/                            # LOOP, LOOPE, LOOPNE, and loops built by hand (12)
│   ├── Macros/                           # MACRO, LOCAL, REPT, conditional assembly (12)
│   ├── Mathematics/                      # Roots, powers, averages, 32-bit arithmetic (12)
│   ├── Matrix/                           # Addition, transpose, multiplication, determinant (15)
│   ├── Memory Operations/                # Block move, fill, compare, scan, checksum, dump (12)
│   ├── Number Theory/                    # Primes, divisors, Collatz, modular arithmetic (13)
│   ├── Patterns/                         # Pyramids, diamonds, triangles, geometric figures (16)
│   ├── Port Programming/                 # IN and OUT against a port space (12)
│   ├── Procedures/                       # Calls, arguments, frames, recursion, dispatch (12)
│   ├── Recursion/                        # Factorial, Fibonacci, Hanoi, and the frames beneath (12)
│   ├── Searching/                        # Linear, binary, jump, exponential, ternary, rotated (16)
│   ├── Shift and Rotate/                 # SHL, SHR, SAR, ROL, ROR, RCL, RCR (12)
│   ├── Signed Arithmetic/                # Two’s complement, IMUL, IDIV, CBW, CWD (12)
│   ├── Simulation/                       # Traffic lights, lifts, sensors, machines, displays (12)
│   ├── Sorting/                          # Bubble, selection, insertion, quick, heap, radix (20)
│   ├── Stack Operations/                 # The pointer, frames, flags, and stack discipline (12)
│   ├── String Instructions/              # MOVS, LODS, STOS, CMPS, SCAS, and REP (12)
│   ├── String Operations/                # Length, reverse, palindrome, case, search, encode (18)
│   ├── Utilities/                        # Delays, passwords, sound, clearing, calendars (13)
│   │
│   └── 8086 Microprocessor Simulator/       # Browser simulator, no dependencies and no build step
│       ├── css/                             # Tokens, layout, components (3)
│       ├── js/
│       │   ├── cpu/                         # Memory, registers, flags, shifter, ALU, CPU (6)
│       │   ├── asm/                         # Lexer, macros, expressions, operands, assembler (5)
│       │   ├── exec/                        # Executor, devices, strings, interrupts (4)
│       │   ├── ui/                          # Editor, inspector, library, console, panels, app (8)
│       │   ├── tools/                       # Index and count generators (5)
│       │   └── test/                        # Conformance suites (13)
│       ├── index.html                       # Simulator entry point
│       ├── package.json                     # Test runner configuration
│       └── programs.js                      # Generated program index
│
├── .gitattributes                           # Git configuration
├── .gitignore                               # Git ignore rules
├── 404.html                                 # Personalised not-found page
├── CITATION.cff                             # Citation metadata
├── codemeta.json                            # Project metadata (JSON-LD)
├── LICENSE                                  # MIT License
├── README.md                                # Main documentation
└── SECURITY.md                              # Security policy and posture
```

---

<!-- QUICK START -->
## Quick Start

### Prerequisites

- **Operating System**: Windows 7, 8, 10, or 11 is required for native Emu8086 support.
- **Emulator Software**: The **Emu8086** microprocessor emulator is required to assemble and execute the code.
- **Alternative Environments**: For macOS or Linux users, a virtualization layer (e.g., Wine, VM) or DOSBox with an assembler (TASM/MASM) is necessary.

> [!WARNING]
> **Architectural Constraints & Safety**
> 
> These programs are designed for the **Intel 8086 (16-bit)** architecture. Executing them in modern 64-bit operating systems without proper emulation (e.g., DOSBox) may lead to system crashes or undefined behavior due to direct memory access and interrupt usage. Always use a sandboxed 16-bit environment.

### Option 1: Web Simulator (Recommended)

Run programs instantly in your browser without any installation.

1.  **Open the Live Demo**: [8086 Assembly Emulator](https://amey-thakur.github.io/8086-ASSEMBLY-LANGUAGE-PROGRAMS/)
2.  **Select a Program**: Browse the sidebar library containing all **525 programs**.
3.  **Run or Step**: Run to completion, or step one instruction at a time and watch the registers, flags, stack and memory change.

Every program in this repository assembles and runs in the simulator. The
simulator loads the real `.asm` files from the folders beside it rather than
copies, so what runs is what the repository holds.

**What it implements**

| Layer | Coverage |
|:------|:---------|
| **Instructions** | The full 8086 set: arithmetic with all nine flags, BCD adjustment, shifts and rotates through carry, string operations with `REP`, `CALL`/`RET`, and port `IN`/`OUT` |
| **Assembler** | Two passes with forward references, `MACRO` with `LOCAL`, conditional assembly, constant expressions including `$`, `OFFSET`, `SEG`, `DUP` and jump tables |
| **Services** | `INT 21h` for console, buffered input, files and the clock; `INT 10h`, `16h`, `1Ah`, `15h` and `20h` |
| **Verification** | 2010 tests across 12 suites, including one that assembles and runs all 525 programs |

**Running the tests**

```bash
cd "Source Code/8086 Microprocessor Simulator" && npm test
```

**Serving it locally**

The simulator fetches the `.asm` files, which a browser will not do for a page
opened straight from disk. Serve the repository folder instead:

```bash
npx http-server . -p 8080
```

### Option 2: Local Development

For a full native experience with hardware access (requires Windows).

**Prerequisites**
- **OS**: Windows 7/8/10/11
- **Software**: **Emu8086** (Required for native execution)
- **Linux/macOS**: Use DOSBox or Wine

**Setup**

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS.git
   ```

2. **Open in Emulator**
   - Launch **Emu8086**.
   - Open any `.asm` file from the `Source Code/` directory.

3. **Assemble and Run**
   - Click **Emulate** to compile.
   - Use **Run** or **Single Step** to execute.

> [!TIP]
> **Integrated 8086 Assembly Microprocessor Emulator**
>
> Assemble and debug 16-bit TASM/MASM assembly in the browser, with the registers, the nine flags, the stack, memory and the device ports all visible while the program runs, and single stepping through the source line by line.
>
> [**Launch 8086 Assembly Emulator**](https://amey-thakur.github.io/8086-ASSEMBLY-LANGUAGE-PROGRAMS/)

---

<!-- PROGRAM DETAILS -->
## Program Details

> [!IMPORTANT]
> Click on each section below to expand and view all programs with direct links to source code.

> [!NOTE]
> This section is generated from the programs themselves by `npm run catalogue`. The title and description of each row are read out of that file's own header, so the list cannot fall behind the repository.

**525 programs across 39 categories.**

<details>
<summary><strong>Addressing Modes (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `based_addressing_mode.asm` | Based Addressing Mode | A base register plus a constant displacement, the mode that reads a named field out of a record. | [View](Source%20Code/Addressing%20Modes/based_addressing_mode.asm) |
| `based_indexed_addressing_mode.asm` | Based Indexed Addressing Mode | A base register and an index register together, the natural way to reach row and column of a two dimensional table. | [View](Source%20Code/Addressing%20Modes/based_indexed_addressing_mode.asm) |
| `based_indexed_with_displacement.asm` | Based Indexed Addressing With Displacement | The fullest address the 8086 can form: a base register, an index register and a constant, all added together. | [View](Source%20Code/Addressing%20Modes/based_indexed_with_displacement.asm) |
| `comprehensive_8086_addressing_modes_reference.asm` | 8086 Addressing Modes - Complete Reference | A comprehensive demonstration of all 7 addressing modes of the Intel 8086 microprocessor. This program serves as a practical guide for understanding how the CPU accesses operands from registers and memory. | [View](Source%20Code/Addressing%20Modes/comprehensive_8086_addressing_modes_reference.asm) |
| `direct_addressing_mode.asm` | Direct Addressing Mode | The address is a fixed number written into the instruction by the assembler, which is what a plain variable name means. | [View](Source%20Code/Addressing%20Modes/direct_addressing_mode.asm) |
| `immediate_addressing_mode.asm` | Immediate Addressing Mode | The operand is a constant carried inside the instruction itself, so no memory read is needed to fetch it. | [View](Source%20Code/Addressing%20Modes/immediate_addressing_mode.asm) |
| `indexed_addressing_mode.asm` | Indexed Addressing Mode | An index register plus a constant, the mode written as ARRAY[SI] and used for every element by number. | [View](Source%20Code/Addressing%20Modes/indexed_addressing_mode.asm) |
| `register_addressing_mode.asm` | Register Addressing Mode | Both operands live in registers, so the instruction runs without any memory traffic at all. | [View](Source%20Code/Addressing%20Modes/register_addressing_mode.asm) |
| `register_indirect_addressing_mode.asm` | Register Indirect Addressing Mode | A register holds the address instead of the value, which is what makes walking an array possible. | [View](Source%20Code/Addressing%20Modes/register_indirect_addressing_mode.asm) |
| `relative_addressing_mode.asm` | Relative Addressing For Jumps | A jump stores the distance to its target rather than the address, which is what makes code work wherever it is loaded. | [View](Source%20Code/Addressing%20Modes/relative_addressing_mode.asm) |
| `segment_override_addressing.asm` | Segment Override Prefixes | Each addressing mode has a default segment, and a one byte prefix changes it when the default is not what is wanted. | [View](Source%20Code/Addressing%20Modes/segment_override_addressing.asm) |
| `string_addressing_mode.asm` | String Addressing Mode | The string instructions take no operands at all: the source and destination registers are implied and stepped for you. | [View](Source%20Code/Addressing%20Modes/string_addressing_mode.asm) |

</details>

<details>
<summary><strong>Arithmetic (14 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `add_array_of_bytes_from_memory.asm` | Addition of Byte Array from Memory | This program calculates the 16-bit sum of a series of ten 8-bit unsigned integers stored in consecutive memory locations. It demonstrates memory segmentation, indirect addressing, and manual carry propagation. | [View](Source%20Code/Arithmetic/add_array_of_bytes_from_memory.asm) |
| `addition_16bit_packed_bcd.asm` | 16-bit Packed BCD Addition using DAA | This program demonstrates how to add two 16-bit Packed BCD (Binary Coded Decimal) numbers. It highlights the use of the DAA (Decimal Adjust after Addition) instruction to correct hexadecimal results into human-readable decimal digits. | [View](Source%20Code/Arithmetic/addition_16bit_packed_bcd.asm) |
| `addition_16bit_simple.asm` | 16-bit and 8-bit Addition Demonstration | This program demonstrates basic arithmetic operations using both 8-bit and 16-bit operands in the Intel 8086. It covers register usage, memory-to-register transfers, and foundational binary addition mechanics. | [View](Source%20Code/Arithmetic/addition_16bit_simple.asm) |
| `addition_16bit_with_carry_detection.asm` | 16-bit Addition with Carry Detection | This program performs the addition of two 16-bit unsigned integers and identifies if the result has exceeded the maximum capacity of a 16-bit register (FFFFH or 65,535). It emphasizes the use of conditional jumps for status checking. | [View](Source%20Code/Arithmetic/addition_16bit_with_carry_detection.asm) |
| `addition_8bit_with_user_input.asm` | 8-bit Addition with Interactive User Input | This program reads two single-digit decimal numbers from the keyboard, calculates their sum, and displays the result on the screen. It demonstrates ASCII-to-Binary conversion, unpacked BCD arithmetic using AAA, and DOS I/O interrupts. | [View](Source%20Code/Arithmetic/addition_8bit_with_user_input.asm) |
| `calculate_sum_of_first_n_natural_numbers.asm` | Summation of the First 'N' Natural Numbers | This program calculates the sum of the first N natural numbers (1 + 2 + 3 + ... + N) iteratively. It demonstrates the use of the 8086 LOOP instruction, register-based accumulation, and handling of 8-bit unsigned integer limits. | [View](Source%20Code/Arithmetic/calculate_sum_of_first_n_natural_numbers.asm) |
| `count_set_bits_in_16bit_binary.asm` | 16-bit Set Bit Counter (Population Count) | This program calculates the number of bits set to '1' in a 16-bit binary number. It demonstrates efficient bit manipulation using rotation and carry flag analysis. | [View](Source%20Code/Arithmetic/count_set_bits_in_16bit_binary.asm) |
| `decimal_adjust_after_addition_demo.asm` | DAA (Decimal Adjust after Addition) Practical Demo | This program provides a clear demonstration of how the 8086 CPU handles Packed BCD (Binary Coded Decimal) arithmetic. It shows the automated correction process that happens inside the ALU when the DAA instruction is invoked. | [View](Source%20Code/Arithmetic/decimal_adjust_after_addition_demo.asm) |
| `division_16bit_dividend_by_8bit_divisor.asm` | 16-bit Dividend by 8-bit Divisor (Unsigned) | This program demonstrates how to use the DIV instruction in the Intel 8086 to perform unsigned integer division. It specifically shows the implicit register usage and result placement for 8-bit divisors. | [View](Source%20Code/Arithmetic/division_16bit_dividend_by_8bit_divisor.asm) |
| `generate_multiplication_table_for_number.asm` | Dynamic Multiplication Table Generator | This program generates and displays a formatted multiplication table (from 1 to 10) for a given number. It demonstrates complex loop construction, nested procedure calls, and a robust binary-to-decimal conversion algorithm. | [View](Source%20Code/Arithmetic/generate_multiplication_table_for_number.asm) |
| `multiplication_8bit_unsigned.asm` | 8-bit Unsigned Multiplication Demo | This program demonstrates the multiplication of two 8-bit unsigned integers. It illustrates how the 8086 automatically expands the product into a 16-bit register (AX) to prevent data loss from overflow. | [View](Source%20Code/Arithmetic/multiplication_8bit_unsigned.asm) |
| `signed_addition_and_subtraction_demo.asm` | Signed Arithmetic and Conditional Branching Demo | This program demonstrates how the 8086 handles signed integers using Two's Complement representation. It showcases signed addition, the use of the Sign Flag (SF), and the critical distinction between signed (JG/JL) and unsigned (JA/JB) jumps. | [View](Source%20Code/Arithmetic/signed_addition_and_subtraction_demo.asm) |
| `subtraction_8bit_with_user_input.asm` | 8-bit Interactive Subtraction with ASCII Adjustment | This program reads two single-digit decimal numbers from the keyboard, performs subtraction (Minuend - Subtrahend), and displays the result. It highlights the use of AAS (ASCII Adjust for Subtraction) to handle multi-digit borrowing logic in Unpacked BCD format. | [View](Source%20Code/Arithmetic/subtraction_8bit_with_user_input.asm) |
| `swap_two_numbers_using_registers.asm` | Register-to-Register Value Swapping Techniques | This program demonstrates several methods to exchange the contents of two 8086 registers. It covers the atomic XCHG instruction and the classic Bitwise XOR algorithm, ensuring the developer understands the trade-offs between hardware-level exchange and logical manipulation. | [View](Source%20Code/Arithmetic/swap_two_numbers_using_registers.asm) |

</details>

<details>
<summary><strong>Array Operations (20 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `array_equality_check.asm` | Comparing Two Arrays | Decides whether two arrays hold the same values in the same order, and reports the first place they differ. | [View](Source%20Code/Array%20Operations/array_equality_check.asm) |
| `calculate_sum_of_array_elements.asm` | Iterative Array Summation (8-bit to 16-bit Accumulation) | This program calculates the arithmetic sum of all 8-bit elements in an array. It demonstrates a robust accumulator pattern that promotes 8-bit operands to a 16-bit register to prevent arithmetic overflow during the summation process. | [View](Source%20Code/Array%20Operations/calculate_sum_of_array_elements.asm) |
| `copy_block_of_data_between_arrays.asm` | Block Memory Copy using String Instructions (MOVSB) | This program demonstrates the most efficient way to copy a block of data from one memory location to another using the 8086's dedicated string processing hardware. It features the REP prefix and the MOVSB instruction. | [View](Source%20Code/Array%20Operations/copy_block_of_data_between_arrays.asm) |
| `count_odd_and_even_numbers_in_array.asm` | Array-Based Parity Analysis (Odd/Even Distribution) | This program traverses an array of 8-bit integers and calculates the count of odd and even numbers. It utilizes bitwise testing of the Least Significant Bit (LSB) to efficiently determine parity without division. | [View](Source%20Code/Array%20Operations/count_odd_and_even_numbers_in_array.asm) |
| `delete_element_from_array_by_index.asm` | Array Element Deletion via Left-Shift Compaction | This program demonstrates how to delete an element from a sequential array by shifting all subsequent elements one position to the left. It illustrates precise pointer manipulation and loop-based data displacement in the 8086 architecture. | [View](Source%20Code/Array%20Operations/delete_element_from_array_by_index.asm) |
| `element_frequency_count.asm` | How Often Each Element Appears | Counts the occurrences of every distinct value, marking those already reported so none is counted twice. | [View](Source%20Code/Array%20Operations/element_frequency_count.asm) |
| `find_maximum_element_in_array.asm` | Maximum Element Discovery in Unsigned Arrays | This program identifies the largest numerical value within a sequential array of 8-bit integers. It demonstrates the iterative comparison pattern, the use of conditional branching (JA), and efficient register-based state tracking. | [View](Source%20Code/Array%20Operations/find_maximum_element_in_array.asm) |
| `find_minimum_element_in_array.asm` | Minimum Element Discovery in Unsigned Arrays | This program identifies the smallest numerical value within a sequential array of 8-bit integers. It demonstrates the iterative comparison pattern, the use of conditional branching (JB), and efficient register-based state tracking. | [View](Source%20Code/Array%20Operations/find_minimum_element_in_array.asm) |
| `insert_element_into_array_at_index.asm` | Array Element Insertion via Right-Shift Displacement | This program demonstrates how to insert a new element into a sequential array at a specific index. It features the critical "Backwards Shift" logic required to prevent data corruption when moving data within the same memory block. | [View](Source%20Code/Array%20Operations/insert_element_into_array_at_index.asm) |
| `interleave_two_arrays.asm` | Interleaving Two Arrays | Builds one array by taking alternately from two others, and then separates them again. | [View](Source%20Code/Array%20Operations/interleave_two_arrays.asm) |
| `leaders_in_array.asm` | Elements Larger Than Everything After Them | Finds the leaders of an array by scanning from the right, which turns a quadratic problem into one pass. | [View](Source%20Code/Array%20Operations/leaders_in_array.asm) |
| `maximum_subarray_sum.asm` | Largest Sum of Any Run | Finds the run of consecutive elements with the greatest total, in one pass, using Kadane's method. | [View](Source%20Code/Array%20Operations/maximum_subarray_sum.asm) |
| `move_zeros_to_end.asm` | Moving the Zeros to the End | Pushes every zero to the back while keeping the other elements in their original order, in a single pass. | [View](Source%20Code/Array%20Operations/move_zeros_to_end.asm) |
| `pair_with_given_sum.asm` | Finding Two Elements That Add to a Target | Searches a sorted array for a pair summing to a given value, by closing in from both ends. | [View](Source%20Code/Array%20Operations/pair_with_given_sum.asm) |
| `prefix_sums.asm` | Prefix Sums and Range Totals | Builds a table of running totals once, so that the sum of any stretch of the array afterwards costs one subtraction. | [View](Source%20Code/Array%20Operations/prefix_sums.asm) |
| `remove_duplicates_from_sorted.asm` | Removing Duplicates from a Sorted Array | Compacts a sorted array so each value appears once, which needs only one comparison per element because equal values are adjacent. | [View](Source%20Code/Array%20Operations/remove_duplicates_from_sorted.asm) |
| `rotate_array_left.asm` | Rotating an Array Left | Moves every element three places toward the front, wrapping the first three round to the end, by reversing three times. | [View](Source%20Code/Array%20Operations/rotate_array_left.asm) |
| `rotate_array_right.asm` | Rotating an Array Right | The mirror of the left rotation, which is the same three reversals with the split in the other place. | [View](Source%20Code/Array%20Operations/rotate_array_right.asm) |
| `second_largest_element.asm` | The Second Largest Element | Finds the largest and the next largest in a single pass, keeping both as it goes rather than sorting or scanning twice. | [View](Source%20Code/Array%20Operations/second_largest_element.asm) |
| `split_array_by_condition.asm` | Partitioning an Array | Divides an array in place so that everything below a pivot comes first, which is the step quicksort is built on. | [View](Source%20Code/Array%20Operations/split_array_by_condition.asm) |

</details>

<details>
<summary><strong>BIOS Services (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `bios_boot_and_system.asm` | System Services and the Warm Boot | Calls the miscellaneous system service and shows the interrupt that restarts the machine, which is how a program of last resort ends. | [View](Source%20Code/BIOS%20Services/bios_boot_and_system.asm) |
| `bios_character_with_attribute.asm` | Writing a Character with a Colour | Uses service 09h to place a character with a chosen colour, and repeats it, which teletype output cannot do. | [View](Source%20Code/BIOS%20Services/bios_character_with_attribute.asm) |
| `bios_clear_screen.asm` | Clearing the Screen with a Scroll | Clears the display by asking the BIOS to scroll a window by more lines than it has, which is the standard idiom. | [View](Source%20Code/BIOS%20Services/bios_clear_screen.asm) |
| `bios_cursor_control.asm` | Moving and Reading the Cursor | Places the cursor at a chosen row and column, and asks where it is, which is how text is put anywhere on the screen. | [View](Source%20Code/BIOS%20Services/bios_cursor_control.asm) |
| `bios_keyboard_status.asm` | Checking for a Key Without Waiting | Asks whether a key is waiting and carries on either way, which is what a program with other work to do needs. | [View](Source%20Code/BIOS%20Services/bios_keyboard_status.asm) |
| `bios_keyboard_wait.asm` | Waiting for a Key with INT 16h | Reads a keystroke through the BIOS, which returns the scan code as well as the character. | [View](Source%20Code/BIOS%20Services/bios_keyboard_wait.asm) |
| `bios_scan_code_table.asm` | Scan Codes for the Keys | Reads several keys and shows both what they mean and which physical key produced them. | [View](Source%20Code/BIOS%20Services/bios_scan_code_table.asm) |
| `bios_shift_key_state.asm` | Reading the Shift and Lock Keys | Asks which modifier keys are held down or latched, each one a single bit in the returned byte. | [View](Source%20Code/BIOS%20Services/bios_shift_key_state.asm) |
| `bios_teletype_output.asm` | Printing with INT 10h Service 0Eh | Writes characters through the BIOS rather than through DOS, which is what a program that cannot rely on DOS has to do. | [View](Source%20Code/BIOS%20Services/bios_teletype_output.asm) |
| `bios_timer_ticks.asm` | Reading the System Timer | Asks the BIOS how many timer ticks have passed since midnight and turns that back into a time of day. | [View](Source%20Code/BIOS%20Services/bios_timer_ticks.asm) |
| `bios_versus_dos_output.asm` | The BIOS and DOS Compared | Prints the same line through both routes and sets out when each one is the right choice. | [View](Source%20Code/BIOS%20Services/bios_versus_dos_output.asm) |
| `bios_video_mode_query.asm` | Asking About the Display | Reads which video mode is active and how wide the screen is, before assuming anything about where text can go. | [View](Source%20Code/BIOS%20Services/bios_video_mode_query.asm) |

</details>

<details>
<summary><strong>Bit Manipulation (13 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `check_power_of_two.asm` | Test Whether a Value is a Power of Two | Decides in two instructions whether a 16-bit value is a power of two, using the identity that such a value has exactly one bit set. | [View](Source%20Code/Bit%20Manipulation/check_power_of_two.asm) |
| `count_set_bits_kernighan.asm` | Count Set Bits (Kernighan's Method) | Counts the one bits in a 16-bit word by repeatedly clearing the lowest set bit, which costs one iteration per set bit rather than one per bit position. | [View](Source%20Code/Bit%20Manipulation/count_set_bits_kernighan.asm) |
| `count_set_bits_nibble_table.asm` | Count Set Bits with a Nibble Table | Counts the one bits of a word four at a time, by looking every nibble up in a sixteen entry table with XLAT. | [View](Source%20Code/Bit%20Manipulation/count_set_bits_nibble_table.asm) |
| `count_set_bits_parallel_halving.asm` | Count Set Bits by Parallel Halving | Counts the one bits of a word without any loop at all, by adding the bits in pairs, the pairs in nibbles, the nibbles in bytes and the bytes together. | [View](Source%20Code/Bit%20Manipulation/count_set_bits_parallel_halving.asm) |
| `extract_bit_field.asm` | Extract a Bit Field | Reads a run of bits from an arbitrary position within a word by shifting the field down and masking off everything above it. | [View](Source%20Code/Bit%20Manipulation/extract_bit_field.asm) |
| `find_highest_set_bit.asm` | Find the Highest Set Bit | Reports the position of the most significant one bit of a word, and rebuilds that bit on its own, which is the largest power of two the value contains. | [View](Source%20Code/Bit%20Manipulation/find_highest_set_bit.asm) |
| `gray_code_conversion.asm` | Convert Between Binary and Gray Code | Turns a value into the reflected binary code in which successive numbers differ in a single bit, and turns it back again with a running exclusive or. | [View](Source%20Code/Bit%20Manipulation/gray_code_conversion.asm) |
| `isolate_lowest_set_bit.asm` | Isolate the Lowest Set Bit | Extracts the least significant set bit of a value and reports its position, using the two's complement identity X AND -X. | [View](Source%20Code/Bit%20Manipulation/isolate_lowest_set_bit.asm) |
| `reverse_bits_in_word.asm` | Reverse the Bits of a Word | Reverses the bit order of a 16-bit value by shifting bits out of one register and into another in the opposite direction. | [View](Source%20Code/Bit%20Manipulation/reverse_bits_in_word.asm) |
| `round_up_to_power_of_two.asm` | Round a Value Up to the Next Power of Two | Smears the highest set bit downward so that the value becomes a run of ones, then adds one to carry it up to the power of two above, and reports the case that will not fit in a word. | [View](Source%20Code/Bit%20Manipulation/round_up_to_power_of_two.asm) |
| `set_clear_toggle_bit.asm` | Set, Clear and Toggle a Chosen Bit | Builds a mask for a bit named at run time and shows the three operations that act on that bit alone, together with the test that reads it without disturbing anything. | [View](Source%20Code/Bit%20Manipulation/set_clear_toggle_bit.asm) |
| `swap_bytes_in_word.asm` | Swap the Two Bytes of a Word | Exchanges the high and low bytes of a word by two routes, one instruction each, and shows why the exchange is needed when data arrives with the most significant byte first. | [View](Source%20Code/Bit%20Manipulation/swap_bytes_in_word.asm) |
| `swap_nibbles_in_byte.asm` | Swap the Nibbles of a Byte | Exchanges the high and low four bits of a byte using a single four place rotate, and prints the result in hexadecimal. | [View](Source%20Code/Bit%20Manipulation/swap_nibbles_in_byte.asm) |

</details>

<details>
<summary><strong>Bitwise Operations (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `bitwise_and_logic_demonstration.asm` | Bitwise Logical AND Operation (Masking & Intersection) | This program demonstrates the 8086 'AND' instruction, which performs a bitwise logical intersection between two 8-bit operands. It illustrates how AND can be used to isolate specific bit-fields or "mask out" unwanted data. | [View](Source%20Code/Bitwise%20Operations/bitwise_and_logic_demonstration.asm) |
| `bitwise_branchless_selection.asm` | Choosing Without Branching | Minimum, maximum, absolute value and a conditional swap, all done with masks instead of jumps. | [View](Source%20Code/Bitwise%20Operations/bitwise_branchless_selection.asm) |
| `bitwise_field_packing.asm` | Packing Several Fields Into One Word | A date squeezed into sixteen bits, and taken out again, which is what masks and shifts are for. | [View](Source%20Code/Bitwise%20Operations/bitwise_field_packing.asm) |
| `bitwise_identities_demonstrated.asm` | The Bitwise Identities Worth Knowing | Six identities that turn a loop into a single instruction, each demonstrated on real values rather than asserted. | [View](Source%20Code/Bitwise%20Operations/bitwise_identities_demonstrated.asm) |
| `bitwise_logical_shift_left_and_multiplication.asm` | Bitwise Logical Shift Left (SHL) & Binary Multiplication | This program demonstrates the 8086 'SHL' (Shift Logical Left) instruction. It illustrates how shifting bits to the left effectively multiplies a value by powers of two while simultaneously interacting with the Carry Flag. | [View](Source%20Code/Bitwise%20Operations/bitwise_logical_shift_left_and_multiplication.asm) |
| `bitwise_logical_shift_right_and_division.asm` | Bitwise Logical Shift Right (SHR) & Binary Division | This program demonstrates the 8086 'SHR' (Shift Logical Right) instruction. It illustrates how shifting bits to the right performs efficient unsigned division by powers of two while tracking remainders via the Carry Flag. | [View](Source%20Code/Bitwise%20Operations/bitwise_logical_shift_right_and_division.asm) |
| `bitwise_not_ones_complement_demonstration.asm` | Bitwise Logical NOT Operation (One's Complement) | This program demonstrates the 8086 'NOT' instruction, which performs a bitwise logical negation. This operation inverts every bit in the operand (0 becomes 1, and 1 becomes 0), effectively calculating the One's Complement of a value. | [View](Source%20Code/Bitwise%20Operations/bitwise_not_ones_complement_demonstration.asm) |
| `bitwise_or_logic_demonstration.asm` | Bitwise Logical OR Operation (Union & Flag Setting) | This program demonstrates the 8086 'OR' instruction, which performs a bitwise logical union between two 8-bit operands. It illustrates how OR can be used to set specific bits within a register while keeping other bits unchanged. | [View](Source%20Code/Bitwise%20Operations/bitwise_or_logic_demonstration.asm) |
| `bitwise_rotate_left_circular_shift.asm` | Bitwise Left Circular Rotation (ROL) | This program demonstrates the 8086 'ROL' (Rotate Left) instruction. Unlike logical shifts which discard data, rotation preserves all bits by wrapping the Most Significant Bit (MSB) around to the Least Significant Bit (LSB). | [View](Source%20Code/Bitwise%20Operations/bitwise_rotate_left_circular_shift.asm) |
| `bitwise_rotate_right_circular_shift.asm` | Bitwise Right Circular Rotation (ROR) | This program demonstrates the 8086 'ROR' (Rotate Right) instruction. It demonstrates how bits shifted out of the Least Significant Bit (LSB) re-enter the register at the Most Significant Bit (MSB), maintaining data integrity. | [View](Source%20Code/Bitwise%20Operations/bitwise_rotate_right_circular_shift.asm) |
| `bitwise_set_membership.asm` | A Word Used As A Set | Sixteen members held in one word, with adding, removing, testing, union and intersection as single instructions. | [View](Source%20Code/Bitwise%20Operations/bitwise_set_membership.asm) |
| `bitwise_xor_logic_demonstration.asm` | Bitwise Logical XOR Operation (Exclusive-OR & Toggling) | This program demonstrates the 8086 'XOR' instruction, which performs a bitwise logical Exclusive-OR. XOR returns 1 ONLY when the corresponding bits of the operands are different. It is a versatile tool for toggling bit states and clearing registers. | [View](Source%20Code/Bitwise%20Operations/bitwise_xor_logic_demonstration.asm) |

</details>

<details>
<summary><strong>Conditional Jumps (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `indirect_jump_through_register.asm` | Jumping to an Address Held in a Register | Selects one of three routines by computing its address and jumping to it, without a chain of comparisons. | [View](Source%20Code/Conditional%20Jumps/indirect_jump_through_register.asm) |
| `jcxz_guard_before_a_loop.asm` | Guarding a Loop with JCXZ | Shows why a LOOP with a count of zero runs 65536 times, and how JCXZ prevents it in one instruction. | [View](Source%20Code/Conditional%20Jumps/jcxz_guard_before_a_loop.asm) |
| `jump_if_equal_or_not_equal.asm` | Branching on Equality | Compares two values and branches on the result, showing that JE and JZ are the same instruction under two names. | [View](Source%20Code/Conditional%20Jumps/jump_if_equal_or_not_equal.asm) |
| `jump_on_carry_flag.asm` | Branching on the Carry Flag | Detects an unsigned addition that did not fit, which is the carry flag's original purpose. | [View](Source%20Code/Conditional%20Jumps/jump_on_carry_flag.asm) |
| `jump_on_overflow_flag.asm` | Branching on the Overflow Flag | Detects a signed addition whose result is wrong, and shows that the carry flag stays clear while it happens. | [View](Source%20Code/Conditional%20Jumps/jump_on_overflow_flag.asm) |
| `jump_on_parity_flag.asm` | Branching on the Parity Flag | Uses the parity flag to check whether a byte has an even number of set bits, the flag's original use in serial communication. | [View](Source%20Code/Conditional%20Jumps/jump_on_parity_flag.asm) |
| `jump_on_sign_flag.asm` | Branching on the Sign Flag | Classifies a set of values as negative, zero or positive using JS and JZ, the shortest way to take the sign of a number. | [View](Source%20Code/Conditional%20Jumps/jump_on_sign_flag.asm) |
| `short_jump_range_and_bridging.asm` | The Range of a Conditional Jump | Explains the 128 byte reach of a conditional jump and shows the standard way to branch further: invert the test and bridge. | [View](Source%20Code/Conditional%20Jumps/short_jump_range_and_bridging.asm) |
| `signed_comparison_family.asm` | The Signed Branch Family | Runs every signed conditional jump against a negative and a positive value: greater, less, and the two that allow equality. | [View](Source%20Code/Conditional%20Jumps/signed_comparison_family.asm) |
| `signed_versus_unsigned_trap.asm` | The Same Bytes, Two Different Answers | Compares one pair of values with both the signed and the unsigned branches, and shows them reaching opposite conclusions. | [View](Source%20Code/Conditional%20Jumps/signed_versus_unsigned_trap.asm) |
| `test_instruction_before_branch.asm` | TEST, CMP, and Choosing Between Them | Uses TEST to examine individual bits without disturbing the value, and contrasts it with CMP and with a plain AND. | [View](Source%20Code/Conditional%20Jumps/test_instruction_before_branch.asm) |
| `unsigned_comparison_family.asm` | The Unsigned Branch Family | Runs every unsigned conditional jump against the same pair of values: above, below, and the two that allow equality. | [View](Source%20Code/Conditional%20Jumps/unsigned_comparison_family.asm) |

</details>

<details>
<summary><strong>Control Flow (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `computed_jump_into_a_table.asm` | Jumping Into A Table Of Addresses | A computed jump reaches one of several handlers in constant time, however many there are. | [View](Source%20Code/Control%20Flow/computed_jump_into_a_table.asm) |
| `conditional_branching_and_status_flags.asm` | Conditional Branching & Status Flags Reference | This program serves as a comprehensive reference for 8086 conditional jump instructions. It demonstrates how the CPU evaluates Status Flags (ZF, CF, SF, OF, PF) to decide program flow following arithmetic or comparison operations. | [View](Source%20Code/Control%20Flow/conditional_branching_and_status_flags.asm) |
| `do_while_post_test_loop.asm` | Testing A Loop At The Bottom Instead Of The Top | Testing at the bottom instead of the top, which is the right shape whenever the body must happen at least once. | [View](Source%20Code/Control%20Flow/do_while_post_test_loop.asm) |
| `for_loop_counter_iteration_pattern.asm` | For-Loop Counter Iteration Pattern | This program implements a standard 'for' loop structure using manual initialization, conditional branching, and increment logic. It provides a visual bridge between high-level control structures and low-level disassembly. | [View](Source%20Code/Control%20Flow/for_loop_counter_iteration_pattern.asm) |
| `guard_clauses_and_early_return.asm` | Guard Clauses Against Nested Conditions | The same validation written as a pyramid of nested tests and as a flat run of guards, with the same verdicts. | [View](Source%20Code/Control%20Flow/guard_clauses_and_early_return.asm) |
| `if_then_else_conditional_logic_structure.asm` | If-Then-Else Conditional Logic Structure | This program demonstrates the implementation of high-level if-then-else selection logic in 8086 Assembly. It highlights comparison mechanics (CMP) and the use of conditional vs unconditional jumps to redirect program execution flow. | [View](Source%20Code/Control%20Flow/if_then_else_conditional_logic_structure.asm) |
| `loop_instruction_cx_register_control.asm` | Loop Instruction (CX Register Hardware Control) | This program demonstrates the specific hardware-accelerated looping mechanism of the 8086. It utilizes the CX (Count) register and the LOOP primitive to perform iterative logic with minimal instruction overhead. | [View](Source%20Code/Control%20Flow/loop_instruction_cx_register_control.asm) |
| `nested_loops_with_early_exit.asm` | Leaving Two Loops At Once | Searching a table needs the inner loop and the outer loop to end together, which a single branch cannot do. | [View](Source%20Code/Control%20Flow/nested_loops_with_early_exit.asm) |
| `state_machine_transition_table.asm` | A State Machine Driven By A Table | The transitions live in data rather than in branches, so the machine can be read and changed without touching the code. | [View](Source%20Code/Control%20Flow/state_machine_transition_table.asm) |
| `switch_case_multiway_branching_logic.asm` | Switch-Case Multipath Branching (Jump Table Implementation) | This program demonstrates an optimized way to implement multi-way selection logic (Switch-Case) using a Jump Table. By storing offsets in an array, the program achieves O(1) branching complexity, skipping multiple sequential comparisons. | [View](Source%20Code/Control%20Flow/switch_case_multiway_branching_logic.asm) |
| `unconditional_jump_and_program_redirection.asm` | Unconditional Jump (JMP) and Program Redirection | This program demonstrates the 8086 'JMP' instruction, which causes an immediate, unconditional transfer of control to a target label by directly modifying the Instruction Pointer (IP). | [View](Source%20Code/Control%20Flow/unconditional_jump_and_program_redirection.asm) |
| `while_loop_pre_test_conditional_iteration.asm` | While Loop Structure (Pre-Test Conditional Iteration) | This program demonstrates the implementation of a 'while' loop structure in assembly. It highlights the "Pre-Test" pattern where the loop condition is evaluated at the start, ensuring the body executes zero or more times. | [View](Source%20Code/Control%20Flow/while_loop_pre_test_conditional_iteration.asm) |

</details>

<details>
<summary><strong>Conversion (23 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `ascii_to_integer.asm` | Reading a Number from Text | Turns a string of digits into a value, accepting a sign and stopping at the first character that is not a digit. | [View](Source%20Code/Conversion/ascii_to_integer.asm) |
| `bcd_to_ascii_and_back.asm` | Packed BCD to Text and Back | Unpacks a byte holding two decimal digits into printable characters, and packs them up again. | [View](Source%20Code/Conversion/bcd_to_ascii_and_back.asm) |
| `binary_to_decimal.asm` | Binary Text to a Value | Reads a string of ones and zeros into a number, using a shift in place of a multiplication. | [View](Source%20Code/Conversion/binary_to_decimal.asm) |
| `binary_to_hexadecimal_text.asm` | Binary Text to Hexadecimal Text | Converts between two written forms directly, four bits at a time, without turning the value into a number first. | [View](Source%20Code/Conversion/binary_to_hexadecimal_text.asm) |
| `celsius_fahrenheit_temperature_converter.asm` | Temperature Conversion | Convert Celsius to Fahrenheit and vice versa. Demonstrates arithmetic operations with formulas. | [View](Source%20Code/Conversion/celsius_fahrenheit_temperature_converter.asm) |
| `convert_decimal_to_binary_representation.asm` | Decimal to Binary Conversion | Convert a decimal number to its binary representation and display the result. | [View](Source%20Code/Conversion/convert_decimal_to_binary_representation.asm) |
| `convert_decimal_to_octal_representation.asm` | Decimal to Octal Conversion | Convert a decimal number entered by user to its octal (base-8) representation and display the result. | [View](Source%20Code/Conversion/convert_decimal_to_octal_representation.asm) |
| `convert_hexadecimal_to_decimal_string.asm` | Hexadecimal to Decimal String Conversion (Radix Extraction) | This program converts a 16-bit binary (hexadecimal) value into a human-readable decimal string. It demonstrates the use of the "Successive Division" algorithm combined with a Stack to correct digit order. | [View](Source%20Code/Conversion/convert_hexadecimal_to_decimal_string.asm) |
| `convert_hexadecimal_to_packed_bcd.asm` | Hexadecimal to Packed BCD Conversion (Repeated Subtraction) | This program converts a 16-bit hexadecimal number into its equivalent BCD (Binary Coded Decimal) representation. It utilizes the "Repeated Subtraction" method to extract decimal digits from Most Significant to Least Significant. | [View](Source%20Code/Conversion/convert_hexadecimal_to_packed_bcd.asm) |
| `convert_packed_bcd_to_hexadecimal.asm` | BCD to Hexadecimal Conversion | Convert a 16-bit BCD (Binary Coded Decimal) number to its equivalent hexadecimal value. | [View](Source%20Code/Conversion/convert_packed_bcd_to_hexadecimal.asm) |
| `decimal_to_any_base.asm` | Writing a Number in Any Base | Converts one value into base two, eight, ten and sixteen with a single routine, by making the base a parameter. | [View](Source%20Code/Conversion/decimal_to_any_base.asm) |
| `decimal_to_roman_numerals.asm` | Decimal to Roman Numerals | Writes a number in Roman numerals by taking away the largest value that still fits, over and over. | [View](Source%20Code/Conversion/decimal_to_roman_numerals.asm) |
| `gray_code_conversion.asm` | Gray Code | Converts to and from the code in which consecutive values differ in exactly one bit, which is why it is used on rotary encoders. | [View](Source%20Code/Conversion/gray_code_conversion.asm) |
| `hex_string_to_value.asm` | Reading Hexadecimal Text | Turns a string of hexadecimal digits into a value, accepting either case and stopping at anything else. | [View](Source%20Code/Conversion/hex_string_to_value.asm) |
| `hex_to_seven_segment_decoder_lookup.asm` | Seven Segment Display Decoder | Convert a hexadecimal digit (0-F) to its seven segment display pattern using a lookup table. | [View](Source%20Code/Conversion/hex_to_seven_segment_decoder_lookup.asm) |
| `number_to_words.asm` | Writing a Number in Words | Spells a number below one thousand, which needs the teens treated separately because they follow no pattern. | [View](Source%20Code/Conversion/number_to_words.asm) |
| `reverse_digits_of_integer_value.asm` | Reverse Digits of Integer Value | This program extracts decimal digits from an integer, stores them in an array, and then reconstructs a new integer in reverse order. Example: 12345 (Integer) -> 54321 (Integer). | [View](Source%20Code/Conversion/reverse_digits_of_integer_value.asm) |
| `roman_numerals_to_decimal.asm` | Roman Numerals to Decimal | Reads a Roman numeral by adding each letter's value, unless it is smaller than the one after it, in which case it is taken away. | [View](Source%20Code/Conversion/roman_numerals_to_decimal.asm) |
| `seconds_to_time_of_day.asm` | Seconds to Hours, Minutes and Seconds | Breaks a count of seconds into a clock reading, with each part padded to two digits. | [View](Source%20Code/Conversion/seconds_to_time_of_day.asm) |
| `string_comparison_lexicographical_check.asm` | Compare Two Strings | Compare two strings using CMPSB instruction. Demonstrates string comparison operations. | [View](Source%20Code/Conversion/string_comparison_lexicographical_check.asm) |
| `string_copy_using_manual_loop_iteration.asm` | String Copy Implementation (Manual Loop Iteration) | This program demonstrates how to copy data from a source to a destination using standard MOV and LOOP instructions. This approach is less efficient than the hardware primitives but more flexible for adding per-byte logic (e.g., case conversion). | [View](Source%20Code/Conversion/string_copy_using_manual_loop_iteration.asm) |
| `string_copy_using_movsb_instruction.asm` | String Copy Implementation (Hardware MOVSB Instruction) | This program demonstrates the most efficient way to copy a block of memory on the 8086: the 'REP MOVSB' primitive. It highlights the use of the Extra Segment (ES) and the Count Register (CX) for hardware-accelerated data movement. | [View](Source%20Code/Conversion/string_copy_using_movsb_instruction.asm) |
| `temperature_scales.asm` | Converting Between Temperature Scales | Converts Celsius to Fahrenheit and to Kelvin, using integer arithmetic ordered so that no precision is thrown away early. | [View](Source%20Code/Conversion/temperature_scales.asm) |

</details>

<details>
<summary><strong>Data Structures (15 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `balanced_parentheses.asm` | Balanced Brackets | Checks that every bracket is closed by the right kind in the right order, using a stack, and says where the first fault is. | [View](Source%20Code/Data%20Structures/balanced_parentheses.asm) |
| `binary_search_tree_in_array.asm` | A Binary Search Tree Held In Arrays | Insert and traverse a tree whose links are indices rather than addresses, which is how one is built without a heap. | [View](Source%20Code/Data%20Structures/binary_search_tree_in_array.asm) |
| `binary_tree_in_array.asm` | A Binary Tree Held in an Array | Stores a complete tree without any pointers, using the fact that a node at index i has its children at 2i+1 and 2i+2. | [View](Source%20Code/Data%20Structures/binary_tree_in_array.asm) |
| `circular_queue.asm` | Circular Queue | A fixed buffer used as a queue, where the head and tail wrap round the end so the space is reused instead of running out. | [View](Source%20Code/Data%20Structures/circular_queue.asm) |
| `deque_double_ended.asm` | A Double Ended Queue | A buffer that accepts and releases values at either end, which is a stack and a queue at the same time. | [View](Source%20Code/Data%20Structures/deque_double_ended.asm) |
| `evaluate_postfix.asm` | Evaluating a Postfix Expression | Works out the value of an expression written in postfix, which needs a stack and no precedence rules at all. | [View](Source%20Code/Data%20Structures/evaluate_postfix.asm) |
| `hash_table_linear_probing.asm` | A Hash Table with Linear Probing | Stores values at a position derived from the value itself, and steps forward when that position is already taken. | [View](Source%20Code/Data%20Structures/hash_table_linear_probing.asm) |
| `infix_to_postfix.asm` | Converting Infix to Postfix | Rewrites an ordinary expression into postfix by holding operators on a stack until something of lower precedence arrives. | [View](Source%20Code/Data%20Structures/infix_to_postfix.asm) |
| `linked_list_in_memory.asm` | A Linked List Built in Memory | Builds a chain of nodes that each hold a value and the offset of the next, then walks it and inserts into the middle. | [View](Source%20Code/Data%20Structures/linked_list_in_memory.asm) |
| `priority_queue_by_insertion.asm` | A Priority Queue | Keeps its contents in order as they arrive, so the most urgent item is always the one at the front. | [View](Source%20Code/Data%20Structures/priority_queue_by_insertion.asm) |
| `queue.asm` | First-In-First-Out (FIFO) Queue Implementation | This program implements a linear queue data structure using an array. It provides procedures for ENQUEUE (Insertion) and DEQUEUE (Deletion), managing FRONT and REAR pointers to track data flow. | [View](Source%20Code/Data%20Structures/queue.asm) |
| `set_union_and_intersection.asm` | Union and Intersection of Two Sets | Combines and compares two collections of small numbers using a bitmap, where each value is one bit. | [View](Source%20Code/Data%20Structures/set_union_and_intersection.asm) |
| `stack_array.asm` | Last-In-First-Out (LIFO) Stack Implementation | This program implements a custom Stack data structure using an array. Unlike the system stack (SS:SP), this "Software Stack" gives the developer full control over PUSH and POP operations, overflow checks, and Top-of-Stack (TOS) tracking. | [View](Source%20Code/Data%20Structures/stack_array.asm) |
| `stack_using_pointer.asm` | A Stack Addressed by Pointer | The same structure written with a moving pointer rather than an index, which is how it is done when speed matters. | [View](Source%20Code/Data%20Structures/stack_using_pointer.asm) |
| `stack_with_minimum.asm` | A Stack That Knows Its Smallest Value | Keeps the running minimum alongside the values, so the smallest item can be had at any moment without searching. | [View](Source%20Code/Data%20Structures/stack_with_minimum.asm) |

</details>

<details>
<summary><strong>Data Transfer (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `in_out_port_transfer.asm` | Moving Data Through a Port | Writes to a device port with OUT and reads it back with IN, the only instructions that reach outside the memory address space. | [View](Source%20Code/Data%20Transfer/in_out_port_transfer.asm) |
| `lahf_sahf_flag_transfer.asm` | Moving the Flags Through AH | Copies the arithmetic flags into AH with LAHF and restores them with SAHF, the cheaper alternative to PUSHF and POPF. | [View](Source%20Code/Data%20Transfer/lahf_sahf_flag_transfer.asm) |
| `lds_les_far_pointers.asm` | Loading a Far Pointer with LDS and LES | Loads a segment and offset pair in one instruction, which is how a program reaches data outside its own segment. | [View](Source%20Code/Data%20Transfer/lds_les_far_pointers.asm) |
| `lea_versus_offset.asm` | LEA, OFFSET, and the Difference From MOV | Contrasts loading an address with loading the contents of that address, the distinction that catches almost everyone once. | [View](Source%20Code/Data%20Transfer/lea_versus_offset.asm) |
| `mov_between_registers.asm` | MOV Between Registers | Moves a value along a chain of registers, showing that MOV copies rather than moves, and that the source is left untouched. | [View](Source%20Code/Data%20Transfer/mov_between_registers.asm) |
| `mov_immediate_forms.asm` | MOV With an Immediate Operand | Loads constants written in every base the assembler accepts, and shows that they all produce the same value. | [View](Source%20Code/Data%20Transfer/mov_immediate_forms.asm) |
| `mov_memory_and_register.asm` | MOV Between Memory and Registers | Reads a value out of memory, changes it in a register and writes it back, which is the shape of nearly every 8086 calculation. | [View](Source%20Code/Data%20Transfer/mov_memory_and_register.asm) |
| `mov_segment_registers.asm` | Loading the Segment Registers | Sets up DS and ES, reads them back, and explains why a segment register cannot be loaded with a constant directly. | [View](Source%20Code/Data%20Transfer/mov_segment_registers.asm) |
| `push_pop_stack_order.asm` | PUSH and POP, and the Order They Impose | Pushes three values and pops them back, showing that the stack returns them in the opposite order and that SP moves downward. | [View](Source%20Code/Data%20Transfer/push_pop_stack_order.asm) |
| `pushf_popf_preserve_flags.asm` | Preserving the Flags with PUSHF and POPF | Saves the flags across a calculation that would otherwise destroy them, which is what any routine that must not disturb its caller does. | [View](Source%20Code/Data%20Transfer/pushf_popf_preserve_flags.asm) |
| `xchg_swap_without_temporary.asm` | Swap Two Values with XCHG | Exchanges two registers, and then a register and a memory word, without the third variable the same job needs in most languages. | [View](Source%20Code/Data%20Transfer/xchg_swap_without_temporary.asm) |
| `xlat_lookup_table.asm` | Table Lookup with XLAT | Translates a run of values through a lookup table with XLAT, which does an indexed read in a single byte of code. | [View](Source%20Code/Data%20Transfer/xlat_lookup_table.asm) |

</details>

<details>
<summary><strong>DOS Services (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `dos_buffered_input_0ah.asm` | Reading a Line with Service 0Ah | Reads a whole line into a buffer, using the three part descriptor the service expects. | [View](Source%20Code/DOS%20Services/dos_buffered_input_0ah.asm) |
| `dos_create_and_write_file.asm` | Creating a File and Writing to It | Creates a file, writes a line into it and closes it, checking the carry flag after every step. | [View](Source%20Code/DOS%20Services/dos_create_and_write_file.asm) |
| `dos_delete_file.asm` | Deleting a File | Removes a file and demonstrates that opening it afterwards fails, which is how the deletion is confirmed. | [View](Source%20Code/DOS%20Services/dos_delete_file.asm) |
| `dos_direct_console_06h.asm` | Direct Console Input and Output with 06h | One service that both reads and writes depending on what is in DL, and returns immediately rather than waiting. | [View](Source%20Code/DOS%20Services/dos_direct_console_06h.asm) |
| `dos_exit_codes.asm` | Exit Codes | Ends a program with a value the caller can test, which is how a batch file decides what to do next. | [View](Source%20Code/DOS%20Services/dos_exit_codes.asm) |
| `dos_get_date_and_time.asm` | Reading the Date and the Time | Asks DOS what day and time it is and lays both out in the conventional order. | [View](Source%20Code/DOS%20Services/dos_get_date_and_time.asm) |
| `dos_menu_driven_program.asm` | A Menu Driven Program | Shows a menu, reads a choice and dispatches to it, which is the shape of most interactive DOS programs. | [View](Source%20Code/DOS%20Services/dos_menu_driven_program.asm) |
| `dos_password_masking.asm` | Reading a Password Without Showing It | Reads characters without echoing them, printing a star for each one, and allows a backspace to take one back. | [View](Source%20Code/DOS%20Services/dos_password_masking.asm) |
| `dos_print_string_09h.asm` | Printing a String with Service 09h | The service almost every DOS program uses, and the two things about it that catch people out. | [View](Source%20Code/DOS%20Services/dos_print_string_09h.asm) |
| `dos_read_character.asm` | Reading One Character: 01h, 07h and 08h | Three services that all read a key and differ in whether they echo it and whether they notice a break. | [View](Source%20Code/DOS%20Services/dos_read_character.asm) |
| `dos_read_file.asm` | Opening a File and Reading It Back | Writes a file, then opens it again and reads its contents into memory, which is where the handle really earns its keep. | [View](Source%20Code/DOS%20Services/dos_read_file.asm) |
| `dos_write_to_handle.asm` | Writing to the Screen Through a Handle | Uses the file writing service on the console, which is how a program writes text of a known length rather than a terminated string. | [View](Source%20Code/DOS%20Services/dos_write_to_handle.asm) |

</details>

<details>
<summary><strong>Expression (14 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `average_of_array.asm` | Array Average Calculation | This program calculates the integer average of a byte array. It sums all elements and divides by the count, demonstrating accumulator usage and division in 8086 assembly. | [View](Source%20Code/Expression/average_of_array.asm) |
| `calculator.asm` | Interactive 8086 Calculator | A menu-driven integer calculator supporting Addition, Subtraction, Multiplication, and Division. It demonstrates switch-case logic, string I/O, and procedure-based architecture. | [View](Source%20Code/Expression/calculator.asm) |
| `check_even_odd.asm` | Parity Check (Even/Odd) using Division | Determines if a user-supplied number is Even or Odd by checking the remainder of division by 2. | [View](Source%20Code/Expression/check_even_odd.asm) |
| `count_vowels.asm` | Vowel Counter (String Analysis) | Scans a string and counts the total number of vowels (A, E, I, O, U), case-insensitive. Demonstrates string traversal and conditional logic chains. | [View](Source%20Code/Expression/count_vowels.asm) |
| `count_words.asm` | Word Count Analysis (String Processing) | Analyzes a user-input sentence to count the number of words. The logic detects words by tracking transitions from delimiters (SPACES) to characters, handling multiple spaces correctly. | [View](Source%20Code/Expression/count_words.asm) |
| `factorial.asm` | Factorial Calculation (Recursion) | Computes the factorial of a number (N!) using value-passing recursion. Demonstrates stack frame management relative to procedures in 8086 assembly. | [View](Source%20Code/Expression/factorial.asm) |
| `fibonacci.asm` | Fibonacci Series Generator | Generates and displays the Fibonacci sequence (1, 1, 2, 3...) up to a specified count. Demonstrates iterative sequence generation and register swapping logic. | [View](Source%20Code/Expression/fibonacci.asm) |
| `gcd_two_numbers.asm` | Greatest Common Divisor (GCD) | Calculates the GCD of two numbers using the Euclidean Algorithm. GCD(a, b) = GCD(b, a % b). | [View](Source%20Code/Expression/gcd_two_numbers.asm) |
| `power.asm` | Power Calculation (Exponentiation) | Calculates Base^Exponent using iterative multiplication. Demonstrates simple loop-based arithmetic accumulation. | [View](Source%20Code/Expression/power.asm) |
| `prime_number_check.asm` | Prime Number Detector | Determines if a given 8-bit number is Prime. A prime number is only divisible by 1 and itself. This program uses a brute-force division loop from 2 to N-1. | [View](Source%20Code/Expression/prime_number_check.asm) |
| `quadratic_equation_roots.asm` | The Roots Of A Quadratic | The discriminant decides how many roots there are, and only then is a square root worth taking. | [View](Source%20Code/Expression/quadratic_equation_roots.asm) |
| `reverse_array.asm` | Array Reversal | Reverses the contents of a byte array. It uses a second buffer to store the reversed copy. In-place reversal (using XCHG) is an alternative not demonstrated here. | [View](Source%20Code/Expression/reverse_array.asm) |
| `string_concatenation.asm` | String Concatenation | Joins (concatenates) two user-provided strings into a single output string. Manages string length calculation and memory copy. | [View](Source%20Code/Expression/string_concatenation.asm) |
| `substring_search.asm` | Substring Search | Scans a "Main" string to see if it contains a specific "Target" substring. Implements a naive pattern matching algorithm (O(N*M)). | [View](Source%20Code/Expression/substring_search.asm) |

</details>

<details>
<summary><strong>External Devices (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `keyboard.asm` | BIOS Keyboard Interface | Demonstrates direct BIOS keyboard services (INT 16h) to capture and print keystrokes. It works at a lower level than DOS INT 21h, allowing detection of special keys like ESC. | [View](Source%20Code/External%20Devices/keyboard.asm) |
| `led_display_test.asm` | Virtual LED Display Control | Demonstrates I/O Port communication using the Emu8086 Virtual LED Display. It formats values for Port 199 to visualize numeric output. | [View](Source%20Code/External%20Devices/led_display_test.asm) |
| `mouse.asm` | Mouse Interface (INT 33h) | A comprehensive mouse handling program. Detects driver presence, tracks X/Y coordinates, and monitors Left/Right button clicks using interrupt services. | [View](Source%20Code/External%20Devices/mouse.asm) |
| `relay_bank_bit_control.asm` | Driving A Bank Of Relays | Eight relays on one port, switched individually without disturbing the other seven. | [View](Source%20Code/External%20Devices/relay_bank_bit_control.asm) |
| `robot.asm` | Autonomous Robot Controller | Controls a simulated robot navigating a grid. The robot utilizes sensors to detect walls and lamps, switching lamps ON/OFF and navigating random paths. | [View](Source%20Code/External%20Devices/robot.asm) |
| `seven_segment_multiplexed_display.asm` | Multiplexing A Four Digit Display | One set of segment lines shared between four digits, lit one at a time fast enough to look continuous. | [View](Source%20Code/External%20Devices/seven_segment_multiplexed_display.asm) |
| `stepper_motor.asm` | Stepper Motor Controller | Drives a 4-phase unipolar stepper motor using Port 7. Demonstrates Half-Step and Full-Step commutation sequences for precision control. | [View](Source%20Code/External%20Devices/stepper_motor.asm) |
| `thermometer_sampling_and_average.asm` | Sampling A Thermometer And Averaging | A single reading from a sensor is noise; a running average of several is a measurement. | [View](Source%20Code/External%20Devices/thermometer_sampling_and_average.asm) |
| `thermometer.asm` | Digital Thermostat Controller | Simulates a hysteresis-based temperature control system. Monitors a virtual thermometer and toggles a heater component to maintain temperature between 60"C and 80"C. | [View](Source%20Code/External%20Devices/thermometer.asm) |
| `timer.asm` | BIOS Timer Delay | Demonstrates the usage of BIOS Interrupt 15h (System Services) to create precise delays. Displays characters with 1-second intervals. Formatted as a Boot Sector simulation. | [View](Source%20Code/External%20Devices/timer.asm) |
| `traffic_lights_advanced.asm` | Advanced Traffic Control (Bitwise Ops) | Demonstrates controlling traffic lights using Bitwise Shifting operators to construct complex port signals dynamically. | [View](Source%20Code/External%20Devices/traffic_lights_advanced.asm) |
| `traffic_lights.asm` | 4-Way Traffic Light Controller | Controls a 4-way intersection traffic light system using Port 4. Sequences through standard Red-Green transitions with delays. | [View](Source%20Code/External%20Devices/traffic_lights.asm) |

</details>

<details>
<summary><strong>File Operations (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `append_to_file.asm` | Appending To A File | Opening a file leaves the position at the start, so appending means seeking to the end before writing. | [View](Source%20Code/File%20Operations/append_to_file.asm) |
| `copy_file_contents.asm` | Copying One File To Another | Reads a block, writes a block, and stops when the read comes back short, which is the only reliable end of file test. | [View](Source%20Code/File%20Operations/copy_file_contents.asm) |
| `create_file.asm` | Create New File | Demonstrates how to create a new file using DOS Interrupt 21h. The program attempts to create "TEST.TXT" in the current directory. | [View](Source%20Code/File%20Operations/create_file.asm) |
| `delete_file.asm` | Delete File | Deletes a specific file from the disk using DOS Interrupt 21h. Attempts to remove "DELETE_ME.TXT". | [View](Source%20Code/File%20Operations/delete_file.asm) |
| `file_error_handling.asm` | Decoding File Errors | Every failing file call is provoked deliberately and its error code turned into an explanation. | [View](Source%20Code/File%20Operations/file_error_handling.asm) |
| `file_random_access_records.asm` | Random Access To Fixed Length Records | With records all the same size, the position of record n is just n times the size, so any one can be read or written. | [View](Source%20Code/File%20Operations/file_random_access_records.asm) |
| `file_size_by_seek.asm` | Finding A File Size By Seeking | Seeking to the end with an offset of zero returns the length, which is the standard way to measure a file. | [View](Source%20Code/File%20Operations/file_size_by_seek.asm) |
| `open_existing_file.asm` | Opening A File That Already Exists | Service 3Dh with the three access modes, and the difference between opening and creating. | [View](Source%20Code/File%20Operations/open_existing_file.asm) |
| `read_file_in_chunks.asm` | Reading A File In Chunks And Counting It | A buffer smaller than the file, read repeatedly until it empties, counting lines and words on the way through. | [View](Source%20Code/File%20Operations/read_file_in_chunks.asm) |
| `read_file.asm` | Read File Content | Opens an existing text file ("INPUT.TXT") and reads its content into a buffer, then displays it to standard output. | [View](Source%20Code/File%20Operations/read_file.asm) |
| `rename_and_delete_file.asm` | Renaming And Deleting A File | Service 56h takes two names, one in DS:DX and one in ES:DI, and 41h removes a file outright. | [View](Source%20Code/File%20Operations/rename_and_delete_file.asm) |
| `write_file.asm` | Write to File | Creates (or overwrites) "OUTPUT.TXT" and writes a defined string of text into it. | [View](Source%20Code/File%20Operations/write_file.asm) |

</details>

<details>
<summary><strong>Flags (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `auxiliary_carry_and_bcd.asm` | The Auxiliary Carry Behind The BCD Adjust | Adds four pairs of packed decimal bytes, shows the auxiliary carry the addition left, and shows what DAA does with it. | [View](Source%20Code/Flags/auxiliary_carry_and_bcd.asm) |
| `carry_flag.asm` | Carry Flag (CF) Demonstration | Demonstrates how the Carry Flag (CF) is set during unsigned arithmetic overflow and how to manipulate it manually. | [View](Source%20Code/Flags/carry_flag.asm) |
| `carry_versus_overflow.asm` | Carry And Overflow Answer Different Questions | Adds four pairs of words and reports the carry and the overflow side by side, so that all four combinations of the two appear. | [View](Source%20Code/Flags/carry_versus_overflow.asm) |
| `direction_flag_and_strings.asm` | The Direction Flag | One flag decides whether the string instructions count up or down, and leaving it set is a classic way to break DOS. | [View](Source%20Code/Flags/direction_flag_and_strings.asm) |
| `flag_table_after_addition.asm` | Every Flag After A Single Addition | Adds five pairs of words and prints all six status flags after each one, taken from the flags word rather than from a branch. | [View](Source%20Code/Flags/flag_table_after_addition.asm) |
| `flags_preserved_across_a_call.asm` | Keeping The Flags Across A Call | A procedure that leaves the flags as it found them, and the same one that does not, compared on the same condition. | [View](Source%20Code/Flags/flags_preserved_across_a_call.asm) |
| `overflow_flag.asm` | Overflow Flag (OF) Demonstration | Demonstrates the conditions that set the Overflow Flag (OF), which indicates an error in Signed Arithmetic (result too large). | [View](Source%20Code/Flags/overflow_flag.asm) |
| `parity_as_error_check.asm` | The Parity Flag As A Transmission Check | Builds an odd parity bit onto each of four bytes, damages one bit of one byte, and uses the flag again to find the damage. | [View](Source%20Code/Flags/parity_as_error_check.asm) |
| `parity_flag.asm` | Parity Flag (PF) Demonstration | Demonstrates the Parity Flag (PF), which is set if the lower 8 bits of the result contain an even number of 1s (Even Parity). | [View](Source%20Code/Flags/parity_flag.asm) |
| `sign_flag_and_true_sign.asm` | When The Sign Flag Is Not The Sign | Adds signed words and works out the true sign of each answer, which is the sign flag corrected by the overflow flag. | [View](Source%20Code/Flags/sign_flag_and_true_sign.asm) |
| `sign_flag.asm` | Sign Flag (SF) Demonstration | Demonstrates how the Sign Flag (SF) reflects the Most Significant Bit (MSB) of the result, indicating negative numbers in signed arithmetic. | [View](Source%20Code/Flags/sign_flag.asm) |
| `zero_flag.asm` | Zero Flag (ZF) Demonstration | Demonstrates how the Zero Flag (ZF) indicates the result of arithmetic or comparison operations. | [View](Source%20Code/Flags/zero_flag.asm) |

</details>

<details>
<summary><strong>Graphics (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `bitmap_sprite_drawing.asm` | Drawing A Sprite From A Bitmap | A shape held as rows of bits, plotted pixel by pixel, which is how every sprite on hardware of this era was stored. | [View](Source%20Code/Graphics/bitmap_sprite_drawing.asm) |
| `bresenham_line_algorithm.asm` | Bresenham Line Drawing | Draws a line using only addition, subtraction and comparison, which is why it was the standard method on hardware like this. | [View](Source%20Code/Graphics/bresenham_line_algorithm.asm) |
| `colored_text.asm` | Direct Video Memory Access (Colored Text) | Demonstrates how to write directly to the Video Graphics Array (VGA) memory at segment 0B800h to display colored text. | [View](Source%20Code/Graphics/colored_text.asm) |
| `colour_attribute_table.asm` | The Text Mode Colour Attributes | Writes every foreground and background combination directly into video memory, where the attribute byte lives. | [View](Source%20Code/Graphics/colour_attribute_table.asm) |
| `draw_line.asm` | Draw Line (VGA Mode 13h) | Demonstrates drawing a horizontal line in 320x200 256-color mode using direct memory access (Segment A000h). | [View](Source%20Code/Graphics/draw_line.asm) |
| `draw_pixel.asm` | Plot Single Pixel | Basic graphics primitive: plotting a single dot on the screen at coordinates (X, Y) in Mode 13h. | [View](Source%20Code/Graphics/draw_pixel.asm) |
| `draw_rectangle.asm` | Draw Filled Rectangle | Draws a solid colored rectangle by iteratively drawing horizontal lines. | [View](Source%20Code/Graphics/draw_rectangle.asm) |
| `screen_clear_and_scroll.asm` | Clearing And Scrolling The Screen | Service 06h scrolls a rectangle, and scrolling one by zero lines is how the screen is cleared. | [View](Source%20Code/Graphics/screen_clear_and_scroll.asm) |
| `text_mode_bar_chart.asm` | A Bar Chart In Text Mode | Scales a set of values to the width available and draws one row per value, with the value printed beside it. | [View](Source%20Code/Graphics/text_mode_bar_chart.asm) |
| `text_mode_box_drawing.asm` | Drawing A Box In Text Mode | Builds a bordered box out of characters, emitted in reading order, with a caption centred inside it. | [View](Source%20Code/Graphics/text_mode_box_drawing.asm) |
| `vertical_histogram_with_axis.asm` | A Vertical Histogram With An Axis | Draws columns upwards rather than bars sideways, which means the screen has to be built one row at a time. | [View](Source%20Code/Graphics/vertical_histogram_with_axis.asm) |
| `vga_mode_13h_pixels.asm` | Plotting Pixels In Mode 13h | Sets the 320 by 200 graphics mode and writes pixels through the BIOS, then restores the text mode it started in. | [View](Source%20Code/Graphics/vga_mode_13h_pixels.asm) |

</details>

<details>
<summary><strong>Input Output (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `display_binary.asm` | Display Binary Representation | Converts a 16-bit integer into its 8-bit or 16-bit Binary ASCII string and displays it on the console. | [View](Source%20Code/Input%20Output/display_binary.asm) |
| `display_decimal.asm` | Display Decimal Representation | Converts a 16-bit integer into its Decimal (Base 10) ASCII string using repeated division logic. | [View](Source%20Code/Input%20Output/display_decimal.asm) |
| `display_hex.asm` | Display Hexadecimal Representation | Converts a 16-bit integer into its Hexadecimal (Base 16) ASCII string using bitwise rotation and lookup logic. | [View](Source%20Code/Input%20Output/display_hex.asm) |
| `echo_until_enter.asm` | Echoing Characters Until Enter | Reads and echoes one character at a time, counting what arrives, and stops on a carriage return. | [View](Source%20Code/Input%20Output/echo_until_enter.asm) |
| `formatted_column_output.asm` | Printing A Table In Aligned Columns | Right aligns numbers and pads names, so a table reads as a table rather than as a ragged list. | [View](Source%20Code/Input%20Output/formatted_column_output.asm) |
| `print_signed_numbers.asm` | Printing Signed Numbers | A negative word printed as unsigned reads as a large positive one, so the sign has to be handled deliberately. | [View](Source%20Code/Input%20Output/print_signed_numbers.asm) |
| `read_and_validate_digits.asm` | Reading A Number And Rejecting Rubbish | Every character is checked before it is used, so a typing mistake produces a message rather than a wrong answer. | [View](Source%20Code/Input%20Output/read_and_validate_digits.asm) |
| `read_buffered_string.asm` | Reading A Line With A Buffered Input | Service 0Ah reads a whole line into a buffer whose first two bytes describe it, which is what makes backspace work. | [View](Source%20Code/Input%20Output/read_buffered_string.asm) |
| `read_hexadecimal_input.asm` | Reading A Hexadecimal Number | Accepts the digits 0 to 9 and the letters A to F in either case, which needs three ranges rather than one. | [View](Source%20Code/Input%20Output/read_hexadecimal_input.asm) |
| `read_key_without_echo.asm` | Reading A Key Without Echoing It | Services 07h and 08h read a key without printing it, which is what a password prompt or a menu needs. | [View](Source%20Code/Input%20Output/read_key_without_echo.asm) |
| `read_number.asm` | Read Decimal Number Input | Reads a sequence of decimal digit characters mainly from the keyboard and converts them into a 16-bit integer value in AX. | [View](Source%20Code/Input%20Output/read_number.asm) |
| `yes_no_confirmation.asm` | A Yes Or No Confirmation | Accepts either case, rejects anything else, and gives up after a fixed number of attempts rather than looping for ever. | [View](Source%20Code/Input%20Output/yes_no_confirmation.asm) |

</details>

<details>
<summary><strong>Interrupts (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `bios_cursor_position.asm` | BIOS Set Cursor Position | Demonstrates how to position the text cursor on the screen using BIOS Interrupt 10H, Function 02H. | [View](Source%20Code/Interrupts/bios_cursor_position.asm) |
| `bios_keyboard.asm` | BIOS Keyboard Input (Raw) | Reads keyboard input using BIOS Interrupt 16H. This provides access to both ASCII characters and hardware scan codes. | [View](Source%20Code/Interrupts/bios_keyboard.asm) |
| `bios_system_time.asm` | BIOS System Time | Reads the System Clock Tick Counter using BIOS Interrupt 1Ah. The counter increments approximately 18.2 times per second. | [View](Source%20Code/Interrupts/bios_system_time.asm) |
| `bios_versus_dos_output.asm` | BIOS Output Against DOS Output | The same characters written three ways, and what each layer costs and offers. | [View](Source%20Code/Interrupts/bios_versus_dos_output.asm) |
| `bios_video_mode.asm` | BIOS Set Video Mode | Demonstrates how to switch video modes via BIOS (INT 10h). Switches to 80x25 Color Text Mode (Mode 03h). | [View](Source%20Code/Interrupts/bios_video_mode.asm) |
| `dos_character_services_compared.asm` | The Five Ways DOS Reads And Writes A Character | Services 01h, 02h, 06h, 07h and 08h differ in echoing, in waiting, and in whether they notice a break. | [View](Source%20Code/Interrupts/dos_character_services_compared.asm) |
| `dos_display_char.asm` | DOS Display Character | Displays a single character using DOS Interrupt 21H, Function 02H. | [View](Source%20Code/Interrupts/dos_display_char.asm) |
| `dos_display_string.asm` | DOS Display String | Displays a '$' terminated string using DOS Interrupt 21H, Function 09H. | [View](Source%20Code/Interrupts/dos_display_string.asm) |
| `dos_read_char.asm` | DOS Read Character | Reads a single character from Standard Input with ECHO using DOS Interrupt 21H, Function 01H. | [View](Source%20Code/Interrupts/dos_read_char.asm) |
| `dos_read_string.asm` | DOS Buffered String Input | Reads a string from the keyboard into a buffer using DOS Interrupt 21H, Function 0Ah. Allows backspace editing. | [View](Source%20Code/Interrupts/dos_read_string.asm) |
| `interrupt_error_conventions.asm` | How An Interrupt Reports Failure | DOS uses the carry flag and an error code in AX, and the convention is worth learning once rather than per service. | [View](Source%20Code/Interrupts/interrupt_error_conventions.asm) |
| `interrupt_vector_table.asm` | Reading The Interrupt Vector Table | The first kilobyte of memory is 256 far pointers, one per interrupt, and any of them can simply be read. | [View](Source%20Code/Interrupts/interrupt_vector_table.asm) |

</details>

<details>
<summary><strong>Introduction (15 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `data_definition_demo.asm` | Code And Data Are The Same Bytes | Lays out the machine code of three instructions as raw bytes, names every one of them, and then runs the instructions they spell so the two can be compared. | [View](Source%20Code/Introduction/data_definition_demo.asm) |
| `display_characters.asm` | Display Characters | Demonstrate character-by-character output using DOS services. Useful for building dynamic text in loops. | [View](Source%20Code/Introduction/display_characters.asm) |
| `display_string_direct.asm` | Display String Direct | Direct string output demonstration using the DOS 09H service with a standard segment layout. | [View](Source%20Code/Introduction/display_string_direct.asm) |
| `display_system_time.asm` | Display System Time | Fetch and display the current system time (HH:MM:SS.ms) using DOS Interrupt 21H / AH=2CH. | [View](Source%20Code/Introduction/display_system_time.asm) |
| `hello_world_dos.asm` | Hello World (DOS COM style) | Smallest possible "Hello World" using DOS Interrupt 21H in a single-segment COM utility. | [View](Source%20Code/Introduction/hello_world_dos.asm) |
| `hello_world_interrupt.asm` | Hello World (Interrupt-based) | Demonstrate character-by-character printing using BIOS TTY sub-function (INT 10H / AH=0EH). | [View](Source%20Code/Introduction/hello_world_interrupt.asm) |
| `hello_world_procedure_advanced.asm` | Hello World Procedure (Advanced) | Refined version of the string-printing procedure demonstration, focusing on the use of SI as a source pointer and null-termination. | [View](Source%20Code/Introduction/hello_world_procedure_advanced.asm) |
| `hello_world_procedure.asm` | Hello World Procedure | Demonstrate string printing by passing a string address to a custom procedure called 'PRINT_ME'. | [View](Source%20Code/Introduction/hello_world_procedure.asm) |
| `hello_world_string.asm` | Hello World (Segmented EXE style) | Standard multi-segment application structure displaying a string using DOS services. | [View](Source%20Code/Introduction/hello_world_string.asm) |
| `hello_world_vga.asm` | Hello World (Direct VGA Memory) | Display "Hello, World!" by writing directly to the video memory segment 0B800h in text mode. | [View](Source%20Code/Introduction/hello_world_vga.asm) |
| `keyboard_wait_input.asm` | Keyboard Wait (Input Interception) | Demonstrates how to pause program execution by waiting for a BIOS keyboard event (INT 16H / AH=00H). | [View](Source%20Code/Introduction/keyboard_wait_input.asm) |
| `mov_instruction_demo.asm` | MOV Instruction Demo | Demonstrates the MOV instruction for transferring data between memory variables and CPU registers. | [View](Source%20Code/Introduction/mov_instruction_demo.asm) |
| `print_alphabets.asm` | Print Alphabets (Full Set) | Display the entire English alphabet in both Uppercase (A-Z) and Lowercase (a-z) using loops and ASCII arithmetic. | [View](Source%20Code/Introduction/print_alphabets.asm) |
| `procedure_demo.asm` | Procedure Call Demo | Demonstrate defining and calling a basic procedure using CALL and RET instructions in a COM-style program. | [View](Source%20Code/Introduction/procedure_demo.asm) |
| `procedure_multiplication.asm` | Reusable Multiplication Procedure | Demonstrate multiple calls to a single multiplication procedure that uses registers for parameter passing. | [View](Source%20Code/Introduction/procedure_multiplication.asm) |

</details>

<details>
<summary><strong>Loops (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `countdown_versus_countup.asm` | Counting Down Rather Than Up | Runs the same loop both ways and shows why counting down is shorter: the comparison against zero is free. | [View](Source%20Code/Loops/countdown_versus_countup.asm) |
| `loop_counted_with_cx.asm` | The Counted Loop | The plainest use of LOOP: run a body a fixed number of times, with CX as the counter the instruction maintains for you. | [View](Source%20Code/Loops/loop_counted_with_cx.asm) |
| `loop_over_two_arrays.asm` | Walking Two Arrays at Once | Advances two pointers in step to combine a pair of arrays, using SI for one and DI for the other. | [View](Source%20Code/Loops/loop_over_two_arrays.asm) |
| `loop_skipping_elements.asm` | Skipping an Element Inside a Loop | Sums only the even numbers in an array, jumping over the rest, which is what a continue statement compiles into. | [View](Source%20Code/Loops/loop_skipping_elements.asm) |
| `loop_unrolling.asm` | Unrolling a Loop | Does four elements per pass instead of one, trading code size for a quarter of the loop overhead. | [View](Source%20Code/Loops/loop_unrolling.asm) |
| `loop_walking_an_array.asm` | Walking an Array with a Pointer | Combines a counter in CX with a pointer in SI, the standard shape of every array loop on this processor. | [View](Source%20Code/Loops/loop_walking_an_array.asm) |
| `loop_with_computed_step.asm` | Stepping by More Than One | Visits every third element of an array by advancing the pointer further each pass, and derives the count rather than assuming it. | [View](Source%20Code/Loops/loop_with_computed_step.asm) |
| `loop_with_early_exit.asm` | Leaving a Loop Early | Stops as soon as a condition is met rather than running to the end, which is what a break statement compiles into. | [View](Source%20Code/Loops/loop_with_early_exit.asm) |
| `loope_repeat_while_equal.asm` | LOOPE: Repeat While Equal | Scans a run of bytes for the first one that is not a space, stopping either at the difference or when the count runs out. | [View](Source%20Code/Loops/loope_repeat_while_equal.asm) |
| `loopne_search_until_found.asm` | LOOPNE: Repeat Until a Match | Searches an array for a value, leaving as soon as it is found or when every element has been examined. | [View](Source%20Code/Loops/loopne_search_until_found.asm) |
| `nested_loops_multiplication_table.asm` | Nested Loops and Saving the Counter | Prints a multiplication table with a loop inside a loop, which cannot work until the outer counter is saved from the inner one. | [View](Source%20Code/Loops/nested_loops_multiplication_table.asm) |
| `post_test_loop.asm` | A Loop That Always Runs Once | Puts the test at the bottom, so the body runs before anything is checked, which is the do-while shape. | [View](Source%20Code/Loops/post_test_loop.asm) |

</details>

<details>
<summary><strong>Macros (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `conditional_assembly_switches.asm` | Conditional Assembly From A Switch | One source file that assembles to different programs depending on a constant set at the top. | [View](Source%20Code/Macros/conditional_assembly_switches.asm) |
| `conditional_macros.asm` | Conditional Assembly Macros | Demonstrates the use of IF/ELSE/ENDIF conditional directives within macros to handle different data types (Byte vs Word). | [View](Source%20Code/Macros/conditional_macros.asm) |
| `macro_building_data_tables.asm` | Building A Data Table With A Macro | Macros can emit data as readily as instructions, which keeps a table and its length honest with each other. | [View](Source%20Code/Macros/macro_building_data_tables.asm) |
| `macro_expansion_pitfalls.asm` | The Three Macro Traps | A macro is text substitution, and each of its three classic surprises follows directly from that. | [View](Source%20Code/Macros/macro_expansion_pitfalls.asm) |
| `macro_library_of_helpers.asm` | A Small Macro Library | Macros built out of other macros, which is how an assembly project grows a vocabulary of its own. | [View](Source%20Code/Macros/macro_library_of_helpers.asm) |
| `macro_local_labels.asm` | Local Labels Inside A Macro | A macro containing a loop needs LOCAL, or the second use redefines the label the first one made. | [View](Source%20Code/Macros/macro_local_labels.asm) |
| `macro_repeat_and_fill.asm` | Repetition Done By The Assembler | A macro that expands its body a fixed number of times, so the repetition costs nothing at run time. | [View](Source%20Code/Macros/macro_repeat_and_fill.asm) |
| `macro_versus_procedure.asm` | A Macro Against A Procedure | The same job written both ways, with the trade being code size against the cost of a call. | [View](Source%20Code/Macros/macro_versus_procedure.asm) |
| `macro_with_parameters.asm` | Macro with Parameters | Demonstrates how to define and use macros that accept arguments to perform arithmetic and bitwise operations. | [View](Source%20Code/Macros/macro_with_parameters.asm) |
| `macro_with_register_argument.asm` | A Macro Taking A Register Name | Because a macro argument is text, a register name can be passed as an argument, which no procedure can do. | [View](Source%20Code/Macros/macro_with_register_argument.asm) |
| `nested_macros.asm` | Nested Macros Implementation | Demonstrates macro nesting (macros calling other macros) and the 'LOCAL' directive to prevent label collision. | [View](Source%20Code/Macros/nested_macros.asm) |
| `print_string_macro.asm` | Standard String Macro | Encapsulates DOS string display and newline logic into simplistic reusable macros to clean up the main code structure. | [View](Source%20Code/Macros/print_string_macro.asm) |

</details>

<details>
<summary><strong>Mathematics (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `armstrong_number.asm` | Armstrong Number Check | Check if a 16-bit number is an Armstrong number. For a 3-digit number, Armstrong property means: Number = (Digit1^3) + (Digit2^3) + (Digit3^3) | [View](Source%20Code/Mathematics/armstrong_number.asm) |
| `averaging_without_overflow.asm` | Averaging Without Overflowing | Ten large readings whose total will not fit in one word. Shows the wrong answer a single word gives, then two methods that are right: a wide accumulator, and dividing each term first. | [View](Source%20Code/Mathematics/averaging_without_overflow.asm) |
| `euclid_gcd_traced.asm` | Euclid's Algorithm Traced Step by Step | Prints the division that Euclid's rule performs at every stage, so the shrinking remainders can be read off, and then folds the same rule across a list of numbers. | [View](Source%20Code/Mathematics/euclid_gcd_traced.asm) |
| `fixed_point_eight_eight.asm` | Fixed Point Arithmetic in Q8.8 | Holds a fractional value as a whole number of two hundred and fifty sixths, so that addition needs nothing new and only the multiply and the divide have to correct the scale. | [View](Source%20Code/Mathematics/fixed_point_eight_eight.asm) |
| `lcm.asm` | Least Common Multiple (LCM) | Calculate the LCM of two 16-bit numbers using the relationship: LCM(a, b) = (a * b) / GCD(a, b). | [View](Source%20Code/Mathematics/lcm.asm) |
| `percentage_and_ratio.asm` | Percentage and Ratio, Multiply Before Divide | Integer division throws away the fraction, so the scaling has to happen first. Shows what dividing first costs, takes one decimal place from the remainder, and guards the division that follows. | [View](Source%20Code/Mathematics/percentage_and_ratio.asm) |
| `perfect_number.asm` | Perfect Number Check | Determine if a 16-bit number is "Perfect". A Perfect number is equal to the sum of its proper divisors. | [View](Source%20Code/Mathematics/perfect_number.asm) |
| `power_by_repeated_squaring.asm` | Power by Repeated Squaring | Raises a number to a power by reading the exponent as binary and squaring the base once per bit, which costs a count proportional to the number of bits rather than to the exponent itself. | [View](Source%20Code/Mathematics/power_by_repeated_squaring.asm) |
| `rounding_a_quotient.asm` | Rounding a Quotient Three Different Ways | DIV always rounds towards zero. The remainder it leaves behind carries everything needed to round up instead, or to round to the nearest, without ever risking an overflow. | [View](Source%20Code/Mathematics/rounding_a_quotient.asm) |
| `square_root.asm` | Integer Square Root | Calculate the integer part of the square root of a 16-bit unsigned number using the iterative 'Square Search' method. | [View](Source%20Code/Mathematics/square_root.asm) |
| `twos_complement.asm` | Two's Complement (Negation) | Demonstrate how to negate a signed 16-bit integer using the Two's Complement arithmetic method. | [View](Source%20Code/Mathematics/twos_complement.asm) |
| `wide_addition_and_subtraction.asm` | A 32-bit Sum Held in Two Registers | Adds and subtracts values too large for one word by keeping each in a pair of words and letting ADC and SBB carry the flag from the low half into the high half. | [View](Source%20Code/Mathematics/wide_addition_and_subtraction.asm) |

</details>

<details>
<summary><strong>Matrix (15 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `matrix_addition.asm` | Matrix Addition (3x3) | Demonstrate element-wise addition of two 3x3 matrices stored in row-major order. | [View](Source%20Code/Matrix/matrix_addition.asm) |
| `matrix_determinant_3x3.asm` | The Determinant Of A Three By Three Matrix | Expansion along the first row, with the signed arithmetic done carefully because the minors can be negative. | [View](Source%20Code/Matrix/matrix_determinant_3x3.asm) |
| `matrix_determinant.asm` | Determinant of a Three by Three | Computes a determinant by expanding along the first row, with all the arithmetic done in signed values. | [View](Source%20Code/Matrix/matrix_determinant.asm) |
| `matrix_is_identity.asm` | Testing for the Identity Matrix | Checks that a matrix has ones on the diagonal and zeros everywhere else, in a single pass over all its cells. | [View](Source%20Code/Matrix/matrix_is_identity.asm) |
| `matrix_is_symmetric.asm` | Testing a Matrix for Symmetry | Decides whether a matrix equals its own transpose, comparing only the cells above the diagonal. | [View](Source%20Code/Matrix/matrix_is_symmetric.asm) |
| `matrix_largest_and_smallest.asm` | Largest and Smallest Element | Finds the extremes of a matrix and reports which row and column each was found in. | [View](Source%20Code/Matrix/matrix_largest_and_smallest.asm) |
| `matrix_multiplication.asm` | Matrix Multiplication | Multiplies two three by three matrices, walking one along its rows and the other down its columns. | [View](Source%20Code/Matrix/matrix_multiplication.asm) |
| `matrix_rotate_ninety_degrees.asm` | Rotate a Matrix by Ninety Degrees | Turns a matrix a quarter turn clockwise, by transposing it and then reversing each row. | [View](Source%20Code/Matrix/matrix_rotate_ninety_degrees.asm) |
| `matrix_row_and_column_sums.asm` | Row and Column Sums | Totals every row and every column, and checks the two grand totals against each other. | [View](Source%20Code/Matrix/matrix_row_and_column_sums.asm) |
| `matrix_scalar_multiply.asm` | Multiply a Matrix by a Scalar | Scales every element by the same value, and shows the shift that replaces the multiplication when the scalar is a power of two. | [View](Source%20Code/Matrix/matrix_scalar_multiply.asm) |
| `matrix_sparse_count.asm` | Counting the Zeros in a Matrix | Counts how much of a matrix is empty and decides whether it is sparse enough to be worth storing differently. | [View](Source%20Code/Matrix/matrix_sparse_count.asm) |
| `matrix_subtraction.asm` | Matrix Subtraction | Subtracts one matrix from another element by element, which needs only a single loop because the shape never enters into it. | [View](Source%20Code/Matrix/matrix_subtraction.asm) |
| `matrix_trace_and_diagonals.asm` | Trace and Both Diagonals | Adds the leading diagonal and the other one, each reachable with a single stride rather than a nested loop. | [View](Source%20Code/Matrix/matrix_trace_and_diagonals.asm) |
| `matrix_transpose.asm` | Matrix Transpose (3x3) | Transpose a 3x3 matrix (swap rows with columns) using nested loops and linear index calculation. | [View](Source%20Code/Matrix/matrix_transpose.asm) |
| `matrix_upper_lower_triangular.asm` | Upper and Lower Triangular Tests | Decides whether a matrix has zeros below or above its diagonal, which is what makes a system of equations easy to solve. | [View](Source%20Code/Matrix/matrix_upper_lower_triangular.asm) |

</details>

<details>
<summary><strong>Memory Operations (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `block_checksum.asm` | Checksum Over A Memory Block | Adds a block of bytes into a sixteen bit total, derives the one byte checksum that drives the low half of that total to zero, and shows the check failing after a single byte is disturbed. | [View](Source%20Code/Memory%20Operations/block_checksum.asm) |
| `block_copy.asm` | Memory Block Copy | Demonstrate efficient memory-to-memory data transfer using the 8086 specialized string instruction MOVSB. | [View](Source%20Code/Memory%20Operations/block_copy.asm) |
| `exchange_two_blocks.asm` | Exchange Two Blocks Of Memory | Swaps the contents of two separate blocks without a temporary area, by carrying each element through one register and letting XCHG do the crossing over against memory. | [View](Source%20Code/Memory%20Operations/exchange_two_blocks.asm) |
| `hexadecimal_and_ascii_dump.asm` | A Hexadecimal And ASCII Dump Of Memory | Prints a block sixteen bytes to the row, giving the offset, the bytes in hexadecimal and the same bytes as text, with a short final row padded so that the text column still lines up. | [View](Source%20Code/Memory%20Operations/hexadecimal_and_ascii_dump.asm) |
| `largest_and_smallest_one_pass.asm` | Largest And Smallest In One Pass | Finds both extremes of a block in a single walk by taking the values two at a time, so that three comparisons settle a pair where the obvious method spends four. | [View](Source%20Code/Memory%20Operations/largest_and_smallest_one_pass.asm) |
| `memory_compare.asm` | Memory Block Comparison | Compare two memory buffers for equality using the 8086 CMPSB (Compare String Byte) instruction. | [View](Source%20Code/Memory%20Operations/memory_compare.asm) |
| `memory_fill.asm` | Memory Block Fill | Initialize a block of memory with a specific constant byte using the STOSB (Store String Byte) instruction. | [View](Source%20Code/Memory%20Operations/memory_fill.asm) |
| `memory_scan.asm` | Memory Search (Scan) | Search for the first occurrence of a specific byte within a memory block using the SCASB (Scan String Byte) instruction. | [View](Source%20Code/Memory%20Operations/memory_scan.asm) |
| `overlapping_block_move.asm` | Overlapping Block Move Copied Backwards | Moves a block three places up inside itself, first forwards to show the damage that does, then backwards with the direction flag set, which is the only order that survives the overlap. | [View](Source%20Code/Memory%20Operations/overlapping_block_move.asm) |
| `reverse_block_in_place.asm` | Reverse A Block In Place | Turns a block of bytes end for end without a second buffer, by walking one pointer up and one pointer down and exchanging the pair they meet on until the two of them collide. | [View](Source%20Code/Memory%20Operations/reverse_block_in_place.asm) |
| `rotate_block_left.asm` | Rotate A Block Left By N Places | Lifts the leading bytes aside, slides the remainder down to the front and puts the lifted bytes on the end, having first reduced the requested distance modulo the length of the block. | [View](Source%20Code/Memory%20Operations/rotate_block_left.asm) |
| `word_pattern_fill.asm` | Fill A Block With A Repeating Word Pattern | Lays a two byte pattern across a block with STOSW, which does half as many stores as STOSB, and stores the odd byte on its own when the block does not divide evenly into words. | [View](Source%20Code/Memory%20Operations/word_pattern_fill.asm) |

</details>

<details>
<summary><strong>Number Theory (13 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `armstrong_number_check.asm` | Armstrong Numbers | A number equal to the sum of its own digits each raised to the number of digits, checked across a range. | [View](Source%20Code/Number%20Theory/armstrong_number_check.asm) |
| `binomial_coefficient.asm` | Binomial Coefficient | Computes n choose r by multiplying and dividing alternately, so that no intermediate value grows beyond a word. | [View](Source%20Code/Number%20Theory/binomial_coefficient.asm) |
| `classify_by_divisor_sum.asm` | Abundant, Deficient or Perfect | Adds up the proper divisors of several numbers and classifies each by how the total compares with the number itself. | [View](Source%20Code/Number%20Theory/classify_by_divisor_sum.asm) |
| `collatz_sequence_length.asm` | Length of a Collatz Sequence | Counts how many steps a number takes to reach one under the rule halve if even, otherwise treble and add one. | [View](Source%20Code/Number%20Theory/collatz_sequence_length.asm) |
| `coprime_check.asm` | Testing Whether Two Numbers Are Coprime | Decides whether two numbers share any factor, by computing their greatest common divisor with the remainder form of Euclid's method. | [View](Source%20Code/Number%20Theory/coprime_check.asm) |
| `count_divisors.asm` | Count the Divisors of a Number | Counts how many numbers divide a value exactly, stopping at the square root and counting each pair of factors together. | [View](Source%20Code/Number%20Theory/count_divisors.asm) |
| `digital_root.asm` | Digital Root | Adds the digits of a number over and over until one digit is left, then checks the result against the shortcut formula. | [View](Source%20Code/Number%20Theory/digital_root.asm) |
| `happy_number_check.asm` | Happy Numbers | Repeatedly replaces a number with the sum of the squares of its digits, and detects the cycle that shows it will never reach one. | [View](Source%20Code/Number%20Theory/happy_number_check.asm) |
| `modular_exponentiation.asm` | Modular Exponentiation | Raises a number to a power under a modulus by squaring, which keeps every intermediate value small enough for a word. | [View](Source%20Code/Number%20Theory/modular_exponentiation.asm) |
| `prime_factorisation.asm` | Prime Factorisation | Breaks a number into its prime factors by dividing out the smallest factor repeatedly until nothing is left but one. | [View](Source%20Code/Number%20Theory/prime_factorisation.asm) |
| `sieve_of_eratosthenes.asm` | Sieve of Eratosthenes | Finds every prime below fifty by striking out the multiples of each prime in turn, rather than testing each number separately. | [View](Source%20Code/Number%20Theory/sieve_of_eratosthenes.asm) |
| `sum_of_squares_and_cubes.asm` | Sums of Squares and Cubes | Adds the squares and the cubes of the first ten numbers, and checks the striking identity between the cubes and the plain sum. | [View](Source%20Code/Number%20Theory/sum_of_squares_and_cubes.asm) |
| `triangular_numbers.asm` | Triangular Numbers | Produces the running totals 1, 3, 6, 10 and so on, and checks each against the closed formula for the same value. | [View](Source%20Code/Number%20Theory/triangular_numbers.asm) |

</details>

<details>
<summary><strong>Patterns (16 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `alphabet_triangle.asm` | A Triangle of Letters | Fills a triangle with letters, one pattern restarting the alphabet on each row and one carrying on through it. | [View](Source%20Code/Patterns/alphabet_triangle.asm) |
| `binary_pattern.asm` | A Triangle of Ones and Zeros | Fills a triangle with alternating bits, where each cell depends on whether its row and column sum to an even number. | [View](Source%20Code/Patterns/binary_pattern.asm) |
| `butterfly_pattern.asm` | A Butterfly | Two triangles facing each other with a widening gap, then the whole thing mirrored. | [View](Source%20Code/Patterns/butterfly_pattern.asm) |
| `diamond_pattern.asm` | Diamond Star Pattern | Generate and display a symmetric diamond pattern using asterisks (*) and spaces through nested loop logic. | [View](Source%20Code/Patterns/diamond_pattern.asm) |
| `floyd_triangle.asm` | Floyd's Triangle | Fills a triangle with consecutive numbers, one more on each row than the row before. | [View](Source%20Code/Patterns/floyd_triangle.asm) |
| `hollow_pyramid.asm` | A Hollow Pyramid | Draws the outline of a pyramid, which needs the two sloping edges placed as well as the base. | [View](Source%20Code/Patterns/hollow_pyramid.asm) |
| `hollow_square.asm` | A Hollow Square | Draws only the border of a square, by printing a solid row at the top and bottom and just the edges in between. | [View](Source%20Code/Patterns/hollow_square.asm) |
| `hourglass_pattern.asm` | An Hourglass | Prints a shrinking triangle above a growing one, sharing a single row where the two meet. | [View](Source%20Code/Patterns/hourglass_pattern.asm) |
| `inverted_triangle.asm` | Inverted Triangle Pattern | Generate and display a top-heavy (inverted) right-angled triangle using the decrementing loop technique. | [View](Source%20Code/Patterns/inverted_triangle.asm) |
| `multiplication_grid.asm` | A Multiplication Grid | Prints a times table with headings, which is a nested loop and a column alignment problem. | [View](Source%20Code/Patterns/multiplication_grid.asm) |
| `number_pyramid.asm` | Number Pyramid Pattern | Display a centered pyramid where each row contains consecutive numbers starting from 1. | [View](Source%20Code/Patterns/number_pyramid.asm) |
| `pascal_triangle.asm` | Pascal's Triangle | Builds each row from the one above it, where every entry is the sum of the two diagonally over it. | [View](Source%20Code/Patterns/pascal_triangle.asm) |
| `pyramid_of_stars.asm` | A Centred Pyramid | Prints a pyramid of stars, where each row needs one fewer space in front and two more stars than the last. | [View](Source%20Code/Patterns/pyramid_of_stars.asm) |
| `right_aligned_triangle.asm` | A Right Aligned Triangle | Pushes each row to the right by padding in front, so the vertical edge is on the right instead of the left. | [View](Source%20Code/Patterns/right_aligned_triangle.asm) |
| `spiral_matrix_print.asm` | Printing a Matrix in a Spiral | Reads a grid from the outside inward, going right, down, left and up, shrinking the boundary after each side. | [View](Source%20Code/Patterns/spiral_matrix_print.asm) |
| `triangle_pattern.asm` | Right-Angled Triangle Pattern | Generate an increasing star pattern (*) using nested loops to iterate through rows and columns. | [View](Source%20Code/Patterns/triangle_pattern.asm) |

</details>

<details>
<summary><strong>Port Programming (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `adc_read_and_scale.asm` | Reading a Sensor and Scaling It | Reads a converter port and turns the raw byte into engineering units, which is where the arithmetic order matters. | [View](Source%20Code/Port%20Programming/adc_read_and_scale.asm) |
| `buzzer_tone_pattern.asm` | Sounding a Buzzer in Patterns | Drives a buzzer line on and off to produce distinguishable alarm patterns rather than one continuous noise. | [View](Source%20Code/Port%20Programming/buzzer_tone_pattern.asm) |
| `dac_ramp_and_triangle.asm` | Generating a Waveform Through a DAC | Sends a rising ramp and then a triangle to a converter port, which is how a waveform is produced without any analogue parts. | [View](Source%20Code/Port%20Programming/dac_ramp_and_triangle.asm) |
| `keypad_matrix_scan.asm` | Scanning a Keypad Matrix | Finds which key is pressed on a four by four keypad by driving one row at a time and reading the columns. | [View](Source%20Code/Port%20Programming/keypad_matrix_scan.asm) |
| `led_running_light.asm` | A Running Light | Moves a single lit lamp along a row of eight and back, by rotating one bit through a port. | [View](Source%20Code/Port%20Programming/led_running_light.asm) |
| `port_word_versus_byte.asm` | Byte and Word Port Transfers | Shows that a word transfer touches two consecutive ports, and that a port number above 255 has to travel in DX. | [View](Source%20Code/Port%20Programming/port_word_versus_byte.asm) |
| `relay_control_bank.asm` | Switching a Bank of Relays | Turns individual relays on and off without disturbing the others, which is the read, modify, write pattern. | [View](Source%20Code/Port%20Programming/relay_control_bank.asm) |
| `seven_segment_display.asm` | Driving a Seven Segment Display | Sends each digit from nought to nine to a display port, using a lookup table rather than working the pattern out. | [View](Source%20Code/Port%20Programming/seven_segment_display.asm) |
| `stepper_motor_full_step.asm` | Driving a Stepper Motor, Full Step | Energises two coils at a time in the four step sequence, and reverses it. | [View](Source%20Code/Port%20Programming/stepper_motor_full_step.asm) |
| `stepper_motor_half_step.asm` | Driving a Stepper Motor, Half Step | Alternates between one coil and two, which doubles the number of positions the motor can hold. | [View](Source%20Code/Port%20Programming/stepper_motor_half_step.asm) |
| `traffic_light_state_table.asm` | A Traffic Light Driven by a State Table | Runs a junction through its phases from a table of port values, which keeps the sequence in the data rather than in the code. | [View](Source%20Code/Port%20Programming/traffic_light_state_table.asm) |
| `water_level_controller.asm` | A Water Level Controller | Reads two float switches and drives a pump and an alarm, with hysteresis so the pump does not chatter at the threshold. | [View](Source%20Code/Port%20Programming/water_level_controller.asm) |

</details>

<details>
<summary><strong>Procedures (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `basic_procedure.asm` | Basic Procedure Execution | Demonstrate the use of subroutines to avoid code duplication for repetitive tasks like numeric scaling. | [View](Source%20Code/Procedures/basic_procedure.asm) |
| `local_variables.asm` | Procedure with Local Variables | Demonstrate the standard way to allocate and use local variables on the stack using the Base Pointer (BP) register. | [View](Source%20Code/Procedures/local_variables.asm) |
| `nested_procedures.asm` | Nested Procedure Calls | Demonstrate procedural hierarchy where one subroutine calls another, showcasing the stack's LIFO nature for return addresses. | [View](Source%20Code/Procedures/nested_procedures.asm) |
| `procedure_dispatch_table.asm` | A Table of Procedure Addresses Dispatched by Index | A short list of coded operations is carried out by looking each opcode up in a table of procedure addresses, so the driver never names any of the five procedures it calls. | [View](Source%20Code/Procedures/procedure_dispatch_table.asm) |
| `procedure_parameters.asm` | Procedure Parameter Passing | Demonstrate the standard register-based method for passing arguments to a subroutine. | [View](Source%20Code/Procedures/procedure_parameters.asm) |
| `procedure_pointer_in_register.asm` | Calling a Procedure Through a Pointer | One walker over an array calls whatever procedure BX happens to point at, so the same loop performs four different jobs without a single test of which job it is doing. | [View](Source%20Code/Procedures/procedure_pointer_in_register.asm) |
| `recursive_factorial.asm` | Recursive Factorial | Calculate the factorial of a 16-bit number (n!) using a recursive procedure call. | [View](Source%20Code/Procedures/recursive_factorial.asm) |
| `register_preservation_proof.asm` | Proving a Procedure Preserves Every Register | Distinct markers are loaded into seven registers and compared against what a procedure left behind, so the promise to preserve them is tested rather than trusted. | [View](Source%20Code/Procedures/register_preservation_proof.asm) |
| `register_versus_stack_arguments.asm` | Arguments in Registers Against Arguments on the Stack | One calculation is reached by two calling conventions, and the stack each of them costs is measured rather than asserted. | [View](Source%20Code/Procedures/register_versus_stack_arguments.asm) |
| `returning_several_values.asm` | Returning Several Values From One Procedure | One pass over an array hands back four answers at once, and a second procedure returns a result together with a flag saying whether the result is worth reading. | [View](Source%20Code/Procedures/returning_several_values.asm) |
| `two_sequences_defined_by_each_other.asm` | Two Sequences Defined In Terms Of Each Other | The Hofstadter female and male sequences, where each procedure can only finish by calling the other, so neither may be written or tested on its own. | [View](Source%20Code/Procedures/two_sequences_defined_by_each_other.asm) |
| `variable_argument_count.asm` | A Procedure Taking Any Number Of Arguments | The count is pushed last so the procedure can find it, and the rest are read from there. | [View](Source%20Code/Procedures/variable_argument_count.asm) |

</details>

<details>
<summary><strong>Recursion (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `binary_search_recursive.asm` | Binary Search by Recursion | Halves the search range at each call, which is the way the algorithm is usually described. | [View](Source%20Code/Recursion/binary_search_recursive.asm) |
| `factorial_recursive_frames.asm` | Factorial by Recursion | Computes a factorial by calling itself, and shows the stack growing and unwinding through a frame pointer. | [View](Source%20Code/Recursion/factorial_recursive_frames.asm) |
| `fibonacci_recursive.asm` | Fibonacci by Recursion | Computes a Fibonacci number the way the definition reads, and counts the calls to show what that costs. | [View](Source%20Code/Recursion/fibonacci_recursive.asm) |
| `gcd_recursive.asm` | Greatest Common Divisor by Recursion | States Euclid's method as it is usually written in mathematics, where the recursive form is the natural one. | [View](Source%20Code/Recursion/gcd_recursive.asm) |
| `mutual_recursion_even_odd.asm` | Two Procedures Calling Each Other | Decides whether a number is even using two procedures that each call the other, which is mutual recursion. | [View](Source%20Code/Recursion/mutual_recursion_even_odd.asm) |
| `power_recursive.asm` | Exponentiation by Recursion | Raises a number to a power both the plain way and by squaring, and counts the multiplications each needs. | [View](Source%20Code/Recursion/power_recursive.asm) |
| `recursion_versus_iteration.asm` | The Same Problem Both Ways | Computes a factorial recursively and with a loop, and measures how much stack each one uses. | [View](Source%20Code/Recursion/recursion_versus_iteration.asm) |
| `reverse_string_recursive.asm` | Reversing a String by Recursion | Prints a string backward without a buffer, by using the call stack itself to hold the characters until the unwinding. | [View](Source%20Code/Recursion/reverse_string_recursive.asm) |
| `stack_frame_anatomy.asm` | What a Stack Frame Contains | Prints the addresses and contents of a frame from inside the procedure, so the layout can be seen rather than described. | [View](Source%20Code/Recursion/stack_frame_anatomy.asm) |
| `sum_array_recursive.asm` | Summing an Array by Recursion | Adds an array by taking the first element and asking for the sum of what remains. | [View](Source%20Code/Recursion/sum_array_recursive.asm) |
| `sum_of_digits_recursive.asm` | Sum of Digits by Recursion | Adds the digits of a number by taking one off and asking for the sum of the rest. | [View](Source%20Code/Recursion/sum_of_digits_recursive.asm) |
| `tower_of_hanoi.asm` | Tower of Hanoi | Solves the three peg puzzle recursively and prints every move, passing its four arguments on the stack in a proper frame. | [View](Source%20Code/Recursion/tower_of_hanoi.asm) |

</details>

<details>
<summary><strong>Searching (16 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `binary_search_insertion_point.asm` | Where a Value Would Belong | Finds the position at which a value should be inserted to keep an array sorted, whether or not it is already present. | [View](Source%20Code/Searching/binary_search_insertion_point.asm) |
| `binary_search.asm` | Binary Search Algorithm | Implementation of Binary Search on a sorted array of 16-bit unsigned integers. | [View](Source%20Code/Searching/binary_search.asm) |
| `character_occurrences_count.asm` | Character Occurrences Count | Scan a user-provided string to count the number of times a specific character appears. | [View](Source%20Code/Searching/character_occurrences_count.asm) |
| `count_occurrences_by_bisection.asm` | Counting Occurrences by Bisection | Counts how many elements are less than a value and how many are at most that value, and subtracts to get the count. | [View](Source%20Code/Searching/count_occurrences_by_bisection.asm) |
| `exponential_search.asm` | Exponential Search | Doubles the range until the value is bracketed, then binary searches inside it, which suits an array of unknown length. | [View](Source%20Code/Searching/exponential_search.asm) |
| `find_duplicate_number.asm` | The Repeated Number | Finds which value appears twice in a list of one to n, using the same total comparison in reverse. | [View](Source%20Code/Searching/find_duplicate_number.asm) |
| `find_first_and_last_occurrence.asm` | First and Last Occurrence of a Value | Uses two modified binary searches to find both ends of a run of equal values, and so how many there are. | [View](Source%20Code/Searching/find_first_and_last_occurrence.asm) |
| `find_missing_number.asm` | The Missing Number | Finds which value is absent from a list of one to n, by comparing the total that should be there with the total that is. | [View](Source%20Code/Searching/find_missing_number.asm) |
| `jump_search.asm` | Jump Search | Strides through a sorted array in fixed blocks and then walks back, which needs fewer comparisons than a linear scan. | [View](Source%20Code/Searching/jump_search.asm) |
| `linear_search_all_matches.asm` | Finding Every Match | Reports all the positions holding a value rather than stopping at the first, and counts them. | [View](Source%20Code/Searching/linear_search_all_matches.asm) |
| `linear_search.asm` | Linear Search Implementation | Search for an 8-bit element in an array using sequential comparison and loop-based traversal. | [View](Source%20Code/Searching/linear_search.asm) |
| `search_element_array.asm` | Search Element in Array (Debugger Trace) | Basic linear search on an immediate array using indexed addressing and debug traps (INT 3). | [View](Source%20Code/Searching/search_element_array.asm) |
| `search_in_sorted_matrix.asm` | Searching a Sorted Matrix | Finds a value in a matrix whose rows and columns are both sorted, by starting at a corner where every step is decided. | [View](Source%20Code/Searching/search_in_sorted_matrix.asm) |
| `search_rotated_sorted_array.asm` | Searching a Rotated Sorted Array | Finds a value in an array that was sorted and then rotated, still in logarithmic time, by working out which half is in order. | [View](Source%20Code/Searching/search_rotated_sorted_array.asm) |
| `sentinel_linear_search.asm` | Linear Search with a Sentinel | Removes the bounds check from the inner loop by planting the sought value past the end, so the search is certain to stop. | [View](Source%20Code/Searching/sentinel_linear_search.asm) |
| `ternary_search.asm` | Ternary Search | Divides the range into three at each step rather than two, and shows why that is slower despite sounding faster. | [View](Source%20Code/Searching/ternary_search.asm) |

</details>

<details>
<summary><strong>Shift and Rotate (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `arithmetic_shift_signed_divide.asm` | Divide a Signed Value with SAR | Halves a negative number correctly with SAR, and shows what SHR produces for the same value to make the difference plain. | [View](Source%20Code/Shift%20and%20Rotate/arithmetic_shift_signed_divide.asm) |
| `multiply_by_ten_using_shifts.asm` | Multiply by Ten Without MUL | Computes ten times a value using two shifts and one addition, which is how a decimal input routine accumulates its digits. | [View](Source%20Code/Shift%20and%20Rotate/multiply_by_ten_using_shifts.asm) |
| `overflow_flag_on_single_shift.asm` | The Overflow Flag on a Single Shift | Shows when SHL sets the overflow flag, and why the flag is only meaningful for a shift of exactly one place. | [View](Source%20Code/Shift%20and%20Rotate/overflow_flag_on_single_shift.asm) |
| `pack_two_bytes_into_word.asm` | Pack Two Bytes into One Word | Combines two separate bytes into a single word by shifting one into the high half and merging the other in with OR. | [View](Source%20Code/Shift%20and%20Rotate/pack_two_bytes_into_word.asm) |
| `rotate_left_no_carry.asm` | Rotate Left Without the Carry | Rotates a bit pattern left one place at a time, showing that ROL loses nothing: after sixteen rotations the value returns. | [View](Source%20Code/Shift%20and%20Rotate/rotate_left_no_carry.asm) |
| `rotate_right_through_carry.asm` | Shift a 32-bit Value Right Using RCR | The mirror of the RCL case: shifting a two register value right requires starting at the high half so the carry travels downward. | [View](Source%20Code/Shift%20and%20Rotate/rotate_right_through_carry.asm) |
| `rotate_through_carry_multiword_shift.asm` | Shift a 32-bit Value Using RCL | Shifts a value held across two registers as though it were one 32-bit number, by passing the carry from the low half to the high. | [View](Source%20Code/Shift%20and%20Rotate/rotate_through_carry_multiword_shift.asm) |
| `rotate_to_test_each_bit.asm` | Test Every Bit by Rotating | Prints the binary representation of a word by rotating it left sixteen times and reading the carry after each rotation. | [View](Source%20Code/Shift%20and%20Rotate/rotate_to_test_each_bit.asm) |
| `shift_left_to_multiply.asm` | Multiply by a Power of Two with SHL | Shows that shifting left by N multiplies by two to the N, and prints the same value doubled four times over. | [View](Source%20Code/Shift%20and%20Rotate/shift_left_to_multiply.asm) |
| `shift_right_to_divide_unsigned.asm` | Divide an Unsigned Value with SHR | Halves an unsigned value repeatedly with SHR, and shows that the bit shifted out is the remainder. | [View](Source%20Code/Shift%20and%20Rotate/shift_right_to_divide_unsigned.asm) |
| `unpack_word_into_two_bytes.asm` | Unpack a Word into Two Bytes | Splits a word into its high and low bytes, by shifting for one half and masking for the other. | [View](Source%20Code/Shift%20and%20Rotate/unpack_word_into_two_bytes.asm) |
| `variable_shift_count_in_cl.asm` | Shifting by a Count Held in CL | Shifts by an amount decided at run time, which on the 8086 must travel in CL, and shows why CX has to be preserved around it. | [View](Source%20Code/Shift%20and%20Rotate/variable_shift_count_in_cl.asm) |

</details>

<details>
<summary><strong>Signed Arithmetic (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `absolute_value.asm` | Absolute Value | Takes the magnitude of several signed values, and names the one input for which the operation cannot succeed. | [View](Source%20Code/Signed%20Arithmetic/absolute_value.asm) |
| `sign_extension_cbw_cwd.asm` | Widening a Signed Value | Extends a signed byte to a word and a word to a double word, and shows why copying with a zero high half is wrong. | [View](Source%20Code/Signed%20Arithmetic/sign_extension_cbw_cwd.asm) |
| `signed_array_average.asm` | Average of Signed Values | Averages a set of readings that may be negative, which needs the sum sign extended before the division. | [View](Source%20Code/Signed%20Arithmetic/signed_array_average.asm) |
| `signed_byte_arithmetic.asm` | Signed Arithmetic on Bytes | Adds and multiplies signed bytes, where the sign bit is bit seven and widening has to happen before anything larger is attempted. | [View](Source%20Code/Signed%20Arithmetic/signed_byte_arithmetic.asm) |
| `signed_divide_idiv.asm` | Signed Division with IDIV | Divides negative values and shows the direction IDIV rounds in, together with the sign the remainder takes. | [View](Source%20Code/Signed%20Arithmetic/signed_divide_idiv.asm) |
| `signed_minimum_and_maximum.asm` | Smallest and Largest Signed Values | Finds the extremes of a signed array, using the signed branches that a set containing negatives requires. | [View](Source%20Code/Signed%20Arithmetic/signed_minimum_and_maximum.asm) |
| `signed_multiply_imul.asm` | Signed Multiplication with IMUL | Multiplies signed values with IMUL and shows what MUL produces for the same operands, which is not the same number. | [View](Source%20Code/Signed%20Arithmetic/signed_multiply_imul.asm) |
| `signed_overflow_detection.asm` | Detecting Signed Overflow | Adds pairs of values and reports which sums were too large for a signed word, using the overflow flag rather than the carry. | [View](Source%20Code/Signed%20Arithmetic/signed_overflow_detection.asm) |
| `signed_range_check.asm` | Checking a Value Lies Within a Range | Tests whether readings fall between two signed bounds, and shows the single subtraction that replaces two comparisons. | [View](Source%20Code/Signed%20Arithmetic/signed_range_check.asm) |
| `signed_sorting_by_value.asm` | Sorting Signed Values | Sorts an array containing negatives into order, which needs the signed comparison an unsigned sort would get wrong. | [View](Source%20Code/Signed%20Arithmetic/signed_sorting_by_value.asm) |
| `signed_versus_shift_division.asm` | When a Shift Is Not a Division | Compares IDIV against SAR on the same negative values and shows the two rounding in opposite directions. | [View](Source%20Code/Signed%20Arithmetic/signed_versus_shift_division.asm) |
| `two_complement_representation.asm` | How a Negative Number is Stored | Shows the bit pattern the processor keeps for a negative value, and that adding a number to its negation gives zero. | [View](Source%20Code/Signed%20Arithmetic/two_complement_representation.asm) |

</details>

<details>
<summary><strong>Simulation (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `conveyor_belt_counter.asm` | Conveyor Belt Batch Counter | Counts items past a sensor and signals a full box every time a batch is complete, keeping the remainder. | [View](Source%20Code/Simulation/conveyor_belt_counter.asm) |
| `digital_clock_simulation.asm` | Digital Clock Simulation | Advances hours, minutes and seconds with the carries that make midnight work, printed as a proper two digit display. | [View](Source%20Code/Simulation/digital_clock_simulation.asm) |
| `fire_monitoring_system.asm` | Fire Monitoring System (Simulation) | Emulate a temperature-based fire alarm system. The program monitors ambient temperature against user-defined thresholds for two distinct rooms and triggers an alarm if exceeded. | [View](Source%20Code/Simulation/fire_monitoring_system.asm) |
| `garment_defect.asm` | Garment Defect Detection (Simulation) | Simulate a quality control station in a textile factory. The program scans "pieces" (array elements) against grade thresholds and logs inventory statistics. | [View](Source%20Code/Simulation/garment_defect.asm) |
| `lift_controller.asm` | Lift Controller | Serves a list of floor requests in the order a real lift would: everything on the way up first, then on the way down. | [View](Source%20Code/Simulation/lift_controller.asm) |
| `parking_lot_occupancy.asm` | Parking Lot Occupancy | Tracks how many spaces are taken as cars arrive and leave, refusing entry when full and never going below empty. | [View](Source%20Code/Simulation/parking_lot_occupancy.asm) |
| `seven_segment_display_driver.asm` | Seven Segment Display Driver | Turns each digit into the pattern of lit segments, driven from a lookup table rather than worked out. | [View](Source%20Code/Simulation/seven_segment_display_driver.asm) |
| `temperature_controller.asm` | Temperature Controller With Hysteresis | Switches a heater on and off around a target, with a dead band so it does not chatter at the boundary. | [View](Source%20Code/Simulation/temperature_controller.asm) |
| `traffic_light_controller.asm` | Traffic Light Controller | A four state machine driving the lamp port, held in each state for a fixed number of ticks. | [View](Source%20Code/Simulation/traffic_light_controller.asm) |
| `vending_machine.asm` | Vending Machine | Accepts coins until the price is covered, then works out the change with the fewest coins. | [View](Source%20Code/Simulation/vending_machine.asm) |
| `washing_machine_cycle.asm` | Washing Machine Cycle | Runs the phases of a wash in order, each with its own duration and its own set of driven outputs. | [View](Source%20Code/Simulation/washing_machine_cycle.asm) |
| `water_level_controller.asm` | Water Level Controller (Simulation) | Emulate an automated pump system for an overhead tank. Simulates motor switching, water level monitoring (8 levels), and overflow protection logic. | [View](Source%20Code/Simulation/water_level_controller.asm) |

</details>

<details>
<summary><strong>Sorting (20 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `array_ascending.asm` | Array Ascending Sort | Implementation of an exchange-based sorting algorithm to arrange a given byte array in ascending order. | [View](Source%20Code/Sorting/array_ascending.asm) |
| `array_descending.asm` | Array Descending Sort | Arrange an 8-bit numeric array in descending order using the bubble-exchange technique. | [View](Source%20Code/Sorting/array_descending.asm) |
| `bubble_sort_with_early_exit.asm` | Bubble Sort That Stops Early | Adds a flag to the ordinary bubble sort so that an array already in order costs one pass instead of all of them. | [View](Source%20Code/Sorting/bubble_sort_with_early_exit.asm) |
| `bubble_sort.asm` | Bubble Sort (16-bit) | Implementation of Bubble Sort algorithm for a set of unsigned 16-bit word integers. | [View](Source%20Code/Sorting/bubble_sort.asm) |
| `check_if_sorted.asm` | Testing Whether an Array Is Sorted | Decides in one pass whether an array is already in order, which is worth doing before paying for a sort. | [View](Source%20Code/Sorting/check_if_sorted.asm) |
| `cocktail_shaker_sort.asm` | Cocktail Shaker Sort | A bubble sort that alternates direction, so a small value near the end reaches the front in one pass rather than seven. | [View](Source%20Code/Sorting/cocktail_shaker_sort.asm) |
| `counting_sort.asm` | Counting Sort | Sorts without comparing anything, by counting how many of each value there are and writing them back in order. | [View](Source%20Code/Sorting/counting_sort.asm) |
| `find_kth_smallest.asm` | Finding the k-th Smallest Without Sorting | Selects the third smallest element by running only as many selection passes as needed, rather than ordering the whole array. | [View](Source%20Code/Sorting/find_kth_smallest.asm) |
| `gnome_sort.asm` | Gnome Sort | Sorts with a single loop and a single index, stepping back one place whenever a pair is out of order. | [View](Source%20Code/Sorting/gnome_sort.asm) |
| `heap_sort.asm` | Heap Sort | Build a heap in the array itself, then repeatedly take the largest off the top, which needs no extra memory at all. | [View](Source%20Code/Sorting/heap_sort.asm) |
| `insertion_sort_word_array.asm` | Insertion Sort On A Word Array | Grows a sorted region one element at a time by sliding each new value back until it fits, the way a hand of cards is ordered. | [View](Source%20Code/Sorting/insertion_sort_word_array.asm) |
| `insertion_sort.asm` | Insertion Sort | Sort a byte array using the Insertion Sort algorithm, which is efficient for small data sets and partially sorted arrays. | [View](Source%20Code/Sorting/insertion_sort.asm) |
| `merge_sort_bottom_up.asm` | Merge Sort, Bottom Up | Sorts by merging runs of one into runs of two, then four, and so on, which avoids recursion entirely. | [View](Source%20Code/Sorting/merge_sort_bottom_up.asm) |
| `merge_two_sorted_arrays.asm` | Merging Two Sorted Arrays | Combines two ordered arrays into one in a single pass, the step every merge sort is built from. | [View](Source%20Code/Sorting/merge_two_sorted_arrays.asm) |
| `quick_sort.asm` | Quick Sort | Partition around a pivot and sort each side, with the recursion carried on the stack as two offsets at a time. | [View](Source%20Code/Sorting/quick_sort.asm) |
| `radix_sort.asm` | Radix Sort | Sorts by one digit at a time using counting sort, which makes it linear in the number of digits rather than logarithmic. | [View](Source%20Code/Sorting/radix_sort.asm) |
| `selection_sort_word_array.asm` | Selection Sort On A Word Array | Finds the smallest remaining element on each pass and puts it in place, which costs the fewest exchanges of any simple sort. | [View](Source%20Code/Sorting/selection_sort_word_array.asm) |
| `selection_sort.asm` | Selection Sort | Implementation of Selection Sort algorithm for an 8-bit byte array. | [View](Source%20Code/Sorting/selection_sort.asm) |
| `sort_bytes_ascending.asm` | Sorting an Array of Bytes | Sorts byte sized values, where the stride is one and the comparison is eight bits wide. | [View](Source%20Code/Sorting/sort_bytes_ascending.asm) |
| `sort_descending_order.asm` | Sorting into Descending Order | The same sort with one branch reversed, which is all that separates ascending from descending. | [View](Source%20Code/Sorting/sort_descending_order.asm) |

</details>

<details>
<summary><strong>Stack Operations (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `balanced_brackets_check.asm` | Checking Brackets With A Stack | The classic use of a stack: every opening bracket is pushed and must be matched by the right closing one. | [View](Source%20Code/Stack%20Operations/balanced_brackets_check.asm) |
| `inspect_stack_registers.asm` | Inspecting SS, SP And BP | Prints the three registers that describe the stack and shows the linear address they combine into. | [View](Source%20Code/Stack%20Operations/inspect_stack_registers.asm) |
| `last_in_first_out_order.asm` | Last In First Out Order | Pushes a list and pops it back to show that a stack reverses whatever passes through it. | [View](Source%20Code/Stack%20Operations/last_in_first_out_order.asm) |
| `passing_arguments_on_stack.asm` | Passing Arguments On The Stack | A procedure taking four arguments, more than the registers would comfortably carry, with the caller clearing them. | [View](Source%20Code/Stack%20Operations/passing_arguments_on_stack.asm) |
| `push_pop.asm` | PUSH and POP Mechanics | Demonstrate the fundamental Last-In-First-Out (LIFO) behavior of the 8086 hardware stack through register manipulation. | [View](Source%20Code/Stack%20Operations/push_pop.asm) |
| `reverse_string_stack.asm` | Reverse String (Stack Implementation) | Utilize the stack's LIFO property to reverse a string's character order. | [View](Source%20Code/Stack%20Operations/reverse_string_stack.asm) |
| `save_all_registers.asm` | Saving Every Register Across A Call | A procedure that promises to change nothing, and the proof that it kept the promise. | [View](Source%20Code/Stack%20Operations/save_all_registers.asm) |
| `save_and_restore_flags.asm` | Saving And Restoring The Flags | PUSHF and POPF put the whole flag word on the stack, which lets a routine test something without disturbing a result. | [View](Source%20Code/Stack%20Operations/save_and_restore_flags.asm) |
| `stack_depth_measurement.asm` | Measuring How Deep The Stack Has Gone | Records the starting SP and reports the deepest point reached by a recursive routine, which is how a stack budget is set. | [View](Source%20Code/Stack%20Operations/stack_depth_measurement.asm) |
| `stack_frame_with_bp.asm` | A Stack Frame Built With BP | The standard entry and exit sequence, and why BP rather than SP is used to reach into the frame. | [View](Source%20Code/Stack%20Operations/stack_frame_with_bp.asm) |
| `stack_pointer_movement.asm` | How The Stack Pointer Moves | Reports SP before and after each push and pop, showing that the stack grows downwards two bytes at a time. | [View](Source%20Code/Stack%20Operations/stack_pointer_movement.asm) |
| `swap_using_stack.asm` | Register Swap via Stack | Demonstrate how to exchange the values of two registers without using a third temporary register. | [View](Source%20Code/Stack%20Operations/swap_using_stack.asm) |

</details>

<details>
<summary><strong>String Instructions (12 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `cmpsb_compare_strings.asm` | Comparing Strings with REPE CMPSB | Decides whether two strings are identical, and where they first differ, in a handful of instructions. | [View](Source%20Code/String%20Instructions/cmpsb_compare_strings.asm) |
| `count_character_occurrences.asm` | Counting Occurrences of a Character | Counts how many times a character appears, repeating the search from where the previous one stopped. | [View](Source%20Code/String%20Instructions/count_character_occurrences.asm) |
| `lodsb_process_each_byte.asm` | Reading Bytes with LODSB | Walks a string one byte at a time with LODSB, converting each letter to upper case as it passes. | [View](Source%20Code/String%20Instructions/lodsb_process_each_byte.asm) |
| `movsb_copy_a_string.asm` | Copy a String with REP MOVSB | Copies a run of bytes in two instructions, the job MOVSB exists for, and prints both the source and the copy. | [View](Source%20Code/String%20Instructions/movsb_copy_a_string.asm) |
| `movsw_copy_words.asm` | Copying Words Rather Than Bytes | Copies an array of words with MOVSW and shows that halving the count is what makes it equivalent to the byte form. | [View](Source%20Code/String%20Instructions/movsw_copy_words.asm) |
| `overlapping_copy_with_direction.asm` | Copying Overlapping Regions | Shifts a block of memory up by one position, which corrupts the data if copied forward and works if copied backward. | [View](Source%20Code/String%20Instructions/overlapping_copy_with_direction.asm) |
| `palindrome_with_string_instructions.asm` | Palindrome Test Using CMPSB | Decides whether a word reads the same backward by comparing it against its own reversal. | [View](Source%20Code/String%20Instructions/palindrome_with_string_instructions.asm) |
| `reverse_string_with_pointers.asm` | Reversing a String In Place | Reverses a string by swapping from both ends inward, which needs half as many exchanges as characters. | [View](Source%20Code/String%20Instructions/reverse_string_with_pointers.asm) |
| `scasb_find_a_character.asm` | Finding a Character with REPNE SCASB | Searches a string for a character and reports its position, the fastest search the 8086 offers. | [View](Source%20Code/String%20Instructions/scasb_find_a_character.asm) |
| `segment_override_on_source.asm` | Overriding the Source Segment | Copies from a segment other than DS, which the source of a string operation permits and the destination does not. | [View](Source%20Code/String%20Instructions/segment_override_on_source.asm) |
| `stosb_fill_a_buffer.asm` | Filling a Buffer with REP STOSB | Clears a block of memory to a chosen byte, the fastest fill the processor offers, and shows the word form for a two byte pattern. | [View](Source%20Code/String%20Instructions/stosb_fill_a_buffer.asm) |
| `string_length_with_scasb.asm` | Measuring a String with SCASB | Finds the length of a terminated string by scanning for the terminator, without knowing the length in advance. | [View](Source%20Code/String%20Instructions/string_length_with_scasb.asm) |

</details>

<details>
<summary><strong>String Operations (18 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `caesar_cipher.asm` | Caesar Cipher | Shifts every letter along the alphabet by a fixed amount and shifts it back, leaving anything that is not a letter alone. | [View](Source%20Code/String%20Operations/caesar_cipher.asm) |
| `capitalise_each_word.asm` | Capitalise Each Word | Puts a capital at the start of every word and lower case everywhere else, by tracking whether the previous character was a space. | [View](Source%20Code/String%20Operations/capitalise_each_word.asm) |
| `character_frequency_table.asm` | Character Frequency | Counts how often each letter appears and prints only those that occurred, which is what a frequency analysis needs. | [View](Source%20Code/String%20Operations/character_frequency_table.asm) |
| `check_anagram.asm` | Anagram Test | Decides whether two strings use exactly the same letters, by counting each letter rather than sorting either string. | [View](Source%20Code/String%20Operations/check_anagram.asm) |
| `count_letters_digits_others.asm` | Classify Every Character | Counts the letters, digits, spaces and everything else in a string, which is the first step of any input validation. | [View](Source%20Code/String%20Operations/count_letters_digits_others.asm) |
| `longest_common_prefix.asm` | The Longest Common Prefix | How much of the start of several strings is identical, compared one column at a time across all of them. | [View](Source%20Code/String%20Operations/longest_common_prefix.asm) |
| `longest_word_in_sentence.asm` | Find the Longest Word | Measures every word in a sentence and reports the longest, remembering where it began rather than copying it. | [View](Source%20Code/String%20Operations/longest_word_in_sentence.asm) |
| `palindrome_check.asm` | Palindrome String Check | A program to determine if a given string is a palindrome using bi-directional pointers (beginning and end). | [View](Source%20Code/String%20Operations/palindrome_check.asm) |
| `remove_duplicate_characters.asm` | Remove Duplicate Characters | Keeps the first occurrence of each character and discards the rest, using a seen table rather than comparing every pair. | [View](Source%20Code/String%20Operations/remove_duplicate_characters.asm) |
| `replace_character.asm` | Replace Every Occurrence of a Character | Substitutes one character for another throughout a string, and counts how many replacements were made. | [View](Source%20Code/String%20Operations/replace_character.asm) |
| `reverse_words_in_sentence.asm` | Reverse the Words of a Sentence | Reverses the order of the words while leaving each word itself the right way round, by reversing twice. | [View](Source%20Code/String%20Operations/reverse_words_in_sentence.asm) |
| `run_length_encoding.asm` | Run Length Encoding | Compresses a string by replacing each run of repeated characters with the character and its count, then expands it again. | [View](Source%20Code/String%20Operations/run_length_encoding.asm) |
| `string_contains_substring.asm` | Find a Substring | Searches for one string inside another and reports where it starts, comparing only where the first character already matches. | [View](Source%20Code/String%20Operations/string_contains_substring.asm) |
| `string_length.asm` | String Length Calculation | A program to calculate the length of a '$' terminated string in 8086 Assembly. | [View](Source%20Code/String%20Operations/string_length.asm) |
| `string_reverse.asm` | String Reverse | A program to reverse a string in-place using two-pointer swap logic (SI and DI). | [View](Source%20Code/String%20Operations/string_reverse.asm) |
| `to_lowercase.asm` | String to Lowercase Conversion | A program that iterates through a string and converts all uppercase characters (A-Z) to lowercase (a-z). | [View](Source%20Code/String%20Operations/to_lowercase.asm) |
| `to_uppercase.asm` | String to Uppercase Conversion | A program that iterates through a string and converts all lowercase characters (a-z) to uppercase (A-Z). | [View](Source%20Code/String%20Operations/to_uppercase.asm) |
| `trim_spaces.asm` | Trim Leading and Trailing Spaces | Removes the spaces from both ends of a string without touching the ones inside it, and reports how many were taken off. | [View](Source%20Code/String%20Operations/trim_spaces.asm) |

</details>

<details>
<summary><strong>Utilities (13 Programs)</strong></summary>

| Program | Title | Description | Code |
|:---|:---|:---|:-:|
| `beep_sound.asm` | Beep Sound Generation | A utility program to generate a beep sound using two methods: DOS Bell character and direct speaker control concepts. | [View](Source%20Code/Utilities/beep_sound.asm) |
| `checksum_and_parity_byte.asm` | A Checksum And A Parity Byte For A Block | Builds the two guards a serial link relies on, a modulo 256 checksum and a longitudinal parity byte, then alters one byte and shows both of them reject the block. | [View](Source%20Code/Utilities/checksum_and_parity_byte.asm) |
| `clear_screen.asm` | Clear Screen Utility | A program to clear the console screen and reset the cursor to the top-left position using BIOS interrupts. | [View](Source%20Code/Utilities/clear_screen.asm) |
| `delay_timer.asm` | Time Delay Utilities | A collection of methods to create pauses in program execution using software loops and BIOS clock ticks. | [View](Source%20Code/Utilities/delay_timer.asm) |
| `display_date.asm` | Current System Date Display | A program that retrieves the current system date from DOS and displays it in DD/MM/YYYY format. | [View](Source%20Code/Utilities/display_date.asm) |
| `hex_dump_of_a_block.asm` | A Hexadecimal Dump Of A Block | Prints a block of memory eight bytes to a line, the offset on the left, the hexadecimal in the middle and the printable characters on the right. | [View](Source%20Code/Utilities/hex_dump_of_a_block.asm) |
| `leap_year_and_day_count.asm` | Leap Years And The Day Of The Year | The full leap year rule, including the century exception that most implementations get wrong. | [View](Source%20Code/Utilities/leap_year_and_day_count.asm) |
| `pack_date_into_word.asm` | Packing A Date Into A Single Word | Folds a year, a month and a day into sixteen bits the way a directory entry does, unpacks them again, and shows that the packed words compare in date order. | [View](Source%20Code/Utilities/pack_date_into_word.asm) |
| `password_input.asm` | Secure Password Input with Masking | A program that reads a password from the keyboard without echoing it, displaying asterisks instead for privacy. | [View](Source%20Code/Utilities/password_input.asm) |
| `pseudorandom_sequence.asm` | Pseudorandom Numbers From A Visible Seed | A linear congruential generator whose seed is printed and can be set again, so any run of the sequence can be reproduced. | [View](Source%20Code/Utilities/pseudorandom_sequence.asm) |
| `swap_case_in_place.asm` | Swapping The Case Of Every Letter In Place | Turns every capital into a small letter and every small letter into a capital, in the buffer itself, by toggling the one bit that separates the two cases. | [View](Source%20Code/Utilities/swap_case_in_place.asm) |
| `thousand_separators.asm` | Printing A Number With Thousand Separators | Prints an unsigned word with a comma between each group of three digits, by counting the digits first and placing the separator from the count rather than from the value. | [View](Source%20Code/Utilities/thousand_separators.asm) |
| `unit_converter_table.asm` | A Unit Converter Driven By A Table | Converts between the imperial lengths by looking each unit up in a table of names and factors, so a new unit costs one table row and no code at all. | [View](Source%20Code/Utilities/unit_converter_table.asm) |

</details>

---

## Learning Roadmap

Suggested progression for mastering 8086 assembly using this repository:

| Level | Phase | Modules to Study | Key Concepts |
|:---:|:---|:---|:---|
| **1** | **Foundations** | `Introduction` • `Addressing Modes` | Syntax (`MOV`, `DB`/`DW`), Memory Segments, Direct/Indirect Addressing |
| **2** | **Core Logic** | `Arithmetic` • `Bitwise Operations` • `Flags` | Binary Math (`ADD`, `SUB`, `MUL`, `DIV`), Logic Gates (`AND`, `OR`, `XOR`), CPU Status Flags |
| **3** | **Control Flow** | `Control Flow` • `Conversion` • `String Operations` | Looping (`LOOP`, `JZ`), Conditional Branching, Hex/BCD Conversion, String Manipulation |
| **4** | **Modular Design** | `Procedures` • `Macros` • `Stack Operations` | Stack Management (`PUSH`/`POP`), Subroutines, Code Reusability (`MACRO`) |
| **5** | **System Level** | `Interrupts` • `File Operations` • `External Devices` | DOS/BIOS Interrupts (`INT 21h`, `INT 10h`), File I/O, Hardware Simulation |

---

<!-- BEST PRACTICES -->
## Best Practices for Assembly

| Principle | Implementation Strategy | Architectural Rationale |
|:---|:---|:---|
| **Documentation** | **Inline Annotation**: Comment logical blocks rather than individual instructions (e.g., `; Check parity` vs `; TEST AL, 1`). | Mitigates the inherent opacity of low-level machine directives and enhances maintainability. |
| **Labeling** | **Semantic Identifiers**: Use descriptive labels (`calculate_sum:`) instead of generic tokens (`L1:`). | Improves control flow legibility and facilitates efficient debugging. |
| **Modularity** | **Procedural Abstraction**: Encapsulate logic within `PROC` definitions and `MACRO` expansions. | Reduces code redundancy and promotes a structured, hierarchical program design. |
| **State Safety** | **Register Preservation**: Systematically `PUSH` and `POP` registers across procedure calls. | Prevents volatile state corruption and ensures referential transparency between routines. |
| **Segmentation** | **Memory Isolation**: Explicitly delineate `DATA`, `CODE`, and `STACK` segments. | Prevents memory access violations and ensures rigorous structural organization. |

---

<!-- QUICK REFERENCE -->
## Interrupt Vector Specifications
 
 The following table details the primary BIOS and DOS interrupt vectors utilized within this repository, indexed by their functional hexadecimal codes.
 
 | Interrupt Vector | Service Code (`AH`) | Operational Semantics | Implementation Syntax |
 |:---:|:---:|:---|:---|
 | **DOS API** (`INT 21h`) | `01h` | **Standard Input Read**: Reads a character from `STDIN` and echoes to `STDOUT`. | `MOV AH, 01h; INT 21h` |
 | **DOS API** (`INT 21h`) | `02h` | **Standard Output Write**: Writes a specific character (in `DL`) to `STDOUT`. | `MOV AH, 02h; MOV DL, 'A'; INT 21h` |
 | **DOS API** (`INT 21h`) | `09h` | **String Output**: Writes a `$`-terminated string (pointed to by `DX`) to `STDOUT`. | `MOV AH, 09h; LEA DX, MSG; INT 21h` |
 | **DOS API** (`INT 21h`) | `4Ch` | **Process Termination**: Safely terminates the current process and returns control to the OS. | `MOV AH, 4Ch; INT 21h` |
 | **BIOS Video** (`INT 10h`) | `00h` | **Video Mode Control**: Sets the video display mode (e.g., VGA `13h`) via register `AL`. | `MOV AH, 00h; MOV AL, 13h; INT 10h` |
 | **BIOS Video** (`INT 10h`) | `0Eh` | **Teletype Output**: Writes a character (in `AL`) to the active page in Teletype mode. | `MOV AH, 0Eh; MOV AL, 'X'; INT 10h` |
 | **BIOS Keyboard** (`INT 16h`) | `00h` | **Keystroke Retrieval**: Blocks execution until a key is pressed, returning the scan code. | `MOV AH, 00h; INT 16h` |

---

<!-- TROUBLESHOOTING -->
## Debugging & Error Analysis
 
 A structured guide to diagnosing and resolving non-deterministic behaviors and assembler errors.
 
 | Error Condition | Root Cause Analysis | Resolution Strategy |
 |:---|:---|:---|
 | **Operand Size Mismatch** | **Type Incompatibility**: Attempting to operate on disparate data widths (e.g., `MOV AX, BL`) without casting. | Ensure operand bit-width parity. Use explicit type matching, e.g., `MOV AX, BX` (16-bit) or `MOV AL, BL` (8-bit). |
 | **Unresolved Symbol** | **Declaration Void**: Referencing a label or variable identifier not defined within the accessible `DATA` or `CODE` scope. | Verify symbol definitions. Instantiate variables using appropriate directives (`DB`, `DW`) prior to instruction reference. |
 | **Non-Terminating Loop** | **Control Logic Failure**: The Loop Counter register (`CX`) fails to converge to zero, or is unwittingly mutated. | Validate `LOOP` logic. Ensure strict monotonicity of `CX` decrement and avoid side-effect mutations within the iterative body. |
 | **String Termination Fault**| **Buffer Overrun**: The string output routine (`INT 21h/09h`) continues reading memory past the intended buffer. | Enforce string termination. Append the DOS-standard `$` delimiter to all string definitions to signal End-of-String. |

---

<!-- RESOURCES -->
## Useful Resources

Essential tools and documentation for 8086 programming:

*   **Documentation**: [Intel 8086 Datasheet](https://www.inf.pucrs.br/calazans/undergrad/orgcomp_EC/mat_microproc/intel-8086_datasheet.pdf) (PDF)
*   **Reference**: [x86 Instruction Set Reference](https://www.felixcloutier.com/x86/)
*   **Tools**: [ASCII Table](https://www.asciitable.com/) | [Online Hex Converter](https://www.rapidtables.com/convert/number/hex-to-decimal.html)
*   **Emulator**: [8086.js Web Emulator](https://yjdoc2.github.io/8086-emulator-web/)

---

<!-- CONTRIBUTING -->
## Contributing

Full guidance is in **[CONTRIBUTING.md](CONTRIBUTING.md)**: how to add a program, how to change the simulator, and what verification is expected before a pull request.

The short version. Everything here must be correct and provably so, which means:

- `npm test` passes before you start and after you finish
- a new program carries the standard header, prints its result, and terminates
- a change to the engine comes with a test
- `expected-output.json` is regenerated, never hand-edited

This repository maintains a fork-and-pull model.

1.  **Fork the Repository**
    Replicate the repository to your personal remote namespace.

2.  **Initialize Feature Branch**
    ```bash
    git checkout -b feature/Optimization
    ```

3.  **Snapshot Changes**
    Stage and record changes with semantic messaging:
    ```bash
    git commit -m 'Refactor: Optimize loop logic'
    ```

4.  **Push to Origin**
    Upload the branch to your remote origin:
    ```bash
    git push origin feature/Optimization
    ```

5.  **Submit Pull Request**
    Initiate a formal code review process for integration.

---

<!-- =========================================================================================
                                     USAGE SECTION
     ========================================================================================= -->
## Usage Guidelines

This repository is openly shared to support learning and knowledge exchange across the academic community.

**For Students**  
Use these programs as reference materials for understanding assembly logic, instruction syntax, and modular programming. Code is heavily commented to facilitate self-paced learning.

**For Educators**  
The programs may serve as practical lab examples or supplementary teaching resources for Microprocessor courses (`CSC501`/`CSL501`). Attribution is appreciated when utilizing content.

**For Researchers**  
The documentation and organization may provide insights into academic resource curation and educational content structuring.

---

<!-- LICENSE -->
## License

This repository and all linked academic content are made available under the **MIT License**. See the [LICENSE](LICENSE) file for complete terms.

> [!NOTE]
> **Summary**: You are free to share and adapt this content for any purpose, even commercially, as long as you provide appropriate attribution to the original author.

Copyright © 2021 Amey Thakur

---

<!-- ABOUT -->
## About This Repository

**Created & Maintained by**: [Amey Thakur](https://github.com/Amey-Thakur)  
**Academic Journey**: Bachelor of Engineering in Computer Engineering (2018-2022)  
**Institution**: [Terna Engineering College](https://ternaengg.ac.in/), Navi Mumbai  
**University**: [University of Mumbai](https://mu.ac.in/)

This repository represents a comprehensive collection of 525 assembly programs developed, verified, and documented during my academic journey. All content has been carefully organized to serve as a valuable resource for mastering low-level system architecture.

**Connect:** [GitHub](https://github.com/Amey-Thakur) &nbsp;·&nbsp; [LinkedIn](https://www.linkedin.com/in/amey-thakur) &nbsp;·&nbsp; [ORCID](https://orcid.org/0000-0001-5644-1575)

### Acknowledgments

Grateful acknowledgment to the faculty members of the **Department of Computer Engineering** at Terna Engineering College for their guidance and instruction in Microprocessors. Their clear teaching and continued support helped develop a strong understanding of low-level system architecture and 16-bit CISC operations.

Special thanks to the mentors and peers whose encouragement, discussions, and support contributed meaningfully to this learning journey.

---

<!-- FOOTER -->
<div align="center">

  [↑ Back to Top](#8086-assembly-language-programs)

  [Author](#author) &nbsp;·&nbsp; [Overview](#overview) &nbsp;·&nbsp; [Features](#features) &nbsp;·&nbsp; [Structure](#project-structure) &nbsp;·&nbsp; [Quick Start](#quick-start) &nbsp;·&nbsp; [Program Details](#program-details) &nbsp;·&nbsp; [Roadmap](#learning-roadmap) &nbsp;·&nbsp; [Best Practices](#best-practices-for-assembly) &nbsp;·&nbsp; [Specifications](#interrupt-vector-specifications) &nbsp;·&nbsp; [Debugging](#debugging--error-analysis) &nbsp;·&nbsp; [Resources](#useful-resources) &nbsp;·&nbsp; [Contributing](#contributing) &nbsp;·&nbsp; [Usage Guidelines](#usage-guidelines) &nbsp;·&nbsp; [License](#license) &nbsp;·&nbsp; [About](#about-this-repository) &nbsp;·&nbsp; [Acknowledgments](#acknowledgments)

  <br>

  🔬 **[Microprocessor Lab](https://github.com/Amey-Thakur/MICROPROCESSOR-AND-MICROPROCESSOR-LAB)** &nbsp;·&nbsp; 💻 **[8086 Assembly Emulator](https://amey-thakur.github.io/8086-ASSEMBLY-LANGUAGE-PROGRAMS/)**

</div>

---

<div align="center">

  ### 🎓 [Computer Engineering Repository](https://github.com/Amey-Thakur/COMPUTER-ENGINEERING)

  **Computer Engineering (B.E.) - University of Mumbai**

  *Semester-wise curriculum, laboratories, projects, and academic notes.*

</div>
