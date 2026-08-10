# Contributing

Thank you for looking. This repository is an archive of 8086 assembly programs and the browser simulator that runs them, so contributions are held to one standard above all others: **everything here must be correct, and provably so.**

---

## Before you start

Fork the repository, then:

```bash
git clone https://github.com/<your-username>/8086-ASSEMBLY-LANGUAGE-PROGRAMS.git
cd "8086-ASSEMBLY-LANGUAGE-PROGRAMS/Source Code/8086 Microprocessor Simulator"
npm test
```

There are no dependencies and no build step. `npm test` must pass before you change anything, so you know any failure afterwards is yours.

---

## Adding a program

1. **Check it does not already exist.** 525 programs across 39 categories is a lot; search the [Program Details](README.md#program-details) table first.

2. **Put it in the right category** under `Source Code/`, named in `lower_snake_case.asm`.

3. **Give it the standard header.** Every program carries one, and a test enforces it:

   ```asm
   ; =============================================================================
   ; TITLE: What The Program Is
   ; DESCRIPTION: One or two sentences on what it does and why it is interesting.
   ; AUTHOR: Amey Thakur (https://github.com/Amey-Thakur)
   ; REPOSITORY: https://github.com/Amey-Thakur/8086-ASSEMBLY-LANGUAGE-PROGRAMS
   ; LICENSE: MIT License
   ; =============================================================================
   ```

4. **Make it print its result.** A program that computes into a register and halts looks broken in the console. Show the answer.

5. **Make it finish.** Input runs out under the test harness, so give any read loop a counted limit as well as its real exit condition. Programs that run forever by design, such as a traffic light controller, are listed in `js/test/programs.test.mjs`.

6. **End the file with technical notes**: three numbered headings, three lines each, on what is worth understanding.

7. **Regenerate and verify:**

   ```bash
   npm run index      # rebuild the program list
   npm run catalogue  # rewrite the README table
   npm run counts     # rewrite every published figure
   npm run structure  # rewrite the project tree
   npm test           # everything must pass
   ```

---

## Changing the simulator

The engine is in `Source Code/8086 Microprocessor Simulator/js/`, split into `cpu/`, `asm/`, `exec/` and `ui/`. Each file states its purpose and its place in the module order at the top.

**A change to the engine needs a test.** Put it in the suite that matches the layer:

| Suite | Covers |
|:---|:---|
| `core`, `alu`, `cpu` | Memory, registers, flags, the ALU |
| `lexer`, `operands`, `assembler` | Everything before execution |
| `executor`, `strings` | Instruction dispatch, string operations |
| `robustness` | Malformed input, runaway loops, wrap-around |
| `library`, `programs`, `output` | The program library as a whole |

**Never edit `expected-output.json` by hand.** It is the recorded output of every program. Run `npm run test:record`, then read the diff: a removed line means a program's behaviour changed. If you did not mean to change it, you have a bug.

**Match the 8086, not a later processor.** `PUSH SP`, unmasked shift counts and `LOOP` from zero all behave differently on an 8086, and the tests pin them.

---

## Style

- British spelling.
- Comments explain **why**, not what the instruction does.
- No em dashes.
- Uppercase mnemonics, lowercase in prose.
- Name a constant rather than repeating a literal.

---

## Submitting

```bash
git checkout -b feature/what-it-does
git commit -m "Add a clear description of the change"
git push origin feature/what-it-does
```

Then open a pull request saying **what** you changed, **why**, and **how you verified it**. If you added a program, paste its output.

A pull request that leaves `npm test` failing will not be merged.

---

## Reporting a problem

Open an issue with the program or file, what you expected, what happened, and the shortest assembly that shows it. A wrong answer from the simulator is the most valuable report there is: it means a test is missing.

For security matters, see [SECURITY.md](SECURITY.md).
