#ifndef LIGHT_H_
#define LIGHT_H_

#define TIME_INTERVAL 200//30720 //30 seconds
#define N_READINGS 30 //if you change this update TOSH_DATA_LENGTH in Makefile

typedef nx_struct lightData {
  nx_uint16_t data[N_READINGS];
} lightData_t;

#endif /* LIGHT_H_ */
