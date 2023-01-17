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

[false, true, false, false];
x = [2, 12, 2, 3]
x = x.insert(0,100)
x

(
x = Routine {
	var pitch = \c5;
	var dict = p.mf;
	8.do{|id|
		f.playPitch(id, pitch, dict);
		if(id > 0, {
			m.lcSetToggleLights(id-1, \off);
			f.setFanOnOff(id-1, \off);
		});
		5.wait;
	};
}.play;
)
x.stop;

f.playChord([\e6], p.mf, \sort);
f.playChord([\g4, \gs4], p.mp, \rand);
f.playChord([\g4, \gs4, \a4], p.mp, \rand);
f.playChord([\g4, \gs4, \a4, \as4], p.mp, \rand);
f.playChord([\g4, \gs4, \a4, \as4, \b4], p.mp, \rand);
f.playChord([\g4, \gs4, \a4, \as4, \b4, \c5], p.mp, \rand);

y = 55;
x = if((y >= 55) && (y <= 76), {0},{1});
x.do{|item, index| [item, index].postln}
27.linlin(0,127,-1.0,1.0)

(
var id = 3, val = -1;
((id.mod(2) - 0.5) * val * 254).asInteger;
)

-3.abs.neg

f.changeStepperSpeed(106);
8.do{|id| f.setStepperPos(id, 0) };
8.do{|id| f.setStepperPos(id, 20) };



