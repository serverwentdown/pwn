'''
A script to help parse unidirectional captured HTTP WebSocket traffic. 
'''

import sys
import struct
import zlib


BUFSIZE = 1024

def read_http_headers(f, buf):
    '''
    Read HTTP request or response headers from f.
    Returns the header bytes and remaining read buffer
    '''
    n = -1
    while n < 0:
        buf.extend(f.read(BUFSIZE))
        n = buf.find(b'\r\n\r\n')
    head = buf[:n+4]
    buf = buf[n+4:]
    return head, buf

dec = zlib.decompressobj(wbits=-zlib.MAX_WBITS)

def read_websocket_message(f, buf):
    '''
    Read websocket messages by parsing headers from f.
    Returns the opcode, payload and remaining read buffer.
    '''
    while len(buf) < 14:
        read = f.read(BUFSIZE)
        if len(read) <= 0:
            break
        buf.extend(read)

    n = 2
    # Flags
    # ignore fin: buf[0] & 0b1000_0000
    # ignore reserved: buf[0] & 0b0111_0000
    # per-message compression (assumes deflate)
    compress = not not (buf[0] & 0b0100_0000)
    # opcode
    opcode = buf[0] & 0b0000_1111
    # mask
    mask = not not (buf[1] & 0b1000_0000)
    if mask:
        n += 4
    # length
    length = buf[1] & 0b0111_1111
    if length == 126:
        # next 2 bytes
        length, = struct.unpack('!H', buf[2:2+2])
        n += 2
    elif length == 127:
        # next 8 bytes
        length, = struct.unpack('!Q', buf[2:2+8])
        n += 8

    while len(buf) < n + length:
        read = f.read(BUFSIZE)
        if len(read) <= 0:
            break
        buf.extend(read)
    payload = buf[n:n+length]

    if mask:
        for i in range(length):
            off = i % 4
            payload[i] = payload[i] ^ buf[n-4+off]
    if compress:
        payload.extend((0x00, 0x00, 0xff, 0xff))
        payload = dec.decompress(payload)

    buf = buf[n+length:]
    return opcode, payload, buf


if __name__ == '__main__':
    f = open(sys.argv[1], 'rb')
    buf = bytearray()

    # Read request headers
    head, buf = read_http_headers(f, buf)

    # Read messages
    OPCODE_BINARY = 0x02
    OPCODE_TEXT = 0x02
    while True:
        opcode, payload, buf = read_websocket_message(f, buf)
        if len(payload) == 0:
            break
        print(opcode, payload)

    f.close()


# vim: set et ts=4 sw=4:
