#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include "fifo_buf.h"

int fifo_buf_init(FIFO_BUF* buf, size_t size) {
  buf->data = (uint8_t*) malloc(size);
  if (buf->data == NULL) {
    return 1;
  }
  buf->head = 0;
  buf->tail = 0;
  buf->num_of_elems = 0;
  buf->size = size;
  memset(buf->data, 0, size);
  return 0;
}

int fifo_buf_read(FIFO_BUF* buf, uint8_t* databyte) {
  if (buf->num_of_elems == 0) {
    return 1;
  }
  *databyte = buf->data[buf->tail];
  buf->tail++;
  buf->num_of_elems--;
  // if at last index in buffer, set tail back to 0
  if (buf->tail == buf->size) {
    buf->tail = 0;
  }
  return 0;
}

int fifo_buf_write(FIFO_BUF* buf, uint8_t databyte) {
  if (buf->num_of_elems == buf->size) {
    return 1;
  }
  buf->data[buf->head] = databyte;
  buf->head++;
  buf->num_of_elems++;
  // if at last index in buffer, set head back to 0
  if (buf->head == buf->size) {
    buf->head = 0;
  }
  return 0;
}

int fifo_buf_isEmpty(FIFO_BUF* buf) {
  if (buf->num_of_elems == 0) {
    return 1;
  }
  return 0;
}

int fifo_buf_isFull(FIFO_BUF* buf) {
  if (buf->num_of_elems == buf->size) {
    return 1;
  }
  return 0;
}

void fifo_buf_cleanup(FIFO_BUF* buf) {
  if (buf->data != NULL) {
    free(buf->data);
    buf->data = NULL;
  }
  buf->head = 0;
  buf->tail = 0;
  buf->num_of_elems = 0;
  buf->size = 0;
}

