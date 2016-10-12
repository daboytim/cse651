#include "Timer.h"
#include "Light.h"

module LightC
{
  uses {
    interface Boot;
    interface Read<uint16_t>;
    interface SplitControl;
    interface AMSend;
    interface Packet;
    interface CC2420SecurityMode;
    interface CC2420Keys;
    interface Timer<TMilli> as Timer;
    interface Leds;
    interface PacketLink;
  }
}
implementation
{
  //the 128-bit AES key
  uint8_t key[16] = {0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0,0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0};
  
  uint8_t count = 0;
  lightData_t local;
  message_t packet;
  bool sending = FALSE;
  
  //toggles the red led if there is a problem
  void reportProblem() { 
    call Leds.led0Toggle();
  }
  
  //toggles the green led when the photo sensor has been read
  void reportRead() {
    call Leds.led1Toggle();
  }

  //toggles the blue led when a message has been sent
  void reportSent() { 
    call Leds.led2Toggle();
  }
  
  //get ready to send a message
  void prepareForSend() {
    while (call SplitControl.start() != SUCCESS) {
      reportProblem();
    }
  }
  
  //send a message
  void sendLocal() {
    sending = TRUE;
    memcpy(call AMSend.getPayload(&packet, sizeof(local)), &local, sizeof local );   
    call CC2420SecurityMode.setCtr(&packet, 0, 0);
    call PacketLink.setRetries(&packet, 1);
    if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof (lightData_t)) != SUCCESS) {
      reportProblem();
    }
    reportSent();
  }

  //start the timer when the device is booted
  event void Boot.booted() {
    call Timer.startPeriodic(TIME_INTERVAL);
  }
  
  //when the AES key has been set send the message
  event void CC2420Keys.setKeyDone(uint8_t keyNo, uint8_t* sKey) {
    if (keyNo != 0 || sKey != NULL) {
      call CC2420Keys.setKey(0, key);
      reportProblem();
    }
    sendLocal();
  }

  //when the timer fires read the photo sensor
  event void Timer.fired() {
    if (sending)
      return;
    while (call Read.read() != SUCCESS) {
      reportProblem();
    }
  }

  //when the photo sensor has been read store the result, send a message if this is the Nth reading
  event void Read.readDone(error_t result, uint16_t data) {
    if (result == SUCCESS) {
      reportRead();
      local.data[count] = data;
      count++;
      if (count == N_READINGS) {
	count = 0;
	prepareForSend();
      }
    } else 
      reportProblem();
  }

  //set the AES key when the wireless device has been started
  event void SplitControl.startDone(error_t error) { 
    while (error != SUCCESS) 
      call SplitControl.start();
    call CC2420Keys.setKey(0, key);
  }

  //stop the wireless device when the message is finished sending
  event void AMSend.sendDone(message_t* msg, error_t error) {
    if (error == SUCCESS)
      reportSent();
    else 
      reportProblem();

    call SplitControl.stop();
    sending = FALSE;
  }

  //if the wireless device did not stop correctly try again
  event void SplitControl.stopDone(error_t error) {
    if (error != SUCCESS)
      call SplitControl.stop();
  }

}
