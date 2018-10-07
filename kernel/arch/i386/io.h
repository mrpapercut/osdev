#ifndef INCLUDE_IO_H
#define INCLUDE_IO_H

/**
 * outb:
 * Sends given data to given I/O port
 *
 * @param port I/O port to send to
 * @param data Data to send
 */
void outb(unsigned short port, unsigned char data);

#endif
