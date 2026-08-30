# Synchronous Dual-Street Traffic Light Controller (Verilog HDL)

A synthesizable, synchronous Finite State Machine (FSM) implemented in Verilog-2001 to manage vehicular traffic flow across a bidirectional four-way intersection (East-West vs. North-South). The controller incorporates dedicated yellow warning phases and all-red clearance intervals to prevent vehicular conflict during direction handoffs.

---

## 1. System Specifications

* **Architecture:** Moore Finite State Machine (FSM) with synchronized delay counters
* **Target Grid:** 4-Way Dual-Street Intersection (Street A: East-West, Street B: North-South)
* **Output Interface:** Two 3-bit active-high decoded buses (`light_A[2:0]`, `light_B[2:0]`)
* **Signal Encoding:**
  * `3'b001` : GREEN (Active flow)
  * `3'b010` : YELLOW (Warning / Stopping clearance)
  * `3'b100` : RED (Full stop)
* **Safety Feature:** Dual all-red clearance intervals ($S_2, S_5$) inserted before cross-street green phases.

---

## 2. Finite State Machine (FSM) Architecture
+-----------------------------------------------------------+
    |                                                           |
    v                                                           |
 [ S0: EW Green / NS Red ] (6s)                                 |
    |                                                           |
    v                                                           |
 [ S1: EW Yellow / NS Red ] (1s)                                |
    |                                                           |
    v                                                           |
 [ S2: All Red Clearance ] (1s)                                 |
    |                                                           |
    v                                                           |
 [ S3: EW Red / NS Green ] (6s)                                 |
    |                                                           |
    v                                                           |
 [ S4: EW Red / NS Yellow ] (1s)                                |
    |                                                           |
    v                                                           |
 [ S5: All Red Clearance ] (1s) --------------------------------+

### State & Timing Table

| State | State Code | Street A (East-West) | Street B (North-South) | Output Bus `[A, B]` | Duration | Phase Purpose |
| :---: | :---: | :---: | :---: | :---: | :---: | :--- |
| **S0** | `3'b000` | GREEN (`001`) | RED (`100`) | `001_100` | 6 Cycles | Street A active flow |
| **S1** | `3'b001` | YELLOW (`010`) | RED (`100`) | `010_100` | 1 Cycle | Street A stopping warning |
| **S2** | `3'b010` | RED (`100`) | RED (`100`) | `100_100` | 1 Cycle | Intersection clearance buffer |
| **S3** | `3'b011` | RED (`100`) | GREEN (`001`) | `100_001` | 6 Cycles | Street B active flow |
| **S4** | `3'b100` | RED (`100`) | YELLOW (`010`) | `100_010` | 1 Cycle | Street B stopping warning |
| **S5** | `3'b101` | RED (`100`) | RED (`100`) | `100_100` | 1 Cycle | Intersection clearance buffer |

**Full Cycle Duration:** 16 Clock Cycles (6s + 1s + 1s + 6s + 1s + 1s).

---

## 3. Module Hierarchy and Parameters

### Parameters
* `GREEN_TIME` (Default: `3'd6`): Duration for green active flow states.
* `YELLOW_TIME` (Default: `3'd1`): Duration for yellow caution states.
* `ALL_RED_TIME` (Default: `3'd1`): Duration for all-red clearance intervals.

### I/O Ports

| Port Name | Direction | Width | Description |
| :--- | :---: | :---: | :--- |
| `clk` | Input | 1-bit | System master clock signal |
| `rst` | Input | 1-bit | Asynchronous active-high reset |
| `light_A` | Output | 3-bit | One-hot status bus for Street A `[Red, Yellow, Green]` |
| `light_B` | Output | 3-bit | One-hot status bus for Street B `[Red, Yellow, Green]` |

---

## 4. Repository Structure

```plaintext
.
├── traffic_light_controller.v       # Synthesizable RTL design module
├── traffic_light_controller_tb.v    # Self-checking simulation testbench
├── dump.vcd                         # Simulation waveform trace file
└── README.md                        # Technical documentation

## 5. Verification and Simulation

### Prerequisites
* Icarus Verilog (`iverilog`) compiler
* GTKWave waveform viewer

### Build and Run

1. **Compile Design and Testbench:**
   ```bash
   iverilog -o traffic_sim traffic_light_controller.v traffic_light_controller_tb.v

2. **Execute Simulation Runtime:**
   ```bash
   vvp traffic_sim

3. **Inspect Waveforms:**
   ```bash
   gtkwave dump.vcd

Simulation Analysis Checklist

    * Asynchronous Reset: When rst = 1, the state immediately forces to S0 and timer initializes to 1.

    * State Sequencing: The sequential machine transitions sequentially from S0 through S5 before returning to S0.

    * Output Mutex Validation: No condition permits conflicting non-red signals across both streets simultaneously.

## 6. License

This project is licensed under the MIT License. See the LICENSE file for details.

