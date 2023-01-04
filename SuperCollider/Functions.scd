(
// pitch arrays
var ppp = [[110,0],[110,11],[110,30],[120,20],[120,40],[120,60],[125,65],[130,67],[135,70],[140,82],[145,85],[150,90],[160,105],
	[160,118],[165,125],[166,140],[170,150],[180,150],[190,150],[195,160],[200,170],[210,175],[220,185],[230,180],[230,200],[240,210]];
var fanVel = Array.fill(8, {0});
var fanVelRndMinMax = Array.fill(8, {0}); // [min, max] for each flute
var fanVelRnd = Array.fill(8, {0});

// midi init --------------------------------------------------
MIDIClient.init;
MIDIIn.connectAll;

f = (); // create empty event for functions

f.fanOnOff = Array.fill(8,{false});
f.setStepperPosRout = Array.fill(8, {nil});

f.setStepperPos = { // id must be 0-7 and val 0-255
	arg self, id, val;
	if( f.setStepperPosRout[id] != nil, {
		f.setStepperPosRout[id].stop;
		f.setStepperPosRout[id] = nil;
	});
	f.setStepperPosRout[id] = Routine {
		0.05.wait;
		a.sendVal(id, val);
	}.play;
};

f.setFanOnOff = {
	arg self, id, onOff;
	switch( onOff,
		\on, {
			f.fanOnOff[id] = true;
			f.setFanVel(id, nil, \start);
		},
		\off, {
			f.fanOnOff[id] = false;
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
			f.setFanVelRout[id] = Routine {
				a.sendVal(id+20, 255); // air control is 20-27
				0.2.wait;
				a.sendVal(id+20, fanVel[id]); // air control is 20-27
			}.play;
		},
		\stop, {
			a.sendVal(id+20, 0);
		},
		{ // default
			f.setFanVelRout[id] = Routine {
				0.05.wait;
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
x = [1,2,3];
x.do{|i, index|
	i.postln;
};
