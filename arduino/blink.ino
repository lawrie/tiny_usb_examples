#define LED (*(volatile uint32_t*)0x02000000)
#define reg_uart_data (*(volatile uint32_t*)0x02000008)

int ledState = 0;
long  currentMillis, previousMillis = 0;
const long interval = 1000;

void putch(char c) {
  reg_uart_data = c;
}

void print(const char *p) {
  while (*p)
    putch(*(p++));
}

void println(const char *p) {
  print(p);
  putch('\n');
}

#define PIN_LED1 8
#define PIN_LED2 9
#define PIN_BUTTON1 0

void setup() {
  pinMode(PIN_LED1, OUTPUT);
  pinMode(PIN_LED2, OUTPUT);
  pinMode(PIN_BUTTON1, INPUT_PULLUP);
  LED = 0x0;
  println("\nLED blinky");
}

void loop() {
  currentMillis = millis();
  if (currentMillis - previousMillis >= interval) {
    char num[4];
    previousMillis = currentMillis;
    ledState ^= 1;
    LED = ledState;
    sprintf(num, "%d", digitalRead(PIN_BUTTON1));
    print("Buttons: ");
    println(num);
    digitalWrite(PIN_LED1, ledState);
    digitalWrite(PIN_LED2, ledState ^ 1);
  }
}

