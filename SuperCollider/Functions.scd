(
var fanVel = Array.fill(8, {0});
var fanVelRndMinMax = Array.fill(8, {0});
var fanVelRnd = Array.fill(8, {0});
var stepperPos = Array.fill(8, {0});
var stepperPosRndMinMax = Array.fill(8, {0});
var stepperPosRnd = Array.fill(8, {0});
var stepperTilt = false;
var stepperTiltVals = Array.fill(8, {1.0});

f = (); // create empty event for functions

f.playPitch = {
	arg self, id, pitchSymb, dict;
	var pitch = dict.at(pitchSymb), start = nil;
	if( f.fanOnOff[id].not, {
		start = \start;
		m.lcSetToggleLights(id, \on);
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

f.playTempo = 240/60;

f.playSeq = {
	arg self, id, pitchDict, pitchSymbs, noteVals;
	{
		pitchSymbs.do{|note, index|
			if( note != nil, { f.playPitch(id, note, pitchDict) });
			(noteVals[index] * f.playTempo).wait;
			if( note != nil, {
				f.setFanOnOff(id, \off);
				m.lcSetToggleLights(id, \off);
			});
		};
	}.fork;
};

f.playChord = { // spreads a pitch array of up to 8 notes on all flutes
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
		if(val < stepperPos[id], {
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
		if( stepperTilt.not, {
			a.sendVal(id, (stepperPos[id] + stepperPosRnd[id]).max(0).min(255).asInteger );
		}, {
			a.sendVal(id, ((stepperPos[id] + stepperTiltVals[id]).max(0).min(255) + stepperPosRnd[id]).max(0).min(255).asInteger );
		});
	}.play;
};

f.setStepperTilt = {
	arg self, tiltOption, val;
	8.do{|id|
		switch(tiltOption,
			\lin, { // / \
				stepperTiltVals[id] = ((id-3.5) * val * 36.2858).asInteger;
				f.setStepperPos(id);
				stepperTilt = true;
			},
			\peak, { // ^
				stepperTiltVals[id] = ( ((id-3.5).abs.neg + 1.75) * val * 72.5715 ).asInteger;
				f.setStepperPos(id);
				stepperTilt = true;
			},
			\zigzag, { // _-_-_-_-
				stepperTiltVals[id] = ( (id.mod(2) - 0.5) * val * 254 ).asInteger;
				f.setStepperPos(id);
				stepperTilt = true;
			},
			\off, { stepperTilt = false },
		);
	};
};

f.stepperPosRndRout = nil;
f.stepperPosRndInclSilent = false;

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
					if( f.stepperPosRndInclSilent.not, {
						order.do{|id|
							if(f.fanOnOff[id], {
								rrand(0.1, 0.5).wait;
								stepperPosRnd[id] = rrand( stepperPosRndMinMax[id].neg, stepperPosRndMinMax[id] ).asInteger;
								f.setStepperPos(id);
							});
						};
					}, {
						order.do{|id|
							rrand(0.1, 0.5).wait;
							stepperPosRnd[id] = rrand( stepperPosRndMinMax[id].neg, stepperPosRndMinMax[id] ).asInteger;
							f.setStepperPos(id);
						};
					});

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

f.changeStepperSpeedRout = Array.newClear(8);

f.changeStepperSpeed = {
	arg self, val, id = nil, noDelay = false; // val: 0-255
	if(id == nil, {
		8.do{|id|
			if( f.changeStepperSpeedRout[id] != nil, { // in case it is already running
				f.changeStepperSpeedRout[id].stop;
				f.changeStepperSpeedRout[id] = nil;
			});
			f.changeStepperSpeedRout[id] = Routine {
				if( noDelay.not, {0.2.wait});
				a.sendVal(id+10, val); // speed control: 10-17
			}.play;
		};
	}, {
		if( f.changeStepperSpeedRout[id] != nil, { // in case it is already running
			f.changeStepperSpeedRout[id].stop;
			f.changeStepperSpeedRout[id] = nil;
		});
		f.changeStepperSpeedRout[id] = Routine {
			if( noDelay.not, {0.2.wait});
			a.sendVal(id+10, val); // speed control: 10-17
		}.play;
	});
};

f.stepperPitch = {
	arg self, id, pitchSymb, dur;
	var steps, speed, currentPos, val;
	speed = p.stepper.at(pitchSymb);
	f.changeStepperSpeed(speed, id, true);
	steps = (dur * speed * 0.26144).asInteger;
	currentPos = stepperPos[id];

	case
	{(steps < currentPos) && (steps < (255-currentPos))}
	{
		val = if(currentPos < 128, {currentPos - steps}, {currentPos + steps});
		f.setStepperPos(id, val);
	}
	{ steps < currentPos }
	{
		val = (currentPos - steps);
		f.setStepperPos(id, val);
	}
	{ steps < (255-currentPos) }
	{
		val = (currentPos + steps);
		f.setStepperPos(id, val);
	}
	{ true } //default, if steps don't fit in any direction
	{
		val = if(currentPos < 128, {255 - currentPos}, {steps - currentPos});
		f.setStepperPos(id, val);
	};
};

f.playTempo = 240/60;

f.stepperPlay = {
	arg self, id, pitchSymbs, noteVals;
	{
		pitchSymbs.do{|note, index|
			if( note != nil, { f.stepperPitch(id, note, noteVals[index] * f.playTempo) });
			(noteVals[index] * f.playTempo).wait;
		};
	}.fork;
};

f.multiStepperPlay = {
	arg self, ids, pitchSymbs, noteVals;
	ids.do{|id|
		f.stepperPlay(id, pitchSymbs, noteVals);
	}
};

"functions loaded".postln;

)