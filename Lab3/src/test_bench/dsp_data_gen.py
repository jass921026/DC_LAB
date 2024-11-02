import random
import binascii
save_path = "dsp_testdata.txt"
gold_path = "dsp_golden.txt"
random.seed(0)
memsize = 2**10 #default 2**20, to reduce the time of simulation
signwidth = 16

def gen_data() -> list[int]:
    data = [random.randint(0, int(2**signwidth-1)) for _ in range(memsize)]
    return data

def dsp(data, speed, mode=0):
    new_data = []
    if speed < 3: # slow playback
        for i in range(len(data)//int(2**(3-speed))): # max size 2MB
            for order in range(int(2**(3-speed))):
                if mode == 0: # no interpolation
                    new_data.append(data[i])
                else : # linear interpolation
                    new_data.append(int(data[i] + (data[i+1] - data[i]) * order / int(2**(3-speed))))
    else: # fast playback
        for i in range(0,len(data),int(2**(speed-3))):
            new_data.append(data[i])
        new_data.extend([0] * (memsize - len(new_data)))
        
    return new_data

def write_data(data, path):
    with open(path, "a", encoding="ascii") as f:
        process_data = [f"{element:04x}" for element in data]
        f.write(" ".join(process_data) + "\n")

def write_text(data, path):
    with open(path, "a", encoding="ascii") as f:
        f.write(data + "\n")

def process(data, save_path, gold_path, speed, mode):
    new_data = dsp(data, speed, mode)
    write_text(f"{speed} {mode}", save_path)
    write_data(new_data, gold_path)

# clear file
open(save_path, "w").close()
open(gold_path, "w").close()

data = gen_data()
write_data(data, save_path)
for speed in range(7):
    process(data, save_path, gold_path, speed, 0)
    if speed < 3:
        process(data, save_path, gold_path, speed, 1)
    

