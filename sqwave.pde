#include <TimerOne.h>
#include <EEPROM.h>

byte uswait = 50;

void setup() {
	Serial.begin(9600);
	byte b = EEPROM.read(0);
	if (b >= 1 && b <= 250) {
		uswait = b;
	}
	Serial.println();
	Serial.print("H.A.C.K. SqWave init: 2 * ");
	Serial.print(uswait, DEC);
	Serial.println(" us periods");
	Serial.print("cmd> ");
	Timer1.initialize(uswait);
	Timer1.pwm(10, 512);
}

int newfreq = 0;

void interpretSerialInput(byte inp) {
	if (inp >= '0' && inp <= '9') {
		newfreq = newfreq * 10 + inp - '0';
		Serial.print(inp);
	} else if (inp == 's') {
		EEPROM.write(0, uswait);
		Serial.println("==> Successfully stored frequency in the EEPROM");
		Serial.print("cmd> ");
	} else if (inp == '\r' || inp == '\n') {
		if (newfreq == 0) {
			Serial.print(inp);
		} else if (newfreq < 4 || newfreq > 1000) {
			Serial.println(" <-- Invalid frequency (must be 4 <= x <= 1000 kHz)");
		} else {
			uswait = 1000 / newfreq;
			Timer1.setPeriod(uswait);
			Timer1.setPwmDuty(10, 512);
			Serial.print(" --> Frequency: ");
			Serial.print(1000 / uswait);
			Serial.print(" kHz (2 * ");
			Serial.print(uswait, DEC);
			Serial.println(" us periods)");
		}
		newfreq = 0;
		Serial.print("cmd> ");
	} else {
		Serial.println();
		Serial.println("H.A.C.K. SqWave :: enter freq (kHz) to set it, 's' to store it in the EEPROM");
		Serial.print("cmd> ");
	}
}

void loop() {
	if (Serial.available()) {
		interpretSerialInput(Serial.read());
	}
}
