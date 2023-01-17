(
MIDIClient.init;
MIDIIn.connectAll;
)

MIDIdef.freeAll;

MIDIFunc.trace(true);

);

m.pitchDict = p.mp;
m.sort = \rand;

(
var voiceArr = Array.series(8);
var voiceArrPtr = Array.series(8);
var keyArr = Array.fill(127, {false});
var singleKeyArr = Array.newClear(8);

m = (); // create empty event for midi
m.pitchDict = p.mf;
m.sort = \sort;
m.numVoices = 8;

m.polyKey = {
	arg self, num, pitchSymb, pitchDict;
	var voice;
	voice = voiceArr[voiceArrPtr[0]];
	keyArr = keyArr.replace(voice, false);
	keyArr[num] = voice;
	f.playPitch(voice, pitchSymb, pitchDict);
	voiceArrPtr = voiceArrPtr.rotate(-1);
};

m.polyKeyUpp = {
	arg self, num;
	var voice, removeIndex;
	if( keyArr[num] != false, {
		voice = keyArr[num];
		m.lcSetToggleLights(voice, \off);
		f.setFanOnOff(voice, \off);
		voiceArrPtr = voiceArrPtr.insert(0, voice);
		voiceArrPtr.do{|item, index|
			if( (index != 0) && (item == voice), {
				removeIndex = index;
			});
		};
		voiceArrPtr.removeAt(removeIndex);
	});
};

m.singleKey = {
	arg self, voice, num, pitchSymb, pitchDict;
	f.playPitch(voice, pitchSymb, pitchDict);
	singleKeyArr[voice] = num;
};

m.singleKeyUp = {
	arg self, voice, num;
	if( singleKeyArr[voice] == num, {
		f.setFanOnOff(voice, \off);
		singleKeyArr[voice] = nil;
		m.lcSetToggleLights(voice, \off);
	});
};


m.input = {
	MIDIdef.freeAll;
	MIDIdef.noteOn(\noteOn, {
		arg val, num, chan, src;
		switch( chan,
			0, {
				case
				{(num >= 55) && (num <= 76)}
				{
					var pitchIndex = num - 55;
					m.polyKey(num, p.pitchArr[pitchIndex], m.pitchDict);
				}
			},
			1, {
				switch( num,
					67, { f.playChord([\fs5, \g5, \gs5, \a5, \as5, \b5, \c6, \cs6], m.pitchDict, m.sort) },
					66, { f.playChord([\f5, \fs5, \g5, \gs5, \a5, \as5, \b5, \c6], m.pitchDict, m.sort) },
					65, { f.playChord([\e5, \f5, \fs5, \g5, \gs5, \a5, \as5, \b5], m.pitchDict, m.sort) },
					64, { f.playChord([\ds5, \e5, \f5, \fs5, \g5, \gs5, \a5, \as5], m.pitchDict, m.sort) },
					63, { f.playChord([\d5, \ds5, \e5, \f5, \fs5, \g5, \gs5, \a5], m.pitchDict, m.sort) },
					62, { f.playChord([\cs5, \d5, \ds5, \e5, \f5, \fs5, \g5, \gs5], m.pitchDict, m.sort) },
					61, { f.playChord([\c5, \cs5, \d5, \ds5, \e5, \f5, \fs5, \g5], m.pitchDict, m.sort) },
					60, { f.playChord([\b4, \c5, \cs5, \d5, \ds5, \e5, \f5, \fs5], m.pitchDict, m.sort) },
					59, { f.playChord([\a4, \b4, \c5, \cs5, \d5, \ds5, \e5, \f5], m.pitchDict, m.sort) },
					58, { f.playChord([\a4, \b4, \c5, \cs5, \d5, \ds5, \e5], m.pitchDict, m.sort) },
					57, { f.playChord([\a4, \b4, \c5, \cs5, \d5, \ds5], m.pitchDict, m.sort) },
					56, { f.playChord([\a4, \b4, \c5, \cs5, \d5], m.pitchDict, m.sort) },
					55, { f.playChord([\a4, \b4, \c5, \cs5], m.pitchDict, m.sort) },
					54, { f.playChord([\a4, \b4, \c5], m.pitchDict, m.sort) },
					53, { f.playChord([\a4, \b4], m.pitchDict, m.sort) },
					52, { f.playChord([\a4], m.pitchDict, m.sort) },
				);
			},
			2, {
				case
				{(num >= 31) && (num <= 52)}
				{
					var pitchIndex = num - 31;
					m.singleKey(0, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
				{(num >= 55) && (num <=76)}
				{
					var pitchIndex = num - 55;
					m.singleKey(1, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
			},
			3, {
				case
				{(num >= 31) && (num <= 52)}
				{
					var pitchIndex = num - 31;
					m.singleKey(2, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
				{(num >= 55) && (num <=76)}
				{
					var pitchIndex = num - 55;
					m.singleKey(3, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
			},
			4, {
				case
				{(num >= 31) && (num <= 52)}
				{
					var pitchIndex = num - 31;
					m.singleKey(4, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
				{(num >= 55) && (num <=76)}
				{
					var pitchIndex = num - 55;
					m.singleKey(5, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
			},
			5, {
				case
				{(num >= 31) && (num <= 52)}
				{
					var pitchIndex = num - 31;
					m.singleKey(6, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
				{(num >= 55) && (num <=76)}
				{
					var pitchIndex = num - 55;
					m.singleKey(7, num, p.pitchArr[pitchIndex], m.pitchDict);
				}
			},
		);
	});
	MIDIdef.noteOff(\noteOff, {
		arg val, num, chan, src;
		switch( chan,
			0, { m.polyKeyUpp(num) },
			2, {
				var voice = if((num >= 31) && (num <= 52), {0}, {1});
				m.singleKeyUp( voice, num)
			},
			3, {
				var voice = if((num >= 31) && (num <= 52), {2}, {3});
				m.singleKeyUp( voice, num)
			},
			4, {
				var voice = if((num >= 31) && (num <= 52), {4}, {5});
				m.singleKeyUp( voice, num)
			},
			5, {
				var voice = if((num >= 31) && (num <= 52), {6}, {7});
				m.singleKeyUp( voice, num)
			},
		);
	});

	MIDIdef.cc(\input, {
		arg val, num, chan, src;
		case // independent of channel / user template
		{num == 77} // send select (up)
		{
			if(val == 127, {
				f.setFanVelRnd(\start);
				2.do {|template| // do for both first and second user template
					m.launchControlLights(44, 15, template); // 15 = red
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
				2.do {|template| // do for both first and second user template
					m.launchControlLights(45, 15, template); // 15 = red
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
		{num == 76} // track select (=>)
		{
			if(val == 127, {
				f.stepperPosRndInclSilent = true;
				2.do {|template| // do for both first and second user template
					m.launchControlLights(47, 15, template); // 15 = red
					m.launchControlToggle(23, 127, template); // toggle off for bottom button
				};
			}, {
				f.stepperPosRndInclSilent = false;
				2.do {|template| // do for both first and second user template
					m.launchControlLights(47, 12, template);
					m.launchControlToggle(23, 0, template); // toggle off for bottom button
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
				m.lcSetToggleLights(id, \on);
			}, {
				f.setFanOnOff(id, \off);
				m.lcSetToggleLights(id, \off);
			});
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

m.lcSetToggleLights = {
	arg self, id, onOff;
	switch( onOff,
		\on, {
			m.launchControlLights(id+32, 62, 0);
			m.launchControlLights(id+32, 60, 1);
			2.do {|template| // do for both first and second user template
				m.launchControlToggle(id+8, 127, template); // toggle off for bottom button, index 8-15
			};
		},
		\off, {
			2.do {|template| // do for both first and second user template
				m.launchControlLights(id+32, 12, template);
				m.launchControlToggle(id+8, 0, template); // toggle off for bottom button, index 8-15
			};
		},
	);
};

m.input;
)











