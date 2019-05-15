# Heating knob turner

I live in an apartment  where I have no thermostat to regulate the temperature.
The temperature is regulated by manually adjusting the heat by turning the knob of a heater. This process can be automated by having a device which turns the knob of the heater when the room becomes too warm or too cold.
I know devices like this exist commercially but thought it would be fun to build one myself. I use it to keep my house at a steady temperature and
turn the heat up and down automatically at night and in the morning.

## Features:
Knob turner with serial interface.

<img alt="Turner assembly" src="http://buysdb.nl/projects/knobturner/assembly_knob.jpg" width="456" height="257">
<img alt="Box" src="http://buysdb.nl/projects/knobturner/box.jpg" width="456" height="257">
<img alt="Knob grabber" src="http://buysdb.nl/projects/knobturner/grabber.jpg" width="456" height="257">

## Components
```
1x ESP8266 brainbox
1x DC motor driver to drive the engine
1x INA219 breakout board, to measure the current going through the engine
2x SHT31 breakout board, to measure ambient and heater temperature
2x Banana binding posts and plugs to connect the engine to the box
1x SSD1306 oled screen to show the heater and ambient temperature
1x SG960 servo (modified)
```

## Usage

Raw serial commands:
```
Example:
1000,1,1000,5,500.0,2006\n

power : Value between 0 and 1023, how much do we trottle the turner
timeout  : how long do we turn
current Limiter Amount : how many times are we allowed to exceed the current limit
current limit : current limit in mA
checksum (Sum of all values)
```

Usage of the Python class which interfaces using the serial connection
```
import heatingknobturner
import serial
# Connect to the heating knob turner:
ser = serial.Serial('/dev/ttyUSB1',115200)
# Initialise the heatingknobturner object:
knobTurner = heatingknobturner.HeatingKnobTurner(ser)
knobTurner.tick()
knobTurner.setTemp(21) # The knob turner will try to get the room to 21 degrees
```

## Servo modification
