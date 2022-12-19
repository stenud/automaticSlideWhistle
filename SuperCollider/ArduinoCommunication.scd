SerialPort.devices; //returns an array of available device.

( //WHEN ADDRESS BELOW IS CORRECT: RUN THIS BLOCK OF CODE
a = (); // create empty event for arduino control

a.port = SerialPort(
	"/dev/cu.usbmodem2101", //CHANGE TO CORRECT ADDRESS. RUN "SerialPort.devices" ABOVE TO FIND THE ADDRESS.
	baudrate: 115200,
	crtscts: true; );


a.sendVal = { | self, ctlAndId, value |
	a.port.putAll( format("% %\n", ctlAndId.asInteger, value.asInteger) );
};


"Serial communication initiated!".postln;
)

a.sendVal(0, 200);
a.sendVal(20, 0);
a.sendVal(10, 255);

a.sendVal(9, 0); // re-calibrate motor pos


// ----------------------------------------------------

SerialPort.closeAll;







// receive serial
(
var charArray = [ ];
var getSerial = Routine({
    var ascii;
	var receivedValues = Array.newClear(5);
	{
		ascii = ~port.read;
		ascii.postln;
		/*
		if( ascii.isDecDigit, {charArray = charArray.add(ascii)} );
		if( ascii == $a, {
			receivedValues[0] = charArray.collect(_.digit).convertDigits;
			charArray = [ ];
		});
		if( ascii == $b, {
			receivedValues[1] = charArray.collect(_.digit).convertDigits;
			charArray = [ ];
		});
		if( ascii == $c, {
			receivedValues[2] = charArray.collect(_.digit).convertDigits;
			charArray = [ ];
		});
		if( ascii == $d, {
			receivedValues[3] = charArray.collect(_.digit).convertDigits;
			charArray = [ ];
		});
		if( ascii == $e, {
			receivedValues[4] = charArray.collect(_.digit).convertDigits;
			format("led: %, red: %, green: %, blue: %, white: %", receivedValues[0], receivedValues[1],
				receivedValues[2], receivedValues[3], receivedValues[4]).postln;
			charArray = [ ];
		});
		*/
	}.loop;
}).play;
)

getSerial.stop;










