a.sendVal(0, 200); // stepper position
a.sendVal(20, 0); // air speed
a.sendVal(10, 255); // stepper speed

a.sendVal(9, 0); // re-calibrate motor pos


(
var val = 0;
a.sendVal(0, val); // stepper position
a.sendVal(20, val); // air speed
)