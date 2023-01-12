(
var fanVel = Array.fill(8, {0});
var fanVelRndMinMax = Array.fill(8, {0});
var fanVelRnd = Array.fill(8, {0});
var stepperPos = Array.fill(8, {0});
var stepperPosRndMinMax = Array.fill(8, {0});
var stepperPosRnd = Array.fill(8, {0});

f = (); // create empty event for functions

f.playPitch = {
	arg self, id, pitchSymb, dict;
	var pitch = dict.at(pitchSymb), start = nil;
	if( f.fanOnOff[id].not, {
		start = \start;
		m.launchControlLights(id+32, 62, 0);
		m.launchControlLights(id+32, 60, 1);
		2.do {|template| // do for both first and second user template
			m.launchControlToggle(id+8, 127, template); // toggle off for bottom button, index 8-15
		};
	});
	f.setStepperPos(id, pitch[1]);
	f.setFanVel(id, pitch[0], start);
};

f.play8Pitches = {
	arg self, pitches, dict; // pitches is an array with 8 pitch symbols
	pitches.do{|pitch, index|
		f.playPitch(index, pitch, dict);
	};
};

f.playChord = {
	arg self, pitches, dict, order = \rand;
	var numPitches, playArr = [], div, mod;

	numPitches = pitches.size;
	div = 8.div(numPitches);
	mod = 8.mod(numPitches);

	pitches.do{|pitch, index|
		var fill = 0;
		if( mod > 0, {
			fill = 1;
			mod = mod - 1;
		});
		(div+fill).do {|id|
			playArr = playArr.add(pitch);
		};
	};

	switch( order,
		\rand, { playArr = playArr.scramble },
		\sort, {}, //already sorted,
		\rev, { playArr = playArr.reverse },
	);

	f.play8Pitches(playArr, dict);
};

f.fanOnOff = Array.fill(8,{false});
f.setStepperPosRout = Array.fill(8, {nil});

f.setStepperPos = { // id must be 0-7 and val 0-255
	arg self, id, val;
	if(val != nil, {
		if(val > stepperPos[id], {
			stepperPos[id] = (val - 3).max(0); // move slightly further if coming from above
		}, {
			stepperPos[id] = val;
		});
	});
	if( f.setStepperPosRout[id] != nil, {
		f.setStepperPosRout[id].stop;
		f.setStepperPosRout[id] = nil;
	});
	f.setStepperPosRout[id] = Routine {
		0.05.wait;
		a.sendVal(id, (stepperPos[id] + stepperPosRnd[id]).max(0).min(255).asInteger );
	}.play;
};

f.stepperPosRndRout = nil;

f.setStepperPosRnd = {
	arg self, startStop;
	switch( startStop,
		\start, {
			var order = Array.series(8,0);
			if( f.stepperPosRndRout != nil, { // in case it is already running
				f.stepperPosRndRout.stop;
				f.stepperPosRndRout = nil;
			});
			f.stepperPosRndRout = Routine {
				loop {
					order = order.scramble;
					order.do{|id|
						if(f.fanOnOff[id], {
							rrand(0.1, 0.5).wait;
							if(f.fanOnOff[id], {
								stepperPosRnd[id] = rrand( stepperPosRndMinMax[id].neg, stepperPosRndMinMax[id] ).asInteger;
								f.setStepperPos(id);
								// format( "%: %", id, stepperPosRnd[id] ).postln;
							});
						});
					};
					0.1.wait;
				};
			}.play;
		},
		\stop, {
			if( f.stepperPosRndRout != nil, {
				f.stepperPosRndRout.stop;
				f.stepperPosRndRout = nil;
			});
			8.do{|id| stepperPosRnd[id] = 0 };
		},
	);
};

f.setStepperPosRndMinMax = {
	arg self, id, val;
	stepperPosRndMinMax[id] = val;
};


f.setFanOnOff = {
	arg self, id, onOff;
	switch( onOff,
		\on, {
			f.setFanVel(id, nil, \start);
		},
		\off, {
			f.setFanVel(id, nil, \stop);
		},
	);
};

f.setFanVelRout = Array.fill(8, {nil});

f.setFanVel = { // id must be 0-7 and val 0-255
	arg self, id, val, startStop = nil;
	if(val != nil, {fanVel[id] = val});
	if( f.setFanVelRout[id] != nil, {
		f.setFanVelRout[id].stop;
		f.setFanVelRout[id] = nil;
	});
	switch( startStop,
		\start, {
			f.fanOnOff[id] = true;
			f.setFanVelRout[id] = Routine {
				a.sendVal(id+20, 255); // air control is 20-27
				0.5.wait;
				a.sendVal(id+20, fanVel[id]); // air control is 20-27
			}.play;
		},
		\stop, {
			f.fanOnOff[id] = false;
			a.sendVal(id+20, 0);
		},
		{ // default
			f.setFanVelRout[id] = Routine {
				0.02.wait;
				a.sendVal(id+20, (fanVel[id] + fanVelRnd[id]).max(0).min(255).asInteger ); // air control is 20-27
				//format( "%: %", id, (fanVel[id] + fanVelRnd[id]).max(0).min(255) ).postln;
			}.play;
		},
	)
};

f.setFanVelSilent = {
	arg self, id, val;
	fanVel[id] = val;
};


f.fanVelRndRout = nil;
f.setFanVelRnd = {
	arg self, startStop;
	switch( startStop,
		\start, {
			var order = Array.series(8,0);
			if( f.fanVelRndRout != nil, { // in case it is already running
				f.fanVelRndRout.stop;
				f.fanVelRndRout = nil;
			});
			f.fanVelRndRout = Routine {
				loop {
					order = order.scramble;
					order.do{|id|
						if(f.fanOnOff[id], {
							rrand(0.1, 0.5).wait;
							if(f.fanOnOff[id], {
								fanVelRnd[id] = rrand( fanVelRndMinMax[id].neg, fanVelRndMinMax[id] ).asInteger;
								f.setFanVel(id);
								// format( "%: %", id, fanVelRnd[id] ).postln;
							});
						});
					};
					0.1.wait;
				};
			}.play;
		},
		\stop, {
			if( f.fanVelRndRout != nil, {
				f.fanVelRndRout.stop;
				f.fanVelRndRout = nil;
			});
			8.do{|id| fanVelRnd[id] = 0 };
		},
	);
};

f.setVelRndMinMax = {
	arg self, id, val;
	fanVelRndMinMax[id] = val;
};



)