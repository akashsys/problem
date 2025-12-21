### **Power-Aware ALU Top – Design Specification**



**OVERVIEW**



The Arithmetic Logic Unit (ALU) is a synchronous digital block that performs arithmetic and logical operations on two 16-bit operands.

The design models POWER-AWARE BEHAVIOR using CLOCK DISCONNECTION AND OUTPUT CLAMPING, similar to low-power SoC designs that use UPF concepts such as power gating and isolation.



Power-aware behavior is implemented OUTSIDE THE ALU, keeping the ALU itself purely functional.



---



**INPUTS AND OUTPUTS**



Inputs to the design:



\* CLK: system clock driving all sequential logic

\* RST\_N: active-low reset

\* A: 16-bit operand input

\* B: 16-bit operand input

\* OPCODE: 4-bit control selecting the ALU operation

\* START: initiates an ALU operation

\* DISS\_CLK: active-high control signal that disconnects the ALU clock (models ALU power-off)



**Outputs from the design:**



\* RESULT: 16-bit ALU output after power-aware handling

\* BUSY: indicates that the ALU is executing a multi-cycle operation

\* CLAMP\_OBS: observation port exposing the clamp value used during power-off



---



**FUNCTIONAL BEHAVIOR**



The ALU performs arithmetic and logical operations based on the opcode.



\* Operations begin when START is asserted while the ALU is idle

\* The ALU does not accept new operations while BUSY is high

\* Results are produced only when the ALU clock is supplied



Single-cycle operations include:



\* Addition, subtraction

\* AND, OR, XOR, NOR, XNOR

\* Shift-left logical



Multi-cycle operations include:



\* Multiplication

\* Division



Multi-cycle operations hold the ALU in a BUSY state for a fixed number of clock cycles before producing a result.



---



**POWER-AWARE BEHAVIOR**



Power-aware behavior is modeled using CLOCK DISCONNECTION.



\* DISS\_CLK = 1 indicates that the ALU power domain is OFF

\* When DISS\_CLK is high:



&nbsp; \* The ALU clock is disconnected

&nbsp; \* ALU internal state is frozen

&nbsp; \* No ALU computation occurs

&nbsp; \* The ALU output MUST NOT propagate to the top-level result



Clock disconnection models power gating at RTL abstraction.



---



**OUTPUT CLAMPING BEHAVIOR**



Output isolation is implemented using a MUX-BASED CLAMP in the top-level logic.



\* A constant CLAMP VALUE is defined in the top-level logic

\* CLAMP\_OBS exposes the clamp value for verification

\* When DISS\_CLK = 1, the output RESULT MUST BE CLAMPED

\* When DISS\_CLK = 0, the output RESULT reflects ALU computation



Clamp value rules:



\* Clamp value must always resolve to a known value (0 or 1)

\* Clamp value must never be X or Z

\* When the ALU domain is OFF, RESULT MUST EXACTLY MATCH CLAMP\_OBS

\* Missing or undriven clamp logic is considered a FUNCTIONAL BUG



---



**OUTPUT PRIORITY**



The output RESULT follows this priority order:



1\. Reset

2\. Clock disconnection (DISS\_CLK)

3\. Normal functional operation



---



**VERIFICATION INTENT**



The golden design correctly enforces:



\* Functional correctness of ALU operations

\* Clock-disconnect behavior during power-off

\* Deterministic and resolvable clamp behavior

\* Correct matching between RESULT and CLAMP\_OBS when power is OFF



Tests are written such that:



\* All tests pass on the golden design

\* Selected tests fail on incorrect implementations



