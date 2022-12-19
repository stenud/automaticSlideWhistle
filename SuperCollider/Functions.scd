(
// pitch arrays
var ppp = [[110,0],[110,11],[110,30],[120,20],[120,40],[120,60],[125,65],[130,67],[135,70],[140,82],[145,85],[150,90],[160,105],
	[160,118],[165,125],[166,140],[170,150],[180,150],[190,150],[195,160],[200,170],[210,175],[220,185],[230,180],[230,200],[240,210]];
var fanVel = [0,0,0,0,0,0,0,0];

// midi init --------------------------------------------------
MIDIClient.init;
MIDIIn.connectAll;

f = (); // create empty event for functions


f.setStepperPos = { // id must be 0-7 and val 0-255
	arg self, id, val;
	f.setStepperPosRout.stop;
	f.setStepperPosRout = Routine {
		0.05.wait;
		a.sendVal(id, val);
	}.play;
};

f.setFanVel = { // id must be 0-7 and val 0-255
	arg self, id, val;
	if(val != nil, {fanVel[id] = val});
	f.setFanVelRout.stop;
	f.setFanVelRout = Routine {
		0.02.wait;
		a.sendVal(id+20, fanVel[id]); // air control is 20-27
	}.play;
};

f.setFanVelSilent = {
	arg self, id, val;
	fanVel[id] = val;
};



)