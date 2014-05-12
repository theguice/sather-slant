int incomingByte = 0;   // for incoming serial data
int r1 = 13;
int r2 = 12;
int r3 = 11;

// the setup routine runs once when you press reset:
void setup() {                

  flip_r1(0);
  flip_r2(0);
  flip_r3(0);

  // initialize the digital pin as an output.
  pinMode(r1, OUTPUT);
  pinMode(r2, OUTPUT);
  pinMode(r3, OUTPUT);
  
  Serial.begin(9600);
}


void loop() {
  
  if (Serial.available() > 0) {
    
    /* Blobs moving left and right incoming on serial */
    incomingByte = Serial.read();
    // say what you got:
    //Serial.println(incomingByte, DEC);
    
    if (incomingByte == 2) {
      Serial.println("F");
      forward();
      delay(1000);
      flip_r1(0);
    } else if (incomingByte == 1) {
      Serial.println("R");
      reverse();
      delay(1000);
      flip_r1(0);
    } else if (incomingByte == 'r') {
      Serial.println("R");
      forward();
      delay(1000);
      flip_r1(0);
    } else if (incomingByte == 'f') {
      Serial.println("F");
      reverse();
      delay(1000);
      flip_r1(0);
    } else {
      Serial.println("N");
    }
    
    /*  MANUAL KEYBOARD CONTROL 
    char inChar = Serial.read();
    // Type the next ASCII value from what you received:
    if (inChar == 'f') {
      Serial.println("Switching Relays");
      forward();
      Serial.println("Motor Direction: Forward");
    } else if (inChar == 'r') {
      Serial.println("Switching Relays");
      reverse();
      Serial.println("Motor Direction: Reverse");
    } else if (inChar == '1') {
      flip_r1(0);
      Serial.println("Motor Stopped");
    } else {
      Serial.println("Commands: f = forward, r = reverse, 1=stop");
    }*/
  }
}

void flip_r1(int state) {
  if (state == 1) {
    digitalWrite(r1, HIGH);
  } else {
    digitalWrite(r1, LOW);
  }
}
void flip_r2(int state) {
  if (state == 1) {
    digitalWrite(r2, HIGH);
  } else {
    digitalWrite(r2, LOW);
  }
}
void flip_r3(int state) {
  if (state == 1) {
    digitalWrite(r3, HIGH);
  } else {
    digitalWrite(r3, LOW);
  }
}
void forward() {
  // cut power at main gate relay
  flip_r1(0);
  delay(500);
  // align relays
  flip_r2(0);
  flip_r3(0);
  delay(500);
  // turn on power from main gate relay
  flip_r1(1);
  delay(200);
}
void reverse() {
  // cut power at main gate relay
  flip_r1(0);
  delay(500);
  // align relays
  flip_r2(1);
  flip_r3(1);
  delay(500);
  // turn on power from main gate relay
  flip_r1(1);
  delay(200);
}


/*
    // Type the next ASCII value from what you received:
    if (inChar == '1') {
      Serial.println("Relay 1: On"); 
      flip_r1(1);
    } else if (inChar == '2') {
      Serial.println("Relay 1: Off"); 
      flip_r1(0);
    } else if (inChar == '3') {
      Serial.println("Relay 2: On"); 
      flip_r2(1);
    } else if (inChar == '4') {
      Serial.println("Relay 2: Off"); 
      flip_r2(0);
    } else if (inChar == '5') {
      Serial.println("Relay 3: On"); 
      flip_r3(1);
    } else if (inChar == '6') {
      Serial.println("Relay 3: Off"); 
      flip_r3(0);
    } else {
      Serial.println("Commands: 1-relay1on, 2-relay1off, 3-relay2on");
    }

*/

