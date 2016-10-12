configuration ReceiverAppC {}
implementation
{
  components ReceiverC, MainC, LedsC;
  components CC2420KeysC;
  components SerialActiveMessageC as AM;
  components CC2420ActiveMessageC as Radio;

  ReceiverC.Boot -> MainC;
  ReceiverC.Receive -> Radio.Receive[6];
  ReceiverC.Leds -> LedsC;
  ReceiverC.RadioControl -> Radio;
  ReceiverC.CC2420Keys -> CC2420KeysC;
  ReceiverC.SerialControl -> AM;
  ReceiverC.AMSend -> AM.AMSend[6];
  ReceiverC.AMPacket -> AM;
  ReceiverC.PacketLink -> Radio;
}
