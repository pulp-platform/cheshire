import numpy as np

input  = 0x34
p      = 0x1D
XorIn  = 0xFF
RefIn  = False
RefOut = False
XorOut = 0xFF
type   = 8

print("poly", format(p, '08b'))

def xor(b, type):
  if b / 2**(type-1) >= 1:
        return (np.bitwise_xor(b % 2**(type-1) << 1, p)) 
  else:
        return b << 1

def calc_crc(type, input, p, XorIn, RefIn, RefOut, XorOut):
  crc = np.bitwise_xor(input, XorIn)
  print(format(crc, '08b'))
  for _ in range (type):
    crc = xor(crc, type)
    print(format(crc, '08b'))
  return np.bitwise_xor(crc, XorOut)

print(format(calc_crc(type, input, p, XorIn, RefIn, RefOut, XorOut), '02x'))

print(format(np.bitwise_xor(0xCC, 0x05), '02x'))
