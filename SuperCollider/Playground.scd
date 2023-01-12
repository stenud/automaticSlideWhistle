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
	f.setStepperPos( id, 255 )
};
)
f.setFanVel(6, 218);

(
8.do {|id|
	f.setFanVel(id, 180);
}
)

( // random variations within scale/chord
// y = [10, 33, 54, 75, 93, 111, 128, 144, 160, 177, 198];
y = Array.fill(8, {[10, 93, 144]});
x = Array.fill(8, {nil});
8.do {|id|
	x[id] = Routine {
		loop {
			y[id] = y[id].scramble;
			y[id].do {|pitch|
				f.setStepperPos(id, pitch);
				rrand(4.0, 6.0).wait;
			};
		};
	}.play;
};
)
8.do{|id| x[id].stop };

(
// y = [10, 33, 54, 75, 93, 111, 128, 144, 160, 177, 198];
y = [[\a4, \cs5, \e5], [\a4, \d5, \fs5], [\b4, \d5, \e5], [\a4, \cs5, \e5]];
x = Array.fill(8, {nil});
x = Routine {
	loop {
		y.do{|chord|
			8.do{|id|
				var pitch = p.mp.at(chord.choose);
				f.setStepperPos(id, pitch[1]);
				f.setFanVel(id, pitch[0]);
			};
			5.wait;
		};
	};
}.play;
)
x.stop;

p.mf.at(\a4)


(
2.do{|id|
	f.playPitch(id, \d5, p.harm);
	f.playPitch(id+2, \e5, p.harm);
	f.playPitch(id+4, \f5, p.harm);
	f.playPitch(id+6, \g5, p.harm);
}
)

(
8.do{|id|
	f.playPitch(id, \d5, p.harm);
}
)

(
var pitches = [\d5, \e5, \f5, \g5, \a5, \as5, \c6, \d6];
f.playPitch(0, pitches[0], p.harm);
f.playPitch(1, pitches[1], p.harm);
f.playPitch(2, pitches[2], p.harm);
f.playPitch(3, pitches[3], p.harm);
f.playPitch(4, pitches[4], p.harm);
f.playPitch(5, pitches[5], p.harm);
f.playPitch(6, pitches[6], p.harm);
f.playPitch(7, pitches[7], p.harm);
)

(
var pitches = [\a4, \b4, \c5, \d5, \e5, \f5, \g5, \a5];
var dict = p.mp;
f.playPitch(0, pitches[0], dict);
f.playPitch(1, pitches[1], dict);
f.playPitch(2, pitches[2], dict);
f.playPitch(3, pitches[3], dict);
f.playPitch(4, pitches[4], dict);
f.playPitch(5, pitches[5], dict);
f.playPitch(6, pitches[6], p.harm);
f.playPitch(7, pitches[7], p.harm);
)

(
x = Routine {
	loop{
		f.playChord([\b4, \ds5, \fs5], p.mf, \rand);
		(rrand(0.3, 2)).wait;
	}
}.play;
)
x.stop;






