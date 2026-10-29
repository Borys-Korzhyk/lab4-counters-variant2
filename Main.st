(* Lab 4. Borys Korzhyk. Variant 2. Cscape Enhanced IEC, ST.
   Enter VAR declarations in the variable table and the body in a cyclic ST block. *)
PROGRAM Main
VAR
    startConveyor : BOOL := FALSE;
    stopConveyor  : BOOL := FALSE;
    sensorPulse   : BOOL := FALSE;
    resetCounter  : BOOL := FALSE;
    setPoint      : INT := 20;
    motorRunning  : BOOL := FALSE;
    batchComplete : BOOL := FALSE;
    currentCount  : INT := 20;
    processedCount : INT := 0;
    initialized   : BOOL := FALSE;
    loadCounter   : BOOL := FALSE;
    sensorEdge    : R_TRIG;
    startEdge     : R_TRIG;
    partCounter   : CTD;
END_VAR

(* Track raw sensor edges even while stopped.
   A sensor held high at Start must not count as a new part.
   Cscape CTD requires an external edge detector. *)
sensorEdge(sensorPulse);
startEdge(startConveyor);
loadCounter := resetCounter OR NOT initialized;

(* Reset loads 20 and stops the motor.
   Stop has priority; Start requires a new button press. *)
IF loadCounter OR stopConveyor THEN
    motorRunning := FALSE;
ELSIF startEdge.Q AND NOT batchComplete THEN
    motorRunning := TRUE;
END_IF;

(* CD is TRUE for one scan per part. Parameters: CD, LOAD, PV. *)
partCounter(sensorEdge.Q AND motorRunning AND NOT loadCounter,
            loadCounter, setPoint);
currentCount := partCounter.CV;
processedCount := setPoint - currentCount;
batchComplete := partCounter.Q;

(* Stop in the same scan as the twentieth part. *)
IF batchComplete OR stopConveyor OR loadCounter THEN
    motorRunning := FALSE;
END_IF;
initialized := TRUE;
END_PROGRAM
