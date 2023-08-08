(
SynthDef(\string, {
	arg out = 0, freq, fundDev = 0.99, partialDev = 0.985, attRelTime = 3, partialInvLevel = 3.5, mul = 0.2, pan = 0, gate = 1;
	var sig = 0, env, mod, tempFreq, tempSig;
	env = EnvGen.kr(Env.asr(attRelTime, 1.0, attRelTime, [2,-3.5]), gate, doneAction:2);
	tempFreq = freq * LFNoise1.kr(0.6).range(fundDev, fundDev.reciprocal); //genererar grundton
	7.do{ |i| //antal partialer
		mod = LFNoise1.kr(0.5).range(0.3, 1); // modulerar nivån
		tempSig = BPF.ar(PinkNoise.ar(), (tempFreq * (i+1)) *
			LFNoise1.kr(0.8).range(partialDev, partialDev.reciprocal), 0.001) *100;
		tempSig = tempSig / (i+1).pow(partialInvLevel); //justera volymen där högre partialer får lägre volym
		tempSig = tempSig * mod;
		sig = sig + tempSig;
	};
	sig = Mix(sig) * mul * env;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;

~fluteSynths = Array.newClear(128);

MIDIdef.noteOn(\fluteSimOn, {
	arg val, num, chan, src;
	if(chan == 6, {
		~fluteSynths[num] = Synth(\string, [\freq, num.midicps, \mul, 0.5, \attRelTime, 1]);
	});
});

MIDIdef.noteOff(\fluteSimOff, {
	arg val, num, chan, src;
	if(chan == 6, {
		~fluteSynths[num].set(\gate, 0);
	});
});
)

x = Synth(\string, [\freq, 60.midicps, \mul, 0.5]);
x.set(\gate, 0);