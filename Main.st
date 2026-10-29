(* ЛР 4. Коржик Борис. Варіант 2. Cscape, Structured Text.
   У Cscape оголошення VAR перенести до таблиці змінних,
   а тіло програми - до циклічного ST-блока Main. *)
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

(* Фронт реального датчика відстежується навіть під час зупинки.
   Тому Пуск при вже активному датчику не створює нову деталь.
   У Cscape CTD не має власного детектора фронту. *)
sensorEdge(sensorPulse);
startEdge(startConveyor);
loadCounter := resetCounter OR NOT initialized;

(* Reset завантажує 20 і залишає двигун вимкненим.
   Stop має пріоритет над Start. Пуск виконується новим натисканням. *)
IF loadCounter OR stopConveyor THEN
    motorRunning := FALSE;
ELSIF startEdge.Q AND NOT batchComplete THEN
    motorRunning := TRUE;
END_IF;

(* CD = один цикл сканування на одну деталь.
   Позиційні параметри CTD: CD, LOAD, PV. *)
partCounter(sensorEdge.Q AND motorRunning AND NOT loadCounter,
            loadCounter, setPoint);
currentCount := partCounter.CV;
processedCount := setPoint - currentCount;
batchComplete := partCounter.Q;

(* На двадцятій деталі зупинка відбувається у цьому ж циклі. *)
IF batchComplete OR stopConveyor OR loadCounter THEN
    motorRunning := FALSE;
END_IF;
initialized := TRUE;
END_PROGRAM
