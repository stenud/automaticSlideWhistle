SerialPort.devices; //returns an array of available device.

( //WHEN ADDRESS BELOW IS CORRECT: RUN THIS BLOCK OF CODE
a = (); // create empty event for arduino control

a.port = SerialPort(
	"/dev/cu.usbmodem11401", //CHANGE TO CORRECT ADDRESS. RUN "SerialPort.devices" ABOVE TO FIND THE ADDRESS.
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









