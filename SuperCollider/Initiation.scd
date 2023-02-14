//0. check devices
ServerOptions.devices;

//1. Server config and open documents
(
var openDocs = {
	//Öppna alla som dokument, stäng sedan detta dokument
	var docs = Array.newClear(8);
	var path = PathName(thisProcess.nowExecutingPath).parentPath;
	path.postln;

	docs[0] = Document.current;
	docs[1] = Document.open(path +/+ "ArduinoCommunication.scd");
	docs[2] = Document.open(path +/+ "Functions.scd");
	docs[3] = Document.open(path +/+ "Pitches.scd");
	docs[4] = Document.open(path +/+ "Playground.scd");
	docs[5] = Document.open(path +/+ "Modules.scd");
	docs[6] = Document.open(path +/+ "Composition.scd");
	docs[7] = Document.open(path +/+ "MidiIn.scd");

	docs[1].front;
	docs[0].close;
}.value;


// s.options.outDevice = "Built-in Output"; //select audio device
s.options.numOutputBusChannels_(2); //set number of out channels
s.options.sampleRate_(44100); // set sample rate
s.options.memSize_(2.pow(20)); //set max memory use (about 1 GB = a lot!!)
s.boot;
openDocs.();
)