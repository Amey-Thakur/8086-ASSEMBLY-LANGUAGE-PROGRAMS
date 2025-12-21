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
| `comprehensive_8086_addressing_modes_reference.asm` | Addressing | Comprehensive reference of all 8086 addressing modes. | [View](Addressing%20Modes/comprehensive_8086_addressing_modes_reference.asm) |

</details>

<details>
<summary><strong>🧮 Arithmetic (14 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `add_array_of_bytes_from_memory.asm` | Addition | Summing bytes from memory locations. | [View](Arithmetic/add_array_of_bytes_from_memory.asm) |
| `addition_16bit_packed_bcd.asm` | BCD Math | Adding packed BCD numbers. | [View](Arithmetic/addition_16bit_packed_bcd.asm) |
| `addition_16bit_simple.asm` | Addition | Basic 16-bit addition. | [View](Arithmetic/addition_16bit_simple.asm) |
| `calculate_sum_of_first_n_natural_numbers.asm` | Series Sum | Summing 1 to N. | [View](Arithmetic/calculate_sum_of_first_n_natural_numbers.asm) |
| `multiplication_8bit_unsigned.asm` | Multiplication | 8-bit unsigned multiplication. | [View](Arithmetic/multiplication_8bit_unsigned.asm) |
| *...and 9 more programs.* | | | [Browse Folder](Arithmetic/) |

</details>

<details>
<summary><strong>📦 Array Operations (7 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `calculate_sum_of_array_elements.asm` | Traversal | Summing all elements in an array. | [View](Array%20Operations/calculate_sum_of_array_elements.asm) |
| `find_maximum_element_in_array.asm` | Search | Finding the largest value. | [View](Array%20Operations/find_maximum_element_in_array.asm) |
| `copy_block_of_data_between_arrays.asm` | Transfer | Block copy operations. | [View](Array%20Operations/copy_block_of_data_between_arrays.asm) |
| *...and 4 more programs.* | | | [Browse Folder](Array%20Operations/) |

</details>

<details>
<summary><strong>🔌 Bitwise Operations (8 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `bitwise_and_logic_demonstration.asm` | Logic (AND) | Demonstrating AND operation. | [View](Bitwise%20Operations/bitwise_and_logic_demonstration.asm) |
| `bitwise_rotate_left_circular_shift.asm` | Rotate (ROL) | Circular left shift of bits. | [View](Bitwise%20Operations/bitwise_rotate_left_circular_shift.asm) |
| `bitwise_xor_logic_demonstration.asm` | Logic (XOR) | Exclusive OR logical operation. | [View](Bitwise%20Operations/bitwise_xor_logic_demonstration.asm) |
| *...and 5 more programs.* | | | [Browse Folder](Bitwise%20Operations/) |

</details>

<details>
<summary><strong>🔀 Control Flow (7 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `if_then_else_conditional_logic_structure.asm` | Branching | Conditional execution logic. | [View](Control%20Flow/if_then_else_conditional_logic_structure.asm) |
| `switch_case_multiway_branching_logic.asm` | Switch-Case | Multi-way branching using jump tables. | [View](Control%20Flow/switch_case_multiway_branching_logic.asm) |
| `for_loop_counter_iteration_pattern.asm` | Iteration | Counter-controlled loops. | [View](Control%20Flow/for_loop_counter_iteration_pattern.asm) |
| *...and 4 more programs.* | | | [Browse Folder](Control%20Flow/) |

</details>

<details>
<summary><strong>🔄 Conversion (11 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `convert_packed_bcd_to_hexadecimal.asm` | Base Conv | BCD to Hex conversion. | [View](Conversion/convert_packed_bcd_to_hexadecimal.asm) |
| `convert_hexadecimal_to_decimal_string.asm` | Base Conv | Hex to Decimal string conversion. | [View](Conversion/convert_hexadecimal_to_decimal_string.asm) |
| `celsius_fahrenheit_temperature_converter.asm` | Formula | Temperature unit conversion. | [View](Conversion/celsius_fahrenheit_temperature_converter.asm) |
| *...and 8 more programs.* | | | [Browse Folder](Conversion/) |

</details>

<details>
<summary><strong>📚 Data Structures (2 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `queue.asm` | Queue | FIFO data structure implementation. | [View](Data%20Structures/queue.asm) |
| `stack_array.asm` | Stack | LIFO structure using arrays. | [View](Data%20Structures/stack_array.asm) |

</details>

<details>
<summary><strong>🔢 Expression (13 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `calculator.asm` | Arithmetic | Basic calculator logic. | [View](Expression/calculator.asm) |
| `factorial.asm` | Recursion | Calculating factorial of a number. | [View](Expression/factorial.asm) |
| `fibonacci.asm` | Series | Generating Fibonacci sequence. | [View](Expression/fibonacci.asm) |
| *...and 10 more programs.* | | | [Browse Folder](Expression/) |

</details>

<details>
<summary><strong>🖲️ External Devices (9 Programs)</strong></summary>

| Program | Simulation | Description | Code |
|:---|:---|:---|:-:|
| `traffic_lights.asm` | Traffic Light | Traffic signal controller simulation. | [View](External%20Devices/traffic_lights.asm) |
| `stepper_motor.asm` | Motor Control | Stepper motor sequence generation. | [View](External%20Devices/stepper_motor.asm) |
| `keyboard.asm` | I/O | Keyboard interfacing. | [View](External%20Devices/keyboard.asm) |
| *...and 6 more programs.* | | | [Browse Folder](External%20Devices/) |

</details>

<details>
<summary><strong>📂 File Operations (4 Programs)</strong></summary>

| Program | Interrupt | Description | Code |
|:---|:---|:---|:-:|
| `create_file.asm` | INT 21h | Creating a new file. | [View](File%20Operations/create_file.asm) |
| `write_file.asm` | INT 21h | Writing data to a file. | [View](File%20Operations/write_file.asm) |
| `read_file.asm` | INT 21h | Reading data from a file. | [View](File%20Operations/read_file.asm) |
| `delete_file.asm` | INT 21h | Deleting an existing file. | [View](File%20Operations/delete_file.asm) |

</details>

<details>
<summary><strong>🚩 Flags (5 Programs)</strong></summary>

| Program | Flag | Description | Code |
|:---|:---|:---|:-:|
| `carry_flag.asm` | CF | Demonstrating Carry Flag behavior. | [View](Flags/carry_flag.asm) |
| `zero_flag.asm` | ZF | Demonstrating Zero Flag behavior. | [View](Flags/zero_flag.asm) |
| `parity_flag.asm` | PF | Demonstrating Parity Flag behavior. | [View](Flags/parity_flag.asm) |
| *...and 2 more programs.* | | | [Browse Folder](Flags/) |

</details>

<details>
<summary><strong>🎨 Graphics (4 Programs)</strong></summary>

| Program | Mode | Description | Code |
|:---|:---|:---|:-:|
| `draw_rectangle.asm` | VGA | Drawing a rectangle shape. | [View](Graphics/draw_rectangle.asm) |
| `draw_line.asm` | VGA | Implementing line drawing algorithm. | [View](Graphics/draw_line.asm) |
| `colored_text.asm` | Text | Displaying colored text. | [View](Graphics/colored_text.asm) |
| `draw_pixel.asm` | VGA | Plotting individual pixels. | [View](Graphics/draw_pixel.asm) |

</details>

<details>
<summary><strong>⌨️ Input Output (4 Programs)</strong></summary>

| Program | I/O | Description | Code |
|:---|:---|:---|:-:|
| `read_number.asm` | Input | Reading numeric input. | [View](Input%20Output/read_number.asm) |
| `display_decimal.asm` | Output | Displaying decimal numbers. | [View](Input%20Output/display_decimal.asm) |
| `display_hex.asm` | Output | Displaying hexadecimal numbers. | [View](Input%20Output/display_hex.asm) |
| `display_binary.asm` | Output | Displaying binary numbers. | [View](Input%20Output/display_binary.asm) |

</details>

<details>
<summary><strong>⚡ Interrupts (8 Programs)</strong></summary>

| Program | Interrupt | Description | Code |
|:---|:---|:---|:-:|
| `dos_display_string.asm` | INT 21h/09h | Displaying strings via DOS. | [View](Interrupts/dos_display_string.asm) |
| `bios_video_mode.asm` | INT 10h | Setting BIOS video modes. | [View](Interrupts/bios_video_mode.asm) |
| `bios_system_time.asm` | INT 1Ah | Reading system time via BIOS. | [View](Interrupts/bios_system_time.asm) |
| *...and 5 more programs.* | | | [Browse Folder](Interrupts/) |

</details>

<details>
<summary><strong>👋 Introduction (15 Programs)</strong></summary>

| Program | Topic | Description | Code |
|:---|:---|:---|:-:|
| `hello_world_dos.asm` | Basics | Hello World using DOS interrupts. | [View](Introduction/hello_world_dos.asm) |
| `mov_instruction_demo.asm` | Syntax | Demonstrating MOV instruction. | [View](Introduction/mov_instruction_demo.asm) |
| `display_characters.asm` | Output | Printing individual characters. | [View](Introduction/display_characters.asm) |
| *...and 12 more programs.* | | | [Browse Folder](Introduction/) |

</details>

<details>
<summary><strong>📝 Macros (4 Programs)</strong></summary>

| Program | Feature | Description | Code |
|:---|:---|:---|:-:|
| `print_string_macro.asm` | Macro | Macro for string printing. | [View](Macros/print_string_macro.asm) |
| `macro_with_parameters.asm` | Params | Macros accepting parameters. | [View](Macros/macro_with_parameters.asm) |
| `nested_macros.asm` | Nesting | Nested macro definitions. | [View](Macros/nested_macros.asm) |
| `conditional_macros.asm` | Logic | Conditional assembly in macros. | [View](Macros/conditional_macros.asm) |

</details>

<details>
<summary><strong>📐 Mathematics (5 Programs)</strong></summary>

| Program | Math | Description | Code |
|:---|:---|:---|:-:|
| `lcm.asm` | LCM | Least Common Multiple calculation. | [View](Mathematics/lcm.asm) |
| `square_root.asm` | Roots | Integer square root calculation. | [View](Mathematics/square_root.asm) |
| `armstrong_number.asm` | Number Theory | Checking Armstrong numbers. | [View](Mathematics/armstrong_number.asm) |
| *...and 2 more programs.* | | | [Browse Folder](Mathematics/) |

</details>

<details>
<summary><strong>▦ Matrix (2 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `matrix_addition.asm` | Matrix | Addition of two matrices. | [View](Matrix/matrix_addition.asm) |
| `matrix_transpose.asm` | Matrix | Transposing a matrix. | [View](Matrix/matrix_transpose.asm) |

</details>

<details>
<summary><strong>💾 Memory Operations (4 Programs)</strong></summary>

| Program | Operation | Description | Code |
|:---|:---|:---|:-:|
| `block_copy.asm` | Transfer | Copying memory blocks. | [View](Memory%20Operations/block_copy.asm) |
| `memory_compare.asm` | Compare | Comparing memory blocks. | [View](Memory%20Operations/memory_compare.asm) |
| `memory_scan.asm` | Search | Scanning memory for byte. | [View](Memory%20Operations/memory_scan.asm) |
| `memory_fill.asm` | Fill | Filling memory with value. | [View](Memory%20Operations/memory_fill.asm) |

</details>

<details>
<summary><strong>💠 Patterns (4 Programs)</strong></summary>

| Program | Pattern | Description | Code |
|:---|:---|:---|:-:|
| `triangle_pattern.asm` | Shape | Printing a star triangle. | [View](Patterns/triangle_pattern.asm) |
| `number_pyramid.asm` | Number | Printing a number pyramid. | [View](Patterns/number_pyramid.asm) |
| `diamond_pattern.asm` | Shape | Printing a diamond shape. | [View](Patterns/diamond_pattern.asm) |
| `inverted_triangle.asm` | Shape | Printing inverted triangle. | [View](Patterns/inverted_triangle.asm) |

</details>

<details>
<summary><strong>🧩 Procedures (5 Programs)</strong></summary>

| Program | Concept | Description | Code |
|:---|:---|:---|:-:|
| `basic_procedure.asm` | Call/Ret | Basic procedure implementation. | [View](Procedures/basic_procedure.asm) |
| `procedure_parameters.asm` | Params | Passing parameters to procedures. | [View](Procedures/procedure_parameters.asm) |
| `recursive_factorial.asm` | Recursion | Recursive procedure call. | [View](Procedures/recursive_factorial.asm) |
| *...and 2 more programs.* | | | [Browse Folder](Procedures/) |

</details>

<details>
<summary><strong>🔍 Searching (4 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `binary_search.asm` | Binary Search | O(log n) search algorithm. | [View](Searching/binary_search.asm) |
| `linear_search.asm` | Linear Search | O(n) search algorithm. | [View](Searching/linear_search.asm) |
| `search_element_array.asm` | Search | Finding element in array. | [View](Searching/search_element_array.asm) |
| `character_occurrences_count.asm`| Count | Counting char occurrences. | [View](Searching/character_occurrences_count.asm) |

</details>

<details>
<summary><strong>🔥 Simulation (3 Programs)</strong></summary>

| Program | Simulation | Description | Code |
|:---|:---|:---|:-:|
| `fire_monitoring_system.asm` | Sensor | Fire alarm system simulation. | [View](Simulation/fire_monitoring_system.asm) |
| `water_level_controller.asm` | Controller | Water tank level controller. | [View](Simulation/water_level_controller.asm) |
| `garment_defect.asm` | System | Garment defect detection system. | [View](Simulation/garment_defect.asm) |

</details>

<details>
<summary><strong>📊 Sorting (5 Programs)</strong></summary>

| Program | Algorithm | Description | Code |
|:---|:---|:---|:-:|
| `bubble_sort.asm` | Bubble Sort | Standard bubble sort. | [View](Sorting/bubble_sort.asm) |
| `selection_sort.asm` | Selection Sort | Standard selection sort. | [View](Sorting/selection_sort.asm) |
| `insertion_sort.asm` | Insertion Sort | Standard insertion sort. | [View](Sorting/insertion_sort.asm) |
| `array_ascending.asm` | Sort | Array ascending sort. | [View](Sorting/array_ascending.asm) |
| `array_descending.asm` | Sort | Array descending sort. | [View](Sorting/array_descending.asm) |

</details>

<details>
<summary><strong>📚 Stack Operations (3 Programs)</strong></summary>

| Program | Stack | Description | Code |
|:---|:---|:---|:-:|
| `push_pop.asm` | Basic | Push and Pop operations. | [View](Stack%20Operations/push_pop.asm) |
| `reverse_string_stack.asm` | App | Reversing string using stack. | [View](Stack%20Operations/reverse_string_stack.asm) |
| `swap_using_stack.asm` | App | Swapping using stack. | [View](Stack%20Operations/swap_using_stack.asm) |

</details>

<details>
<summary><strong>🧵 String Operations (5 Programs)</strong></summary>

| Program | Op | Description | Code |
|:---|:---|:---|:-:|
| `palindrome_check.asm` | Check | Checking if string is palindrome. | [View](String%20Operations/palindrome_check.asm) |
| `string_length.asm` | Calc | Calculating string length. | [View](String%20Operations/string_length.asm) |
| `string_reverse.asm` | Transform | Reversing a string. | [View](String%20Operations/string_reverse.asm) |
| `to_uppercase.asm` | Case | Converting to uppercase. | [View](String%20Operations/to_uppercase.asm) |
| `to_lowercase.asm` | Case | Converting to lowercase. | [View](String%20Operations/to_lowercase.asm) |

</details>

<details>
<summary><strong>🛠️ Utilities (5 Programs)</strong></summary>

| Program | Utility | Description | Code |
|:---|:---|:---|:-:|
| `delay_timer.asm` | Timing | Generating time delay. | [View](Utilities/delay_timer.asm) |
| `clear_screen.asm` | Screen | Operations to clear screen. | [View](Utilities/clear_screen.asm) |
| `beep_sound.asm` | Sound | Generating beep sound. | [View](Utilities/beep_sound.asm) |
| `password_input.asm` | Security | Masked password input. | [View](Utilities/password_input.asm) |
| `display_date.asm` | System | Displaying system date. | [View](Utilities/display_date.asm) |

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
