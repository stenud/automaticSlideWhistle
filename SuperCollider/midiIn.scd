(
MIDIClient.init;
MIDIIn.connectAll;
)

MIDIdef.freeAll;

MIDIFunc.trace(false);

);

m.pitchDict = p.mp;
m.sort = \rand;

(
var voiceArr = Array.series(8);
var voiceArrPtr = Array.series(8);
var keyArr = Array.fill(127, {false});

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

m.input = {
	MIDIdef.freeAll;
	MIDIdef.noteOn(\noteOn, {
		arg val, num, chan, src;
		switch( chan,
			0, {
				switch( num,
					55, { m.polyKey(num, \g4, p.pp) },
					56, { m.polyKey(num, \gs4, p.pp) },
					57, { m.polyKey(num, \a4, m.pitchDict) },
					58, { m.polyKey(num, \as4, m.pitchDict) },
					59, { m.polyKey(num, \b4, m.pitchDict) },
					60, { m.polyKey(num, \c5, m.pitchDict) },
					61, { m.polyKey(num, \cs5, m.pitchDict) },
					62, { m.polyKey(num, \d5, m.pitchDict) },
					63, { m.polyKey(num, \ds5, m.pitchDict) },
					64, { m.polyKey(num, \e5, m.pitchDict) },
					65, { m.polyKey(num, \f5, m.pitchDict) },
					66, { m.polyKey(num, \fs5, m.pitchDict) },
					67, { m.polyKey(num, \g5, m.pitchDict) },
					68, { m.polyKey(num, \gs5, m.pitchDict) },
					69, { m.polyKey(num, \a5, p.harm) },
					70, { m.polyKey(num, \as5, p.harm) },
					71, { m.polyKey(num, \b5, p.harm) },
					72, { m.polyKey(num, \c6, p.harm) },
					73, { m.polyKey(num, \cs6, p.harm) },
					74, { m.polyKey(num, \d6, p.harm) },
					75, { m.polyKey(num, \ds6, p.harm) },
					76, { m.polyKey(num, \e6, p.harm) },
				);
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
		});
	});
	MIDIdef.noteOff(\noteOff, {
		arg val, num, chan, src;
		switch( chan,
			0, { m.polyKeyUpp(num) },
			1,
			{

		});
	});

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











