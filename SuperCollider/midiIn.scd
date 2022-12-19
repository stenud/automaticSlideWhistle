(
MIDIClient.init;
MIDIIn.connectAll;
)

MIDIdef.freeAll;

MIDIFunc.trace(false);


// RUN THIS BLOCK OF CODE
(
var fanOnOff = [false,false,false,false,false,false,false,false];

m = (); // create empty event for midi
m.input = {
	MIDIdef.freeAll;
	MIDIdef.cc(\input, {
		arg val, num, chan, src;
		switch(num,
			61,{
				if(fanOnOff[0], {
					f.setFanVel(0, val.linlin(0,127,0,255).asInteger);
				}, {
					f.setFanVelSilent(0, val.linlin(0,127,0,255).asInteger);
			});
			},
			31,{ f.setStepperPos( 0, val.linlin(0,127,0,255).asInteger ) },
			21,{
				if(val == 127, {
					fanOnOff[0] = true;
					f.setFanVel(0);
					m.launchControlLights(24,60);
				},{
					fanOnOff[0] = false;
					a.sendVal(20, 0);
					m.launchControlLights(24,12);
					m.launchControlToggle(8,0); // toggle off for bottom button
					m.launchControlLights(32,12); // toggle off for bottom button
				})
			},
			11,{
				if(val == 127, {
					fanOnOff[0] = true;
					f.setFanVel(0);
					m.launchControlLights(32,60);
				},{
					fanOnOff[0] = false;
					a.sendVal(20, 0);
					m.launchControlLights(32,12);
				})
			},
			74,{a.sendVal(9, 0)}, // re-calibrate motor pos
		);
	});
};

m.lcSysex = MIDIOut.newByName("Launch Control XL", "Launch Control XL");

m.launchControlLights = { // update fixed color
	arg self, index, val;
	var template = 1; // second user template
	m.lcSysex.sysex(Int8Array[ 240, 0, 32, 41, 2, 17, 120, template, index, val, 247 ]);
};

m.launchControlToggle = { // change toggle state (where applicable)
	arg self, index, val; // val 0 or 127
	var template = 1; // second user template
	m.lcSysex.sysex(Int8Array[ 240, 0, 32, 41, 2, 17, 123, template, index, val, 247 ]);
};

m.input;
)











