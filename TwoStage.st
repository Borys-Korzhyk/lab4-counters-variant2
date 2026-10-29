(* Самостійне завдання. Запускати як окрему циклічну програму.
   Cscape: VAR - таблиця змінних; тіло - ST-блок.
   5 деталей у контейнері, 3 контейнери за зміну, пауза 3000 мс. *)
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

(* Під час паузи та після завершення зміни деталі не рахуються. *)
motorRunning := runRequested AND NOT pauseActive
                AND NOT shiftComplete AND NOT resetAll
                AND NOT stopConveyor;
counter1(sensorEdge.Q AND motorRunning, resetParts, 5);

(* Тривале Q першого лічильника дає лише один контейнер. *)
containerEdge(counter1.Q);
counter2(containerEdge.Q AND NOT resetAll, resetAll, 3);
currentParts := counter1.CV;
currentContainers := counter2.CV;
shiftComplete := counter2.Q;

IF containerEdge.Q AND NOT shiftComplete AND NOT resetAll THEN
    pauseActive := TRUE;
END_IF;

(* TON1ms має числовий PT у мілісекундах. *)
pauseTimer(pauseActive AND NOT resetAll, 3000);
IF pauseTimer.Q THEN
    pauseActive := FALSE;
    resetPartsNext := TRUE;
END_IF;

IF shiftComplete THEN
    runRequested := FALSE;
    pauseActive := FALSE;
END_IF;

(* Не дозволяємо рух до скидання першого лічильника. *)
motorRunning := runRequested AND NOT pauseActive
                AND NOT shiftComplete AND NOT resetAll
                AND NOT stopConveyor AND NOT resetPartsNext;
initialized := TRUE;
END_PROGRAM
