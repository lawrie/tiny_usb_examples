#define LED (*(volatile uint32_t*)0x02000000)
int ledState = 0;
int previousMillis = 0;
const long interval = 100000;

void setup() { LED = 0x0; }

void loop()
{
static int currentMillis = 0;
currentMillis++;
if (currentMillis - previousMillis >= interval)
  {
    previousMillis = currentMillis;
    ledState ^= 1;
    LED = ledState;
  }
}
