### **Power-Aware ALU Top – Design Specification**



OVERVIEW

The Arithmetic Logic Unit (ALU) is a synchronous digital block that performs arithmetic and logical operations on two 16-bit operands. The design also models power-aware behavior using explicit power enable and isolation signals. This allows verification of correct functionality during normal operation, power-down, and isolation scenarios, similar to low-power SoC designs using UPF concepts.



INPUTS AND OUTPUTS

Inputs to the design are:



\* clk: system clock driving all sequential logic

\* rst\_n: active-low reset

\* A: 16-bit operand input

\* B: 16-bit operand input

\* opcode: 4-bit control selecting the ALU operation

\* start: initiates an ALU operation

\* alu\_pwr\_en: indicates whether the ALU power domain is enabled

\* iso\_en: enables isolation between the ALU and the output domain



Outputs from the design are:



\* result: 16-bit ALU output after power and isolation handling

\* busy: indicates that the ALU is executing a multi-cycle operation



FUNCTIONAL BEHAVIOR

The ALU performs arithmetic and logical operations based on the opcode.



\* Operations begin when start is asserted while the ALU is idle

\* The ALU does not accept new operations while busy is high

\* Results are produced only when the ALU is powered on and not isolated



Single-cycle operations include:



\* Addition, subtraction

\* AND, OR, XOR, NOR, XNOR

\* Shift-left logical



Multi-cycle operations include:



\* Multiplication

\* Division



Multi-cycle operations hold the ALU in a busy state for a fixed number of clock cycles before producing a result.



RESET BEHAVIOR

Reset has the highest priority in the design.



\* When rst\_n is low, internal state machines return to idle

\* Cycle counters are cleared

\* The output result is forced to zero

\* Reset overrides power enable and isolation signals



POWER BEHAVIOR

The alu\_pwr\_en signal models the power state of the ALU domain.



\* When alu\_pwr\_en is low, the ALU is considered powered down

\* ALU internal execution is disabled

\* The ALU state machine is forced to idle

\* The output result must be clamped to a safe value



ISOLATION BEHAVIOR

The iso\_en signal models isolation between power domains.



\* When iso\_en is high, the ALU output must not propagate to the result

\* Isolation blocks functional values regardless of ALU activity

\* The output result must be driven to the clamp value



CLAMP VALUE RULES



\* A constant clamp value is defined in the top-level logic

\* The clamp value must always resolve to a known value (0 or 1)

\* The clamp value must never be X or Z

\* Clamp is applied when iso\_en is high or alu\_pwr\_en is low

\* When a power domain is OFF(iso\_en high and alu\_pwr\_en low) then the output must be a valid 0/1 and also must

match the value of the clamp value defined and if not defined must be set and makes sure output matches it when

ALU domain is OFF.







OUTPUT PRIORITY

The output result follows this priority order:



\* Reset

\* Isolation enable

\* Power-down

\* Normal functional operation



POWER-AWARE SEQUENCING ASSUMPTIONS



\* Isolation and power-down are applied only when the ALU is idle

\* Mid-operation power or isolation transitions are not supported

\* Verification tests ensure no overlap between ALU execution cycles and power control changes



VERIFICATION INTENT

The golden design correctly enforces power-aware rules and clamp behavior. Buggy implementations may fail to initialize the clamp value, ignore isolation, or propagate ALU results during power-down. Tests are written such that all tests pass on the golden design and selected tests fail on incorrect implementations.

