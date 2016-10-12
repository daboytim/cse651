#include "AM.h"

module ReceiverC
{
  uses {
    interface Boot;
    interface SplitControl as RadioControl;
    interface SplitControl as SerialControl;
    interface CC2420Keys;
    interface Leds;
    interface Receive;
    interface AMSend;
    interface AMPacket;
    interface PacketLink;
  }
}
implementation
{
  //the 128-bit AES key
  uint8_t key[16] = {0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0,0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0};

  //uint8_t key[16] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

  bool readyToReceive = FALSE;
  bool sending = FALSE;

  //toggle the red led if a problem occurs
  void reportProblem() { 
    call Leds.led0Toggle();
  }

  //toggle the green led when a message is recieved
  void reportReceive() {
    call Leds.led1Toggle();
  }

  //toggle the blue led when a message is sent to the pc
  void reportSent() { 
    call Leds.led2Toggle();
  }

  //start the serial connection after booting
  event void Boot.booted() {
    while (call SerialControl.start() != SUCCESS) {
      reportProblem();
    }
  }
  
  //key set, ready to receive packets
  event void CC2420Keys.setKeyDone(uint8_t keyNo, uint8_t* skey) {
    readyToReceive = TRUE;
  }

  //set the AES key after wireless device is turned on
  event void RadioControl.startDone(error_t error) {
    while (error != SUCCESS) {
      call RadioControl.start();
    }
    call Leds.led2Toggle();
    call CC2420Keys.setKey(0, key);
  }

  //dont need to worry about this, never call stop()
  event void RadioControl.stopDone(error_t error) {

  }

  //start the wireless device after serial connection is set up
  event void SerialControl.startDone(error_t error) {
    while (error != SUCCESS) {
      call SerialControl.start();
    }
    call Leds.led2Toggle();
    while (call RadioControl.start() != SUCCESS) {
      reportProblem();
    }
  }
  
  //dont need to worry about this, never call stop()
  event void SerialControl.stopDone(error_t error) {

  }

  //send a messagge on the serial connection after a message is received on the wireless device
  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len) {
    if (readyToReceive && !sending) {
      reportReceive();
      sending = TRUE;
      if (call AMSend.send(AM_BROADCAST_ADDR, msg, len) != SUCCESS) {
	reportProblem();
      }
    }
    return msg;
  }

  //report sent to pc, set sending to false
  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      reportSent();
    else 
      reportProblem();

    sending = FALSE;
  }
}
