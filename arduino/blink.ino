#define LED (*(volatile uint32_t*)0x02000000)
int ledState = 0;
int previousMillis = 0;
const long interval = 100000;

void setup() { LED = 0xFF; }

void loop()
{
static int currentMillis = 0;
currentMillis++;
if (currentMillis - previousMillis >= interval)
  {
    previousMillis = currentMillis;
    if (ledState == 0) ledState = 0x0F;
    else ledState = ledState / 2;
    LED = ledState;
  }
}
