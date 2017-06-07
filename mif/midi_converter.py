#!/usr/bin/env python
"""
Print a description of a MIDI file.
"""
from __future__ import print_function
import midi
import sys
import struct



midifile = sys.argv[1]
a = midi.read_midifile(midifile)
print(a.resolution)
TPM = a.resolution
TPM = 620*4
cnt_ticks = 0

# note(7 bit) 20 - 14
# interval(10 bit) 13 - 4
# pos(3 bit) 3 - 1
# end(1 bit) 0 - 0

basic_note = [40, 45, 50, 55, 59, 64];
base = 12
def gen(a, idx):
    f = open('%s-%d'%(sys.argv[2], idx), 'wb')
    data = None
    interval = 0
    max_interval = 0
    note = 0
    for i in range(len(a)):
        if a[i].name == 'Note On':
            if data is not None:
                data = struct.pack('>i', data)
                for c in data[1:]:
                    if ord(c) <= 107 and ord(c) > 32:
                        print(c,end='')
                    else:
                        print('[%d]'%ord(c),end='')
                print()
                f.write(data[1:])
            note = a[i].data[0]
            velocity = a[i].data[1]
            interval += max(1, a[i].tick * 200 // TPM)
            pos = 0
            for j in range(6):
                if note >= basic_note[j] + base:
                    pos = j
            End = 0
            data = (note << 10) + interval
            data = (data << 3) + pos
            data = (data << 1) + End
            interval = 0
        else:
            interval += max(1, a[i].tick * 200 // TPM)
        max_interval = max(interval, max_interval)
        print('note=%d, interval=%d'%(note,  interval))
    if interval > 511: interval /= 4
    
    if data is not None:
        assert(data % 2 == 0)
        data += 1
        data = struct.pack('>i', data)
        for c in data[1:]:
            if ord(c) <= 107 and ord(c) > 32:
                print(c,end='')
            else:
                print('[%d]'%ord(c),end='')
        print()
        f.write(data[1:])
    f.close()
    print('max_interval=%d'%max_interval)
    
for idx,b in enumerate(a):
    gen(b, idx)
