#!/usr/bin/env python
"""
Print a description of a MIDI file.
"""
from __future__ import print_function
import midi
import sys
import struct


MaxInterval = 4096
midifile = "WhiteAlbum.mid"
a = midi.read_midifile(midifile)
print(a.resolution)
TPB = a.resolution # ticks per bit
BPM = 90
cnt_ticks = 0

# note(7 bit) 22 - 16
# interval(12 bit) 15 - 4
# pos(3 bit) 3 - 1
# end(1 bit) 0 - 0

basic_note = [40, 45, 50, 55, 59, 64];
base = 12
def gen(a, idx):
    f = open('%s-%d'%("whitealbum", idx), 'wb')
    data = None
    interval = 0
    max_interval = 0
    raw_tick = 0
    note = 0
    cur_intvls = 0
    real_ticks = 0
    for i in range(len(a)):
        if a[i].name == 'Note On':
            if data is not None:
                assert(interval < MaxInterval)
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
            raw_tick += a[i].tick
            
            interval = int(float(raw_tick) / TPB / BPM * 60 * 200)
            
            cur_intvls += interval
            real_ticks += raw_tick
            real_intvls = int(float(real_ticks) / TPB / BPM * 60 * 200)
            print(a[i])
            print("real_intvls=%d,cur_intvls=%d\n"%(real_intvls, cur_intvls))
            if real_intvls != cur_intvls:
                interval += real_intvls - cur_intvls
                cur_intvls = real_intvls
            
            max_interval = max(interval, max_interval)
            pos = 0
            for j in range(6):
                if note >= basic_note[j] + base:
                    pos = j
            End = 0
            data = (note << 12) + max(1, interval)
            data = (data << 3) + pos
            data = (data << 1) + End
            print('note=%d, interval=%d, raw_tick=%d, max=%d'%(note,  int(interval), raw_tick, max_interval))
            raw_tick = 0
        else:
            raw_tick += a[i].tick
    if interval > MaxInterval:
        interval = 4000
    
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
    
for idx,b in enumerate(a[0:4]):
    gen(b, idx)
