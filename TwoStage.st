(* Independent assignment. Run as a separate cyclic program.
   Cscape Enhanced IEC: declarations in the variable table; body in ST.
   Five parts per container, three containers per shift, 3000 ms pause. *)
PROGRAM TwoStage
VAR
    startConveyor : BOOL := FALSE;
    stopConveyor  : BOOL := FALSE;
    sensorPulse   : BOOL := FALSE;
    resetShift    : BOOL := FALSE;
    motorRunning  : BOOL := FALSE;
    shiftComplete : BOOL := FALSE;
    currentParts  : INT := 0;
    currentContainers : INT := 0;
    runRequested  : BOOL := FALSE;
    pauseActive   : BOOL := FALSE;
    resetPartsNext : BOOL := FALSE;
    resetParts    : BOOL := FALSE;
    initialized   : BOOL := FALSE;
    resetAll      : BOOL := FALSE;
    sensorEdge    : R_TRIG;
    startEdge     : R_TRIG;
    containerEdge : R_TRIG;
    counter1      : CTU;
    counter2      : CTU;
    pauseTimer    : TON1ms;
END_VAR

sensorEdge(sensorPulse);
startEdge(startConveyor);
resetAll := resetShift OR NOT initialized;
resetParts := resetAll OR resetPartsNext;
resetPartsNext := FALSE;

IF resetAll THEN
    runRequested := FALSE;
    pauseActive := FALSE;
ELSIF stopConveyor THEN
    runRequested := FALSE;
ELSIF startEdge.Q AND NOT shiftComplete THEN
    runRequested := TRUE;
END_IF;

(* Ignore sensor events during pauses and after shift completion. *)
motorRunning := runRequested AND NOT pauseActive
                AND NOT shiftComplete AND NOT resetAll
                AND NOT stopConveyor;
counter1(sensorEdge.Q AND motorRunning, resetParts, 5);

(* Count exactly one container for each rising edge of counter1.Q. *)
containerEdge(counter1.Q);
counter2(containerEdge.Q AND NOT resetAll, resetAll, 3);
currentParts := counter1.CV;
currentContainers := counter2.CV;
shiftComplete := counter2.Q;

IF containerEdge.Q AND NOT shiftComplete AND NOT resetAll THEN
    pauseActive := TRUE;
END_IF;

(* TON1ms uses a numeric preset in milliseconds. *)
pauseTimer(pauseActive AND NOT resetAll, 3000);
IF pauseTimer.Q THEN
    pauseActive := FALSE;
    resetPartsNext := TRUE;
END_IF;

IF shiftComplete THEN
    runRequested := FALSE;
    pauseActive := FALSE;
END_IF;

(* Keep the motor stopped until counter1 has been reset. *)
motorRunning := runRequested AND NOT pauseActive
                AND NOT shiftComplete AND NOT resetAll
                AND NOT stopConveyor AND NOT resetPartsNext;
initialized := TRUE;
END_PROGRAM
