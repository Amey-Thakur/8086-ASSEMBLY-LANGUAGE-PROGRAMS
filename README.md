<div align="center">

  # 8086 Assembly Language Programs

  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
  [![Language](https://img.shields.io/badge/Language-Assembly%208086-blue.svg)](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)
  [![Tool](https://img.shields.io/badge/Tool-Emu8086-orange.svg)](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)
  [![Status](https://img.shields.io/badge/Status-Completed-green.svg)](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)
  [![Developed by](https://img.shields.io/badge/Developed%20by-Amey%20Thakur-blue.svg)](https://github.com/Amey-Thakur)

  A comprehensive collection of professionally documented 8086 Assembly Language programs, covering arithmetic, logic, data structures, and hardware simulation.

  **[Microprocessor Lab](https://github.com/Amey-Thakur/MICROPROCESSOR-AND-MICROPROCESSOR-LAB)** • **[Source Code](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)** • **[Report Issues](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS/issues)**

</div>

---

<div align="center">

  [👥 Authors](#authors) &nbsp;·&nbsp; [📖 Overview](#overview) &nbsp;·&nbsp; [✨ Features](#features) &nbsp;·&nbsp; [📁 Structure](#project-structure) &nbsp;·&nbsp; [💾 Program Details](#program-details) &nbsp;·&nbsp; [🚀 Usage](#usage-guidelines) &nbsp;·&nbsp; [📜 License](#license) &nbsp;·&nbsp; [ℹ️ About](#about-this-repository) &nbsp;·&nbsp; [🙏 Acknowledgments](#acknowledgments)

</div>

---

<!-- AUTHORS -->
<div align="center">

  ## Authors

  **Terna Engineering College | Computer Engineering | Batch of 2022**

  <table>
  <tr>
  <td align="center">
  <a href="https://github.com/Amey-Thakur">
  <img src="https://github.com/Amey-Thakur.png" width="150px;" alt="Amey Thakur"/><br />
  <sub><b>Amey Thakur</b></sub><br />
  </a>
  </td>
  </tr>
  </table>

</div>

---

<!-- OVERVIEW -->
## Overview

The **8086 Assembly Language Programs** repository is a curated collection of low-level assembly code designed to verify and strengthen the understanding of the 8086 microprocessor architecture. It demonstrates the practical implementation of instruction sets, memory management, and hardware simulation using the **Emu8086** emulator.

### Repository Purpose

This repository represents a comprehensive archive of hands-on coding experiments. The primary motivation for creating and maintaining this archive is simple yet profound: **to preserve knowledge for continuous learning and future reference**.

As a computer engineer, understanding the underlying hardware-software interface is crucial for low-level system design and performance optimization. This repository serves as my intellectual reference point: a resource I can return to for relearning concepts, reviewing methodologies, and strengthening understanding when needed.

**Why this repository exists:**

- **Knowledge Preservation**: To maintain organized access to tested assembly programs beyond the classroom.
- **Continuous Learning**: To support lifelong learning by enabling easy revisitation of fundamental 8086 concepts.
- **Academic Documentation**: To authentically document my learning journey through 8086 assembly programming.
- **Community Contribution**: To provide a structured and verified code reference for fellow engineering students.

All programs in this repository were developed, verified, and documented by me during my undergraduate studies (2018-2022) to master the 8086 architecture.

---

<!-- FEATURES -->
## Features

| Feature | Description |
|---------|-------------|
| **Instruction Implementation** | Practical demonstrations of Arithmetic, Logical, String, and Transfer instruction sets |
| **System Interfacing** | Direct hardware simulation for Traffic Lights, Stepper Motors, and LED Displays |
| **Memory Management** | Implementation of various 8086 Addressing Modes and Stack pointer operations |
| **Algorithm Design** | Low-level implementation of Sorting (Bubble/Selection) and Binary Search algorithms |
| **Modular Programming** | Usage of Macros (`MACRO`) and Procedures (`PROC`) for structured code reusability |
| **Interrupt Handling** | Utilization of DOS (`INT 21h`) and BIOS (`INT 10h`) interrupts for System I/O |

### 🛠️ Tech Stack
- **Architecture**: Intel 8086 (16-bit)
- **Assembler**: MASM / TASM Syntax Compatibility
- **Emulator**: Emu8086
- **Language**: Assembly (ASM)

---

<!-- STRUCTURE -->
## Project Structure

```
8086-ASSEMBLY-LANGUAGE-PROGRAMS/
│
├── Addressing Modes/        # Register, Immediate, Direct, etc.
├── Arithmetic/              # Basic math (Add, Sub, Mul, Div)
├── Array Operations/        # Sum, Average, Min/Max finding
├── Bitwise Operations/      # AND, OR, XOR, NOT, Shifts, Rotates
├── Control Flow/            # Loops (LOOP), Conditional Jumps (JE, JNE)
├── Conversion/              # Hex-BCD, BCD-Hex, ASCII conversions
├── Data Structures/         # Stack, Queue implementation
├── Expression/              # Series evaluation, Factorial, Fibonacci
├── External Devices/        # Interfacing Logic (Keyboard, Mouse)
├── File Operations/         # File Creation, Reading, Writing (DOS)
├── Flags/                   # Carry, Parity, Zero, Sign flag manipulations
├── Graphics/                # VGA Graphics Mode, Shape Drawing
├── Input Output/            # Single char, String I/O
├── Interrupts/              # BIOS & DOS Interrupt vectors
├── Introduction/            # Basic Hello World & Syntax examples
├── Macros/                  # Macro definitions & usage
├── Mathematics/             # Advanced math (GCD, LCM, Power)
├── Matrix/                  # Matrix addition/manipulation
├── Memory Operations/       # Block transfer, Overlap handling
├── Patterns/                # Star patterns, Pyramids
├── Procedures/              # Modular programming examples
├── Searching/               # Linear & Binary Search
├── Simulation/              # Hardware simulations (Fire, Water Level)
├── Sorting/                 # Bubble, Selection, Insertion sorts
├── Stack Operations/        # Push, Pop, Reversal applications
├── String Operations/       # Length, Reverse, Palindrome, Case conversion
├── Utilities/               # Delays, Screen clear, Sound generation
│
├── LICENSE                  # MIT License
└── README.md                # Project Documentation
```

---

<!-- PROGRAM DETAILS -->
## Program Details

<details>
<summary><strong>📁 Addressing Modes (1 Program)</strong></summary>

| Program | Topic | Description | Code |
|:---|:---|:---|:-:|
| `comprehensive_8086_addressing_modes_reference.asm` | Addressing | Comprehensive reference guide demonstrating all 8086 addressing modes. | [View](Addressing%20Modes/comprehensive_8086_addressing_modes_reference.asm) |

</details>

<details>
<summary><strong>🧮 Arithmetic (14 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `add_array_of_bytes_from_memory.asm` | Addition | Algorithm to calculate the sum of an array of bytes stored in memory. | [View](Arithmetic/add_array_of_bytes_from_memory.asm) |
| `addition_16bit_packed_bcd.asm` | BCD Math | Implementation of 16-bit addition for packed Binary Coded Decimal (BCD) numbers. | [View](Arithmetic/addition_16bit_packed_bcd.asm) |
| `addition_16bit_simple.asm` | Addition | Basic implementation of 16-bit addition using general-purpose registers. | [View](Arithmetic/addition_16bit_simple.asm) |
| `addition_16bit_with_carry_detection.asm` | Addition | 16-bit addition logic that specifically checks and handles the Carry Flag. | [View](Arithmetic/addition_16bit_with_carry_detection.asm) |
| `addition_8bit_with_user_input.asm` | I/O Addition | Interactive program to accept two 8-bit numbers from the user and display their sum. | [View](Arithmetic/addition_8bit_with_user_input.asm) |
| `calculate_sum_of_first_n_natural_numbers.asm` | Series Sum | Calculates the sum of the first N natural numbers using iterative loops. | [View](Arithmetic/calculate_sum_of_first_n_natural_numbers.asm) |
| `count_set_bits_in_16bit_binary.asm` | Bit Count | Algorithm to count the number of set bits (1s) in a 16-bit binary number. | [View](Arithmetic/count_set_bits_in_16bit_binary.asm) |
| `decimal_adjust_after_addition_demo.asm` | DAA Logic | Demonstration of the DAA instruction to correct BCD addition results. | [View](Arithmetic/decimal_adjust_after_addition_demo.asm) |
| `division_16bit_dividend_by_8bit_divisor.asm` | Division | Performs division of a 16-bit dividend by an 8-bit divisor. | [View](Arithmetic/division_16bit_dividend_by_8bit_divisor.asm) |
| `generate_multiplication_table_for_number.asm` | Iteration | Generates and displays the multiplication table for a given number. | [View](Arithmetic/generate_multiplication_table_for_number.asm) |
| `multiplication_8bit_unsigned.asm` | Multiplication | Standard 8-bit unsigned multiplication using the MUL instruction. | [View](Arithmetic/multiplication_8bit_unsigned.asm) |
| `signed_addition_and_subtraction_demo.asm` | Signed Math | Demonstration of arithmetic operations on signed integers using IDIV/IMUL checks. | [View](Arithmetic/signed_addition_and_subtraction_demo.asm) |
| `subtraction_8bit_with_user_input.asm` | I/O Subtraction | Interactive 8-bit subtraction requiring input conversion from ASCII to numeric. | [View](Arithmetic/subtraction_8bit_with_user_input.asm) |
| `swap_two_numbers_using_registers.asm` | Swapping | Efficient value swapping between two registers without using stack memory. | [View](Arithmetic/swap_two_numbers_using_registers.asm) |

</details>

<details>
<summary><strong>📦 Array Operations (7 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `calculate_sum_of_array_elements.asm` | Traversal | Iterates through an array to calculate the total sum of all elements. | [View](Array%20Operations/calculate_sum_of_array_elements.asm) |
| `copy_block_of_data_between_arrays.asm` | Data Transfer | Copies a block of data from a source array to a destination array in memory. | [View](Array%20Operations/copy_block_of_data_between_arrays.asm) |
| `count_odd_and_even_numbers_in_array.asm` | Counting | Scans an array to count the total number of odd and even integers. | [View](Array%20Operations/count_odd_and_even_numbers_in_array.asm) |
| `delete_element_from_array_by_index.asm` | Deletion | Removes an element at a specific index and shifts remaining elements to fill the gap. | [View](Array%20Operations/delete_element_from_array_by_index.asm) |
| `find_maximum_element_in_array.asm` | Search | Linearly searches an array to identify the maximum value. | [View](Array%20Operations/find_maximum_element_in_array.asm) |
| `find_minimum_element_in_array.asm` | Search | Linearly searches an array to identify the minimum value. | [View](Array%20Operations/find_minimum_element_in_array.asm) |
| `insert_element_into_array_at_index.asm` | Insertion | Inserts a new element at a specified index, shifting existing elements to the right. | [View](Array%20Operations/insert_element_into_array_at_index.asm) |

</details>

<details>
<summary><strong>🔌 Bitwise Operations (8 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `bitwise_and_logic_demonstration.asm` | Logic (AND) | Demonstration of the AND instruction for masking bits. | [View](Bitwise%20Operations/bitwise_and_logic_demonstration.asm) |
| `bitwise_logical_shift_left_and_multiplication.asm` | Shift (SHL) | Uses logical left shift to perform efficient multiplication by powers of 2. | [View](Bitwise%20Operations/bitwise_logical_shift_left_and_multiplication.asm) |
| `bitwise_logical_shift_right_and_division.asm` | Shift (SHR) | Uses logical right shift to perform efficient division by powers of 2. | [View](Bitwise%20Operations/bitwise_logical_shift_right_and_division.asm) |
| `bitwise_not_ones_complement_demonstration.asm` | Logic (NOT) | Demonstrates the NOT instruction to calculate the 1's complement of a value. | [View](Bitwise%20Operations/bitwise_not_ones_complement_demonstration.asm) |
| `bitwise_or_logic_demonstration.asm` | Logic (OR) | Demonstration of the OR instruction for setting specific bits. | [View](Bitwise%20Operations/bitwise_or_logic_demonstration.asm) |
| `bitwise_rotate_left_circular_shift.asm` | Rotate (ROL) | Implementation of circular left shift (Rotate Left) preserving bit information. | [View](Bitwise%20Operations/bitwise_rotate_left_circular_shift.asm) |
| `bitwise_rotate_right_circular_shift.asm` | Rotate (ROR) | Implementation of circular right shift (Rotate Right) preserving bit information. | [View](Bitwise%20Operations/bitwise_rotate_right_circular_shift.asm) |
| `bitwise_xor_logic_demonstration.asm` | Logic (XOR) | Demonstration of Exclusive OR logic, often used for toggling bits. | [View](Bitwise%20Operations/bitwise_xor_logic_demonstration.asm) |

</details>

<details>
<summary><strong>🔀 Control Flow (7 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `conditional_branching_and_status_flags.asm` | Branching | Demonstrates conditional jumps (JZ, JNZ, JC) based on CPU flag states. | [View](Control%20Flow/conditional_branching_and_status_flags.asm) |
| `for_loop_counter_iteration_pattern.asm` | Iteration | Implements a standard for-loop checking a counter for a fixed number of iterations. | [View](Control%20Flow/for_loop_counter_iteration_pattern.asm) |
| `if_then_else_conditional_logic_structure.asm` | Branching | Implements classic If-Then-Else logic using comparison and jump instructions. | [View](Control%20Flow/if_then_else_conditional_logic_structure.asm) |
| `loop_instruction_cx_register_control.asm` | Iteration | Demonstrates the hardware LOOP instruction which uses the CX register. | [View](Control%20Flow/loop_instruction_cx_register_control.asm) |
| `switch_case_multiway_branching_logic.asm` | Switch-Case | Implements multi-way branching similar to a switch-case statement. | [View](Control%20Flow/switch_case_multiway_branching_logic.asm) |
| `unconditional_jump_and_program_redirection.asm` | JMP | Demonstrates unconditional jumps (JMP) to redirect program execution flow. | [View](Control%20Flow/unconditional_jump_and_program_redirection.asm) |
| `while_loop_pre_test_conditional_iteration.asm` | Iteration | Implements a pre-test while loop where the condition is checked before execution. | [View](Control%20Flow/while_loop_pre_test_conditional_iteration.asm) |

</details>

<details>
<summary><strong>🔄 Conversion (11 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `celsius_fahrenheit_temperature_converter.asm` | Formula | Converts temperature readings between Celsius and Fahrenheit scales. | [View](Conversion/celsius_fahrenheit_temperature_converter.asm) |
| `convert_decimal_to_binary_representation.asm` | Base Conversion | Converts a decimal integer into its binary string representation. | [View](Conversion/convert_decimal_to_binary_representation.asm) |
| `convert_decimal_to_octal_representation.asm` | Base Conversion | Converts a decimal integer into its octal string representation. | [View](Conversion/convert_decimal_to_octal_representation.asm) |
| `convert_hexadecimal_to_decimal_string.asm` | Base Conversion | Converts a Hexadecimal value to its equivalent Decimal ASCII string. | [View](Conversion/convert_hexadecimal_to_decimal_string.asm) |
| `convert_hexadecimal_to_packed_bcd.asm` | Base Conversion | Converts a Hexadecimal value into Packed Binary Coded Decimal format. | [View](Conversion/convert_hexadecimal_to_packed_bcd.asm) |
| `convert_packed_bcd_to_hexadecimal.asm` | Base Conversion | Converts a Packed BCD value back into its Hexadecimal equivalent. | [View](Conversion/convert_packed_bcd_to_hexadecimal.asm) |
| `hex_to_seven_segment_decoder_lookup.asm` | Decoding | Converts Hex digits to 7-segment display control codes using a lookup table. | [View](Conversion/hex_to_seven_segment_decoder_lookup.asm) |
| `reverse_digits_of_integer_value.asm` | Reversal | Separates and reverses the individual digits of an integer value. | [View](Conversion/reverse_digits_of_integer_value.asm) |
| `string_comparison_lexicographical_check.asm` | Comparison | compares two strings lexicographically to check for equality. | [View](Conversion/string_comparison_lexicographical_check.asm) |
| `string_copy_using_manual_loop_iteration.asm` | Copy | Copies a string from source to destination using a manual byte-by-byte loop. | [View](Conversion/string_copy_using_manual_loop_iteration.asm) |
| `string_copy_using_movsb_instruction.asm` | Copy | Optimizes string copying using the dedicated MOVSB hardware instruction. | [View](Conversion/string_copy_using_movsb_instruction.asm) |

</details>

<details>
<summary><strong>📚 Data Structures (2 Programs)</strong></summary>

| Program | Data Structure | Description | Code |
|:---|:---|:---|:-:|
| `queue.asm` | Queue | Implementation of a FIFO (First-In-First-Out) queue using arrays. | [View](Data%20Structures/queue.asm) |
| `stack_array.asm` | Stack | Implementation of a LIFO (Last-In-First-Out) stack using arrays. | [View](Data%20Structures/stack_array.asm) |

</details>

<details>
<summary><strong>🔢 Expression (13 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `average_of_array.asm` | Statistics | Calculates the arithmetic mean of a set of numbers stored in an array. | [View](Expression/average_of_array.asm) |
| `calculator.asm` | Arithmetic | Basic calculator simulating Add, Subtract, Multiply, and Divide operations. | [View](Expression/calculator.asm) |
| `check_even_odd.asm` | Logic | Determines if a number is even or odd by checking the least significant bit. | [View](Expression/check_even_odd.asm) |
| `count_vowels.asm` | String Processing | Scans an input string to count the number of vowels present. | [View](Expression/count_vowels.asm) |
| `count_words.asm` | String Processing | Counts the number of words in a sentence by detecting spaces. | [View](Expression/count_words.asm) |
| `factorial.asm` | Recursion/Loop | Calculates the factorial of a given number using iterative logic. | [View](Expression/factorial.asm) |
| `fibonacci.asm` | Series Generation | Generates the Fibonacci sequence up to a specified Nth term. | [View](Expression/fibonacci.asm) |
| `gcd_two_numbers.asm` | Euclidean Algorithm | Finds the Greatest Common Divisor (GCD) of two numbers. | [View](Expression/gcd_two_numbers.asm) |
| `power.asm` | Exponentiation | Calculates the result of a base number raised to a given power (X^Y). | [View](Expression/power.asm) |
| `prime_number_check.asm` | Primality Test | Algorithms to determine if a provided integer is a prime number. | [View](Expression/prime_number_check.asm) |
| `reverse_array.asm` | Reversal | Reverses the elements of an array in-place without auxiliary storage. | [View](Expression/reverse_array.asm) |
| `string_concatenation.asm` | Processing | Joins two separate strings into a single concatenated string. | [View](Expression/string_concatenation.asm) |
| `substring_search.asm` | Search | Searches for the presence of a target substring within a larger string. | [View](Expression/substring_search.asm) |

</details>

<details>
<summary><strong>🖲️ External Devices (9 Programs)</strong></summary>

| Program | Simulation | Description | Code |
|:---|:---|:---|:-:|
| `keyboard.asm` | I/O | Interfacing code to handle keyboard input interrupts. | [View](External%20Devices/keyboard.asm) |
| `led_display_test.asm` | Output | Simulation code to toggle LEDs on an external output port. | [View](External%20Devices/led_display_test.asm) |
| `mouse.asm` | I/O | Interfacing code to detect mouse clicks and coordinates. | [View](External%20Devices/mouse.asm) |
| `robot.asm` | Control | Simulation of simple robot arm movement instructions. | [View](External%20Devices/robot.asm) |
| `stepper_motor.asm` | Motor Control | Generates the correct bit pulses to rotate a stepper motor. | [View](External%20Devices/stepper_motor.asm) |
| `thermometer.asm` | Sensor | Simulates reading digital values from a temperature sensor. | [View](External%20Devices/thermometer.asm) |
| `timer.asm` | Clock | Configures the 8253/8254 Programmable Interval Timer (PIT). | [View](External%20Devices/timer.asm) |
| `traffic_lights.asm` | Traffic Light | Simulates a basic Traffic Light Control system sequence. | [View](External%20Devices/traffic_lights.asm) |
| `traffic_lights_advanced.asm` | Traffic Light | Advanced traffic control logic including pedestrian usage. | [View](External%20Devices/traffic_lights_advanced.asm) |

</details>

<details>
<summary><strong>📂 File Operations (4 Programs)</strong></summary>

| Program | Interrupt | Description | Code |
|:---|:---|:---|:-:|
| `create_file.asm` | INT 21h | Uses DOS interrupts to create a new file on the disk. | [View](File%20Operations/create_file.asm) |
| `delete_file.asm` | INT 21h | Uses DOS interrupts to delete a specified file from the disk. | [View](File%20Operations/delete_file.asm) |
| `read_file.asm` | INT 21h | Reads content from an existing file into a memory buffer. | [View](File%20Operations/read_file.asm) |
| `write_file.asm` | INT 21h | Writes string data from a buffer into a file on disk. | [View](File%20Operations/write_file.asm) |

</details>

<details>
<summary><strong>🚩 Flags (5 Programs)</strong></summary>

| Program | Flag Name | Description | Code |
|:---|:---|:---|:-:|
| `carry_flag.asm` | Carry Flag (CF) | Demonstrates operations that set or clear the Carry Flag. | [View](Flags/carry_flag.asm) |
| `overflow_flag.asm` | Overflow Flag (OF) | Demonstrates signed arithmetic overflow conditions. | [View](Flags/overflow_flag.asm) |
| `parity_flag.asm` | Parity Flag (PF) | Checks parity (number of set bits) of the result. | [View](Flags/parity_flag.asm) |
| `sign_flag.asm` | Sign Flag (SF) | Demonstrates how negative results affect the Sign Flag. | [View](Flags/sign_flag.asm) |
| `zero_flag.asm` | Zero Flag (ZF) | Demonstrates operations resulting in zero to set the Zero Flag. | [View](Flags/zero_flag.asm) |

</details>

<details>
<summary><strong>🎨 Graphics (4 Programs)</strong></summary>

| Program | Video Mode | Description | Code |
|:---|:---|:---|:-:|
| `colored_text.asm` | Text Mode | Displays text with various background and foreground colors. | [View](Graphics/colored_text.asm) |
| `draw_line.asm` | VGA Mode | Implements the Bresenham or DDA algorithm to draw lines. | [View](Graphics/draw_line.asm) |
| `draw_pixel.asm` | VGA Mode | Demonstrates how to write to video memory to plot a single pixel. | [View](Graphics/draw_pixel.asm) |
| `draw_rectangle.asm` | VGA Mode | Loops logic to draw a rectangle shape on the screen. | [View](Graphics/draw_rectangle.asm) |

</details>

<details>
<summary><strong>⌨️ Input Output (4 Programs)</strong></summary>

| Program | I/O Type | Description | Code |
|:---|:---|:---|:-:|
| `display_binary.asm` | Output | Routines to display a 16-bit number in Binary format. | [View](Input%20Output/display_binary.asm) |
| `display_decimal.asm` | Output | Routines to display a 16-bit number in Decimal format. | [View](Input%20Output/display_decimal.asm) |
| `display_hex.asm` | Output | Routines to display a 16-bit number in Hexadecimal format. | [View](Input%20Output/display_hex.asm) |
| `read_number.asm` | Input | Logic to read multi-digit numbers from the keyboard. | [View](Input%20Output/read_number.asm) |

</details>

<details>
<summary><strong>⚡ Interrupts (8 Programs)</strong></summary>

| Program | Interrupt | Description | Code |
|:---|:---|:---|:-:|
| `bios_cursor_position.asm` | INT 10h | Manipulating the cursor position using BIOS services. | [View](Interrupts/bios_cursor_position.asm) |
| `bios_keyboard.asm` | INT 16h | Reading keystrokes using BIOS keyboard services. | [View](Interrupts/bios_keyboard.asm) |
| `bios_system_time.asm` | INT 1Ah | Reading the system clock count using BIOS time services. | [View](Interrupts/bios_system_time.asm) |
| `bios_video_mode.asm` | INT 10h | Switching between Text and Video modes using BIOS. | [View](Interrupts/bios_video_mode.asm) |
| `dos_display_char.asm` | INT 21h/02h | Displaying a single ASCII character using DOS functions. | [View](Interrupts/dos_display_char.asm) |
| `dos_display_string.asm` | INT 21h/09h | Displaying a '$' terminated string using DOS functions. | [View](Interrupts/dos_display_string.asm) |
| `dos_read_char.asm` | INT 21h/01h | Reading a single character from Standard Input. | [View](Interrupts/dos_read_char.asm) |
| `dos_read_string.asm` | INT 21h/0Ah | Buffered string input from Standard Input via DOS. | [View](Interrupts/dos_read_string.asm) |

</details>

<details>
<summary><strong>👋 Introduction (15 Programs)</strong></summary>

| Program | Topic | Description | Code |
|:---|:---|:---|:-:|
| `data_definition_demo.asm` | Syntax | Demonstration of DB, DW, DD, and other data directives. | [View](Introduction/data_definition_demo.asm) |
| `display_characters.asm` | Output | Basic program to print a sequence of characters. | [View](Introduction/display_characters.asm) |
| `display_string_direct.asm` | Video Memory | Writing directly to Video RAM at segment B800h. | [View](Introduction/display_string_direct.asm) |
| `display_system_time.asm` | System | Fetching and formatting system time for display. | [View](Introduction/display_system_time.asm) |
| `hello_world_dos.asm` | Basics | classic Hello World program using DOS INT 21h. | [View](Introduction/hello_world_dos.asm) |
| `hello_world_interrupt.asm` | Interrupts | Understanding the interrupt vector table for output. | [View](Introduction/hello_world_interrupt.asm) |
| `hello_world_procedure.asm` | Procedures | Structuring Hello World code into a reusable procedure. | [View](Introduction/hello_world_procedure.asm) |
| `hello_world_procedure_advanced.asm` | Procedures | Advanced procedure usage with stack frame setup. | [View](Introduction/hello_world_procedure_advanced.asm) |
| `hello_world_string.asm` | Strings | Variable declaration and string printing. | [View](Introduction/hello_world_string.asm) |
| `hello_world_vga.asm` | Graphics | Printing Hello World in VGA graphical mode. | [View](Introduction/hello_world_vga.asm) |
| `keyboard_wait_input.asm` | Input | Looping program that waits for specific key input. | [View](Introduction/keyboard_wait_input.asm) |
| `mov_instruction_demo.asm` | Instructions | In-depth demonstration of the MOV data transfer instruction. | [View](Introduction/mov_instruction_demo.asm) |
| `print_alphabets.asm` | Loops | Printing the alphabet using loop constructs. | [View](Introduction/print_alphabets.asm) |
| `procedure_demo.asm` | Structure | Generic template for procedure-based programming. | [View](Introduction/procedure_demo.asm) |
| `procedure_multiplication.asm` | Algorithm | Encapsulating multiplication logic within a procedure. | [View](Introduction/procedure_multiplication.asm) |

</details>

<details>
<summary><strong>📝 Macros (4 Programs)</strong></summary>

| Program | Feature | Description | Code |
|:---|:---|:---|:-:|
| `conditional_macros.asm` | Conditional Assembly | Macros that generate code based on assembly-time conditions. | [View](Macros/conditional_macros.asm) |
| `macro_with_parameters.asm` | Parameters | Defining macros that accept arguments for flexible code generation. | [View](Macros/macro_with_parameters.asm) |
| `nested_macros.asm` | Nesting | Defining macros describing other macros (Macros within Macros). | [View](Macros/nested_macros.asm) |
| `print_string_macro.asm` | Macro Definition | A reusable macro to simplify printing strings via DOS. | [View](Macros/print_string_macro.asm) |

</details>

<details>
<summary><strong>📐 Mathematics (5 Programs)</strong></summary>

| Program | Mathematics | Description | Code |
|:---|:---|:---|:-:|
| `armstrong_number.asm` | Number Theory | Program to check if a number satisfies the Armstrong property. | [View](Mathematics/armstrong_number.asm) |
| `lcm.asm` | LCM | Calculating the Least Common Multiple of two integers. | [View](Mathematics/lcm.asm) |
| `perfect_number.asm` | Number Theory | Checking if a number is a Perfect Number (sum of divisors). | [View](Mathematics/perfect_number.asm) |
| `square_root.asm` | Roots | Algorithm to compute the integer square root of a number. | [View](Mathematics/square_root.asm) |
| `twos_complement.asm` | Binary Math | manually calculating the 2's complement of a binary number. | [View](Mathematics/twos_complement.asm) |

</details>

<details>
<summary><strong>▦ Matrix (2 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `matrix_addition.asm` | Matrix | Element-wise addition of two 2D matrices. | [View](Matrix/matrix_addition.asm) |
| `matrix_transpose.asm` | Matrix | Swapping rows and columns to generate a matrix transpose. | [View](Matrix/matrix_transpose.asm) |

</details>

<details>
<summary><strong>💾 Memory Operations (4 Programs)</strong></summary>

| Program | Operation | Description | Code |
|:---|:---|:---|:-:|
| `block_copy.asm` | Transfer | Efficiently copying large blocks of memory (Block Transfer). | [View](Memory%20Operations/block_copy.asm) |
| `memory_compare.asm` | Comparison | Comparing two blocks of memory for equality. | [View](Memory%20Operations/memory_compare.asm) |
| `memory_fill.asm` | Initialization | Filling a block of memory with a specific constant value. | [View](Memory%20Operations/memory_fill.asm) |
| `memory_scan.asm` | Search | Scanning a memory range for a specific byte value. | [View](Memory%20Operations/memory_scan.asm) |

</details>

<details>
<summary><strong>💠 Patterns (4 Programs)</strong></summary>

| Program | Pattern Type | Description | Code |
|:---|:---|:---|:-:|
| `diamond_pattern.asm` | Geometric | Logic to print a symmetrical diamond star pattern. | [View](Patterns/diamond_pattern.asm) |
| `inverted_triangle.asm` | Geometric | Logic to print an inverted triangle of stars. | [View](Patterns/inverted_triangle.asm) |
| `number_pyramid.asm` | Numeric | Logic to print a pyramid of incrementing numbers. | [View](Patterns/number_pyramid.asm) |
| `triangle_pattern.asm` | Geometric | Logic to print a standard right-angled star triangle. | [View](Patterns/triangle_pattern.asm) |

</details>

<details>
<summary><strong>🧩 Procedures (5 Programs)</strong></summary>

| Program | Concept | Description | Code |
|:---|:---|:---|:-:|
| `basic_procedure.asm` | CALL/RET | Introduction to defining and calling basic procedures. | [View](Procedures/basic_procedure.asm) |
| `local_variables.asm` | Stack Frame | Managing local variables within a procedure using the stack (BP). | [View](Procedures/local_variables.asm) |
| `nested_procedures.asm` | Nesting | Demonstration of a procedure calling another procedure. | [View](Procedures/nested_procedures.asm) |
| `procedure_parameters.asm` | Parameters | Passing arguments to procedures using registers and stack. | [View](Procedures/procedure_parameters.asm) |
| `recursive_factorial.asm` | Recursion | Implementing the Factorial function using self-calling procedures. | [View](Procedures/recursive_factorial.asm) |

</details>

<details>
<summary><strong>🔍 Searching (4 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `binary_search.asm` | Binary Search | Efficient O(log n) search on a sorted array. | [View](Searching/binary_search.asm) |
| `character_occurrences_count.asm`| Frequency | Counting how many times a char appears in a string. | [View](Searching/character_occurrences_count.asm) |
| `linear_search.asm` | Linear Search | Standard O(n) scan through an array to find a value. | [View](Searching/linear_search.asm) |
| `search_element_array.asm` | Search | Basic implementation of finding an element in a list. | [View](Searching/search_element_array.asm) |

</details>

<details>
<summary><strong>🔥 Simulation (3 Programs)</strong></summary>

| Program | Simulation | Description | Code |
|:---|:---|:---|:-:|
| `fire_monitoring_system.asm` | Sensor System | Simulating a fire alarm trigger based on temperature input. | [View](Simulation/fire_monitoring_system.asm) |
| `garment_defect.asm` | Quality Control | Simulating a defect detection system in a manufacturing line. | [View](Simulation/garment_defect.asm) |
| `water_level_controller.asm` | Control System | Simulating a water tank level controller (Overflow/Refill). | [View](Simulation/water_level_controller.asm) |

</details>

<details>
<summary><strong>📊 Sorting (5 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `array_ascending.asm` | Sorting | Sorting an array of numbers in Ascending order. | [View](Sorting/array_ascending.asm) |
| `array_descending.asm` | Sorting | Sorting an array of numbers in Descending order. | [View](Sorting/array_descending.asm) |
| `bubble_sort.asm` | Bubble Sort | Implementation of the Bubble Sort algorithm. | [View](Sorting/bubble_sort.asm) |
| `insertion_sort.asm` | Insertion Sort | Implementation of the Insertion Sort algorithm. | [View](Sorting/insertion_sort.asm) |
| `selection_sort.asm` | Selection Sort | Implementation of the Selection Sort algorithm. | [View](Sorting/selection_sort.asm) |

</details>

<details>
<summary><strong>📚 Stack Operations (3 Programs)</strong></summary>

| Program | Operation | Description | Code |
|:---|:---|:---|:-:|
| `push_pop.asm` | Basic Ops | Demonstration of PUSH and POP instructions. | [View](Stack%20Operations/push_pop.asm) |
| `reverse_string_stack.asm` | Application | Using the Stack's LIFO property to reverse a string. | [View](Stack%20Operations/reverse_string_stack.asm) |
| `swap_using_stack.asm` | Application | Using the Stack to swap two values. | [View](Stack%20Operations/swap_using_stack.asm) |

</details>

<details>
<summary><strong>🧵 String Operations (5 Programs)</strong></summary>

| Program | Operation | Description | Code |
|:---|:---|:---|:-:|
| `palindrome_check.asm` | Verification | Checking if a string reads the same forwards and backwards. | [View](String%20Operations/palindrome_check.asm) |
| `string_length.asm` | Calculation | Counting the number of characters in a string. | [View](String%20Operations/string_length.asm) |
| `string_reverse.asm` | Transformation | Reversing the character order of a string in memory. | [View](String%20Operations/string_reverse.asm) |
| `to_lowercase.asm` | Conversion | Converting all uppercase characters in a string to lowercase. | [View](String%20Operations/to_lowercase.asm) |
| `to_uppercase.asm` | Conversion | Converting all lowercase characters in a string to uppercase. | [View](String%20Operations/to_uppercase.asm) |

</details>

<details>
<summary><strong>🛠️ Utilities (5 Programs)</strong></summary>

| Program | Utility | Description | Code |
|:---|:---|:---|:-:|
| `beep_sound.asm` | Audio | Generating a beep sound using the internal speaker. | [View](Utilities/beep_sound.asm) |
| `clear_screen.asm` | Screen | Routine to clear the DOS console screen. | [View](Utilities/clear_screen.asm) |
| `delay_timer.asm` | Timing | Generating a precise execution delay loop. | [View](Utilities/delay_timer.asm) |
| `display_date.asm` | System | Fetching and displaying the current system date. | [View](Utilities/display_date.asm) |
| `password_input.asm` | Security | Reading password input while masking characters (e.g., *). | [View](Utilities/password_input.asm) |

</details>

---

<!-- USAGE -->
## Usage Guidelines

### Execution Steps
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS.git
    ```

2.  **Open in Emulator**:
    - Launch **Emu8086**.
    - Click `Open` and navigate to the desired `.asm` file (e.g., `Arithmetic/addition_16bit_simple.asm`).

3.  **Assemble and Run**:
    - Click the `emulate` button to compile.
    - Use the `Run` or `Single Step` controls to execute the code and observe register changes.

### Academic Use
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

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

**Summary**: You are free to share and adapt this content for any purpose, even commercially, as long as you provide appropriate attribution to the original author.

**Copyright © 2021** [Amey Thakur](https://github.com/Amey-Thakur)

---

<!-- ABOUT -->
## About This Repository

**Created & Maintained by**: [Amey Thakur](https://github.com/Amey-Thakur)  
**Academic Journey**: Bachelor of Engineering in Computer Engineering (2018-2022)  
**Institution**: [Terna Engineering College](https://ternaengg.ac.in/), Navi Mumbai  
**University**: [University of Mumbai](https://mu.ac.in/)

This repository represents a comprehensive collection of 8086 assembly programs developed, verified, and documented during my academic journey. All content has been carefully organized to serve as a valuable resource for mastering low-level system architecture.

**Connect**: [GitHub](https://github.com/Amey-Thakur) · [LinkedIn](https://www.linkedin.com/in/amey-thakur)

### Acknowledgments

Special thanks to the faculty members of the **Department of Computer Engineering** at Terna Engineering College for their guidance and instruction in Microprocessors. Their clear teaching and continued support helped develop a strong understanding of low-level system architecture.

Special thanks to the peers whose discussions and support contributed meaningfully to this learning experience.

---

<!-- FOOTER -->
<div align="center">

  **[⬆ Back to Top](#8086-assembly-language-programs)** &nbsp;·&nbsp; [👥 Authors](#authors) &nbsp;·&nbsp; [📖 Overview](#overview) &nbsp;·&nbsp; [✨ Features](#features) &nbsp;·&nbsp; [📁 Structure](#project-structure) &nbsp;·&nbsp; [💾 Program Details](#program-details) &nbsp;·&nbsp; [🚀 Usage](#usage-guidelines) &nbsp;·&nbsp; [📜 License](#license) &nbsp;·&nbsp; [ℹ️ About](#about-this-repository) &nbsp;·&nbsp; [🙏 Acknowledgments](#acknowledgments)

  <br>

  **[🧪 Microprocessor Lab](https://github.com/Amey-Thakur/MICROPROCESSOR-AND-MICROPROCESSOR-LAB)** &nbsp;·&nbsp; **[💻 Project Repository](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)**

</div>

---

<div align="center">

  ### 🎓 [Computer Engineering Repository](https://github.com/Amey-Thakur/COMPUTER-ENGINEERING)

  **Computer Engineering (B.E.) - University of Mumbai**

  *Semester-wise curriculum, laboratories, projects, and academic notes.*

</div>
