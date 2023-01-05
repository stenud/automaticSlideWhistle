a.sendVal(0, 200); // stepper position
a.sendVal(20, 0); // air speed
a.sendVal(10, 255); // stepper speed

a.sendVal(9, 0); // re-calibrate motor pos


(
var val = 0;
a.sendVal(0, val); // stepper position
a.sendVal(20, val); // air speed
)

f.setFanVelRnd(\start);
f.setFanVelRnd(\stop);

f.setStepperPosRnd(\start);
f.setStepperPosRnd(\stop);

(
8.do {|id|
	f.setStepperPos( id, 0 )
};
)

(
8.do {|id|
	f.setFanVel(id, 96);
}
)

(
// y = [10, 33, 54, 75, 93, 111, 128, 144, 160, 177, 198];
y = [10, 54, 93, 111, 144];
y = y.scramble;
x = Routine {
	loop {
		y.do {|pitch|
			8.do {|id|
				f.setStepperPos( id, pitch );
			};
			pitch.postln;
			5.wait;
		};
	};
}.play;
)
x.stop