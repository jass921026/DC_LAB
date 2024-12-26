import serial
from pprint import pprint
import numpy as np
import Lenet5_inference

#PORT = /dev/tty.usbmodem14101 # Mac
#PORT = /dev/ttyACM0 # Linux
PORT = 'COM3' # Windows
BAUD_RATES = 115200  

ser = serial.Serial(PORT, BAUD_RATES)   

try:
    while True:
        while ser.in_waiting:          
            data_raw = ser.read(900) # Read 900 Bytes
            data_array = np.frombuffer(data_raw, dtype=np.uint8)
            data_array = data_array.reshape(30, 30)
            print(f'Data get:')
            pprint(data_array)

            # Send data To pytorch
            result = Lenet5_inference.inference(data_array)

            # Send result back to FPGA
            ser.write(result)


except KeyboardInterrupt:
    ser.close()    # 清除序列通訊物件
    print('再見！')
