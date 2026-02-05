### **Real-Time SoC Game System: Head Soccer on FPGA**

A high-performance System-on-Chip (SoC) implementing a real-time, two-player interactive game on a Spartan-7 FPGA. This project features custom SystemVerilog hardware accelerators for physics and rendering, coordinated by an embedded MicroBlaze soft-core processor.

**System Architecture & HW/SW Co-Design**

The system utilizes a hybrid architecture to achieve 60 FPS fluid gameplay with zero input lag.

_Embedded Firmware & Control (MicroBlaze)_
- Interrupt-Driven Input: Decodes complex PS/2 keyboard scancodes (WASD and Arrow keys) to manage multi-key concurrent player movement.
- State Coordination: Manages high-level game states (Menu, Gameplay, Goal Reset, Win Condition) and synchronizes data with hardware registers via the AXI-Lite interface.

__Deterministic Hardware Accelerators (RTL)__

- Real-Time Physics Engine (ball_control.sv): Implemented gravity-based kinematics and elastic collision detection at the hardware level. Used fixed-point arithmetic to ensure single-cycle deterministic updates for ball trajectories.

- VGA Timing Controller (VGA_controller.sv): Engineered a clock-synchronous video pipeline generating 640x480 @ 60Hz output with precise horizontal and vertical synchronization pulses.

- Layered Rendering (Color_Mapper.sv): Developed a modular pixel-generation engine using ROM-based sprite storage and palette mapping for efficient resource utilization.

**Technical Achievements**

_Deterministic Physics & Collision Detection_

Unlike software-based games, the collision logic for player-ball interaction and goal detection (goal_detector.sv) is calculated in parallel with the rendering pipeline. This ensures that even during high-intensity gameplay, the physics engine remains perfectly synchronized with the VGA frame clock.

_Hardware Resource Optimization_
- Efficient Sprite Mapping: Utilized on-chip Block RAM (BRAM) to store graphical assets, reducing external memory bandwidth requirements.
- Clock Domain Management: Synchronized the 100MHz system clock with a derived 25MHz pixel clock to maintain visual stability across HDMI/VGA interfaces.

**Tech Stack**

Hardware Description: SystemVerilog, Verilog

Embedded Software: C (MicroBlaze Firmware)

Design Tools: Xilinx Vivado, Vitis Unified Software Platform

Target Platform: Xilinx Spartan-7 FPGA

**Engineering Challenge: Real-Time Sync**

The primary challenge was synchronizing the asynchronous PS/2 keyboard inputs with the synchronous 60Hz frame updates. I solved this by implementing a dual-buffered register system, where the MicroBlaze updates motion vectors in one buffer while the hardware accelerators read from the stable "active" buffer, preventing visual tearing or physics glitches.
