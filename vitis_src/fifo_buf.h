#ifndef FIFO_BUF_H
#define FIFO_BUF_H

#include <stdint.h>

typedef struct {
  size_t head; // write index
  size_t tail; // read index
  size_t size;
  size_t num_of_elems;
  uint8_t* data;
} FIFO_BUF;

int fifo_buf_init(FIFO_BUF* buf, size_t size);
int fifo_buf_write(FIFO_BUF* buf, uint8_t data);
int fifo_buf_read(FIFO_BUF* buf, uint8_t* data);
int fifo_buf_isEmpty(FIFO_BUF* buf);
int fifo_buf_isFull(FIFO_BUF* buf);
void fifo_buf_cleanup(FIFO_BUF* buf);

#endif
