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

  [👥 Authors](#authors) &nbsp;·&nbsp; [📖 Overview](#overview) &nbsp;·&nbsp; [✨ Features](#features) &nbsp;·&nbsp; [📁 Structure](#project-structure) &nbsp;·&nbsp; [🚀 Usage](#usage) &nbsp;·&nbsp; [📜 License](#license) &nbsp;·&nbsp; [ℹ️ About](#about-this-repository) &nbsp;·&nbsp; [🙏 Acknowledgments](#acknowledgments)

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
  | **Instruction Implementation** | Practical demonstrations of Arithmetic, Logical, string, and Transfer instruction sets |
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

  **[⬆ Back to Top](#8086-assembly-language-programs)** &nbsp;·&nbsp; [👥 Authors](#authors) &nbsp;·&nbsp; [📖 Overview](#overview) &nbsp;·&nbsp; [✨ Features](#features) &nbsp;·&nbsp; [📁 Structure](#project-structure) &nbsp;·&nbsp; [🚀 Usage](#usage) &nbsp;·&nbsp; [📜 License](#license) &nbsp;·&nbsp; [ℹ️ About](#about-this-repository) &nbsp;·&nbsp; [🙏 Acknowledgments](#acknowledgments)

  <br>

  **[🧪 Microprocessor Lab](https://github.com/Amey-Thakur/MICROPROCESSOR-AND-MICROPROCESSOR-LAB)** &nbsp;·&nbsp; **[💻 Project Repository](https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS)**

</div>

---

<div align="center">

  ### 🎓 [Computer Engineering Repository](https://github.com/Amey-Thakur/COMPUTER-ENGINEERING)

  **Computer Engineering (B.E.) - University of Mumbai**

  *Semester-wise curriculum, laboratories, projects, and academic notes.*

</div>
