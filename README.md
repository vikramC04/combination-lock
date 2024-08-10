# Combination Lock FSM 
This project implements a robust combination lock using a Moore Finite State Machine (FSM) model in Verilog, specifically designed for the DE1-SOC Board. This lock system uses a secure 4-bit input sequence and offers advanced features, including an alarm system after consecutive incorrect attempts and the ability to update the combination code, ensuring both security and flexibility.

## Design Features

### Moore Finite State Machine (FSM) Architecture
The lock's logic is controlled by a Moore FSM, ensuring that the output is determined entirely by the current state of the machine. This makes the system more predictable, easier to debug, and robust against unintended behaviors.

### New Combination 
Users can dynamically update the four bit combination code, allowing the lock to adapt to changing security needs. This flexibility is crucial in environments where the access code may need to be regularly changed.

### Security Alarm System
An integrated alarm system is triggered after two consecutive incorrect combination entries. This feature enhances security by deterring brute-force attempts and alerting users to potential unauthorized access.

## Detailed Module Descriptions
### Top-Level Module: combinationlock
This module integrates all the components of the combination lock, including input conditioning, FSM control, combination storage, and display. It handles inputs from the DE1-SOC Board's switches and keys, processes the combination logic, and outputs the status on a 7-segment display.


### Register Module: register
A 4-bit register with enable functionality. It stores the combination input and updates it when a new combination is set.
Key Operation:
-Stores the current combination code.
-Resets to a default combination on a system reset.

### Comparator Module: compare
Compares the entered combination against the stored combination to determine if the input is correct.
Key Operation:
-Outputs a signal indicating whether the entered combination matches the stored combination.

### Input Conditioning Module: inputConditioning
Debounces the input signals to ensure stable operation of the FSM by conditioning the key presses.
Key Operation:
-Prevents spurious inputs from affecting the FSM transitions.

### Moore State Machine Module: moorestatemachine
The core of the lock's logic, controlling the state transitions based on user inputs and the correctness of the entered combination.
Key States:
-Default: Awaiting user input.
-Open: The lock is open upon correct combination entry.
-Fail: Incorrect combination entered; system awaits further action.
-Alarm: Triggered after two consecutive incorrect entries.
-Change: Allows the user to set a new combination.

### 7-Segment Display Module: hex7seg
Converts the FSM's state into a readable output on the 7-segment display, showing whether the lock is open, in alarm mode, or allowing a new combination to be set.
Key Operation:
-Displays different symbols based on the lock's status (- for default, A for alarm, n for new combination, O for open).

