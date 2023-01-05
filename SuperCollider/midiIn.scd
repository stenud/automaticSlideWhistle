(
MIDIClient.init;
MIDIIn.connectAll;
)

MIDIdef.freeAll;

MIDIFunc.trace(false);

(
m = (); // create empty event for midi
m.input = {
	MIDIdef.freeAll;
	MIDIdef.cc(\input, {
		arg val, num, chan, src;
		case // independent of channel / user template
		{num == 77} // send select (up)
		{
			if(val == 127, {
				f.setFanVelRnd(\start);
				m.launchControlLights(44, 15, 0); // 62 = yellow
				m.launchControlLights(44, 15, 1); // 60 = green
				2.do {|template| // do for both first and second user template
					m.launchControlToggle(20, 127, template); // toggle off for bottom button
				};
			}, {
				f.setFanVelRnd(\stop);
				2.do {|template| // do for both first and second user template
					m.launchControlLights(44, 12, template);
					m.launchControlToggle(20, 0, template); // toggle off for bottom button
				};
			});
		}
		{num == 78} // send select (down)
		{
			if(val == 127, {
				f.setStepperPosRnd(\start);
				m.launchControlLights(45, 15, 0); // 62 = yellow
				m.launchControlLights(45, 15, 1); // 60 = green
				2.do {|template| // do for both first and second user template
					m.launchControlToggle(21, 127, template); // toggle off for bottom button
				};
			}, {
				f.setStepperPosRnd(\stop);
				2.do {|template| // do for both first and second user template
					m.launchControlLights(45, 12, template);
					m.launchControlToggle(21, 0, template); // toggle off for bottom button
				};
			});
		}
		{(num >= 21) && (num <= 28)}
		{
			var id = num - 21;
			if(val == 127, {
				f.setFanOnOff(id, \on);
				m.launchControlLights(id+24, 62, 0); // index 24-31, 62 = yellow
				m.launchControlLights(id+24, 60, 1); // index 24-31, 60 = green
			},{
				f.setFanOnOff(id, \off);
				2.do {|template| // do for both first and second user template
					m.launchControlLights(id+24, 12, template); // index 24-31
					m.launchControlToggle(id+8, 0, template); // toggle off for bottom button, index 8-15
					m.launchControlLights(id+32, 12, template); // toggle off for bottom button, index 32-39
				};
			})
		}
		{(num >= 11) && (num <= 18)}
		{
			var id = num - 11;
			if(val == 127, {
				f.setFanOnOff(id, \on);
				m.launchControlLights(id+32, 62, 0);
				m.launchControlLights(id+32, 60, 1);
				2.do {|template| // do for both first and second user template
					m.launchControlToggle(id+8, 127, template); // toggle off for bottom button, index 8-15
				};
			},{
				f.setFanOnOff(id, \off);
				2.do {|template| // do for both first and second user template
					m.launchControlLights(id+32, 12, template);
					m.launchControlToggle(id+8, 0, template); // toggle off for bottom button, index 8-15
				};
			})
		}
		{num == 74} {a.sendVal(9, 0)}; // re-calibrate motor pos

		switch( chan,
			0, {
				switch( num,
					61, {
						8.do {|id|
							if(f.fanOnOff[id], {
								f.setFanVel(id, val.linlin(0,127,0,255).asInteger);
							}, {
								f.setFanVelSilent(id, val.linlin(0,127,0,255).asInteger);
							});
						};
					},
					51, {
						8.do {|id|
							f.setVelRndMinMax(id, val.linlin(0,127,0,127) ).asInteger;
						};
					},
					41, {
						8.do {|id|
							f.setStepperPosRndMinMax(id, val.linlin(0,127,0,127) ).asInteger;
						};
					},
					31, {
						8.do {|id|
							f.setStepperPos( id, val.linlin(0,127,0,255).asInteger )
						};
					},
				);
			},
			1, {
				case
				{(num >= 61) && (num <= 68)}
				{
					var id = num - 61;
					if(f.fanOnOff[id], {
						f.setFanVel(id, val.linlin(0,127,0,255).asInteger);
					}, {
						f.setFanVelSilent(id, val.linlin(0,127,0,255).asInteger);
					});
				}
				{(num >= 51) && (num <= 58)}
				{
					var id = num - 51;
					f.setVelRndMinMax(id, val.linlin(0,127,0,127) ).asInteger;
				}
				{(num >= 41) && (num <= 48)}
				{
					var id = num - 41;
					f.setStepperPosRndMinMax(id, val.linlin(0,127,0,127) ).asInteger;
				}
				{(num >= 31) && (num <= 38)}
				{
					var id = num - 31;
					f.setStepperPos( id, val.linlin(0,127,0,255).asInteger )
				};
			},
		);

	});
};

m.lcSysex = MIDIOut.newByName("Launch Control XL", "Launch Control XL");

m.launchControlLights = { // update fixed color
	arg self, index, val, template;
	m.lcSysex.sysex(Int8Array[ 240, 0, 32, 41, 2, 17, 120, template, index, val, 247 ]);
};

m.launchControlToggle = { // change toggle state (where applicable)
	arg self, index, val, template; // val 0 or 127
	m.lcSysex.sysex(Int8Array[ 240, 0, 32, 41, 2, 17, 123, template, index, val, 247 ]);
};

m.input;
)











