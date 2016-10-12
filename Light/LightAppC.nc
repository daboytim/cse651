configuration LightAppC {}
implementation 
{
  components LightC, MainC, LedsC;
  components new SecAMSenderC(6) as AMSenderC;
  components CC2420KeysC;
  components new HamamatsuS1087ParC() as PhotoSensor;
  components new TimerMilliC() as TheTimer;
  components CC2420ActiveMessageC as Radio;
  
  LightC.Boot -> MainC;
  LightC.AMSend -> AMSenderC;
  LightC.Packet -> AMSenderC;
  LightC.CC2420SecurityMode -> AMSenderC;
  LightC.CC2420Keys -> CC2420KeysC;
  LightC.Read -> PhotoSensor;
  LightC.Timer -> TheTimer;
  LightC.Leds -> LedsC;
  LightC.SplitControl -> Radio;
  LightC.PacketLink -> Radio;
}
