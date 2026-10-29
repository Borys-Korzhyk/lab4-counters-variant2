(* Custom pulse function block based on TON1ms.
   Create inputs, outputs and local variables in the Cscape UDFB editor. *)
FUNCTION_BLOCK TP
VAR_INPUT
    IN : BOOL;
    PT : INT := 10;
END_VAR
VAR_OUTPUT
    Pulse_Q : BOOL := FALSE;
END_VAR
VAR
    inputEdge : R_TRIG;
    timer : TON1ms;
    active : BOOL := FALSE;
END_VAR

inputEdge(IN);
IF inputEdge.Q AND NOT active THEN
    active := TRUE;
END_IF;
timer(active, PT);
IF timer.Q THEN
    active := FALSE;
END_IF;
Pulse_Q := active;
END_FUNCTION_BLOCK
