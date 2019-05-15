#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import  collections
import threading
import time
import datetime
class HeatingKnobTurner():

    def __init__(self, serialConnection):
        self.currPos = 0
        self.currCurrent = 0
        self.currPower = 0
        self.currDirection = 0
        self.updateInterval = 15
        self.loglen = 80 # 20 minutes
        self.currTemperatureHeater = collections.deque(maxlen=self.loglen)
        self.currTemperatureAmbient = collections.deque(maxlen=self.loglen)
        self.currHumidityHeater  = collections.deque(maxlen=self.loglen)
        self.currHumidityAmbient  = collections.deque(maxlen=self.loglen)

        self.ser = serialConnection
        self.currentLog = collections.deque(maxlen=1000)
        self.lastUpdate = None
        self.stop = False
        self.targetTemp = None
        self.targetTempUpdateRate = 60*10 # Temperature evaluation every 10 minutes

    def isRising(self):
        pass


    def setTemp(self, t):
        self.targetTemp = t
        self.lastTargetUpdate = None
        self.evalTarget()

    def evalTarget(self):
        now = datetime.datetime.now()
        if self.targetTemp is not None:
            if self.lastTargetUpdate is None or ((now - self.lastTargetUpdate).total_seconds() > self.targetTempUpdateRate):
                print('Evaluation:%s %s %s' % (self.currTemperatureAmbient[-1], self.targetTemp, self.isHeating()))
                # Evaluate Temperature function
                if self.currTemperatureAmbient[-1]>self.targetTemp and self.isHeating():
                    # Try to reduce:
                    self.turn(1500,reverse=True)
                    print('Reducing temperature')
                elif self.currTemperatureAmbient[-1]<(self.targetTemp-0.5) and not self.isHeating():
                    self.turn(1500)
                    print('Increasing temperature')
                else:
                    #Keep heating
                    print('Keeping heating')
                    pass

                self.lastTargetUpdate = datetime.datetime.now()

    def isHeating(self):
        return self.currTemperatureHeater[-1]>35

    def isRunning(self):
        return abs(self.currPower)>0

    def writeCommand(self, power=500, sign=1, t=1000, climitAmount=5, climit=600):
        self.currentLog.clear()
        power = int(power)
        sign = int(sign)
        if sign==0:
            self.currDirection=0
        elif sign==1:
            self.currDirection=1
        t=int(t)
        assert(sign==0 or sign==1 or sign==3)
        climitAmount = int(climitAmount)
        climit = float(climit)
        chk = power + sign + climitAmount +t
        #b= f'{power},{sign},{t},{climitAmount},{climit:.2f},{chk}\n'
        b= '%s,%s,%s,%s,%.2f,%s\n' % (power, sign, t, climitAmount, climit, chk)
        #print(b)
        self.ser.write(bytes(b,'ascii'))

        self.parseIncomingSerdata()

    def parseIncomingSerdata(self, sleep=True):
        if sleep:
            time.sleep(0.01)

        while self.ser.in_waiting>0:
            try:
                line = self.ser.readline().decode('ascii').strip()
            except Exception as e:
                continue


            if line.startswith('EXEC'):
                pass
            elif line.startswith('TEMP'):

                temp, hum = line.split(',')
                try:
                    if line.startswith('TEMPAMB'):
                        self.currTemperatureAmbient.append( float(temp.replace('TEMPAMB:','')))
                        self.currHumidityAmbient.append(  float(hum.replace('HUMAMB:','')))
                    elif line.startswith('TEMPHEAT'):
                        self.currTemperatureHeater.append( float(temp.replace('TEMPHEAT:','')))
                        self.currHumidityHeater.append(  float(hum.replace('HUMHEAT:','')))

                except Exception as e:
                    print(e)
                    continue
            elif 'Current limited'==line:
                self.currCurrent  = 0
                self.currPower = 0
            else:
                try:
                    current = float(line)
                    self.currentLog.append(current)
                    self.currCurrent = current
                except Exception as e:
                    print(e)

    def turn(self, t=5000, reverse=False, power=1023,  climit=1310,climitAmount=4):
        self.writeCommand(t=t,power=power, sign=(reverse), climit=climit,climitAmount=climitAmount )
        time.sleep(0.1)
        while self.isRunning():
            self.parseIncomingSerdata()

    def updateTempHum(self):
        if self.isRunning():
            self.parseIncomingSerdata()
            # Sending a temp request will stop the operation
            return

        self.writeCommand(power=1000,sign=3,climitAmount=1,climit=0, t=0)
        self.parseIncomingSerdata()
        self.lastUpdate = time.time()

    def __repr__(self):
        return ('''
        Heating turner, pos:%s direction:%s
        power:%s current:%s
        ''' % (self.currPos,self.currDirection,self.currPower,self.currCurrent )
        ) + ('' if len(self.currTemperatureHeater)==0 else '''tempH:%s humH:%s
        tempA:%s humA:%s'''%(self.currTemperatureHeater[-1],self.currHumidityHeater[-1],self.currTemperatureAmbient[-1],self.currHumidityAmbient[-1] ))

    def tick(self):
        self.updateTempHum()
        if not self.stop:
            threading.Timer(self.updateInterval, self.tick).start()
        self.evalTarget()
