(
MIDIClient.init;
MIDIIn.connectAll;
)

MIDIdef.freeAll;

MIDIFunc.trace(false);

(
var fanOnOff = Array.fill(8,{false});

m = (); // create empty event for midi
m.input = {
	MIDIdef.freeAll;
	MIDIdef.cc(\input, {
		arg val, num, chan, src;
		case
		{(num >= 61) && (num <= 68)}
		{
			var id = num - 61;
			if(fanOnOff[id], {
				f.setFanVel(id, val.linlin(0,127,0,255).asInteger);
			}, {
				f.setFanVelSilent(id, val.linlin(0,127,0,255).asInteger);
			});
		}
		{(num >= 31) && (num <= 38)}
		{
			var id = num - 31;
			f.setStepperPos( id, val.linlin(0,127,0,255).asInteger )
		}
		{(num >= 21) && (num <= 28)}
		{
			var id = num - 21;
			if(val == 127, {
				fanOnOff[id] = true;
				f.setFanVel(id);
				m.launchControlLights(id+24,60); // index 24-31
			},{
				fanOnOff[id] = false;
				a.sendVal(id+20, 0);
				m.launchControlLights(id+24,12); // index 24-31
				m.launchControlToggle(id+8,0); // toggle off for bottom button, index 8-15
				m.launchControlLights(id+32,12); // toggle off for bottom button, index 32-39
			})
		}
		{(num >= 11) && (num <= 18)}
		{
			var id = num - 11;
			if(val == 127, {
				fanOnOff[id] = true;
				f.setFanVel(id);
				m.launchControlLights(id+32,60);
			},{
				fanOnOff[id] = false;
				a.sendVal(id+20, 0);
				m.launchControlLights(id+32,12);
			})
		}
		{num == 74} {a.sendVal(9, 0)}; // re-calibrate motor pos
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











