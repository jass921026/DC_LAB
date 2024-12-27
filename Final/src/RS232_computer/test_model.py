import Lenet5_inference
import numpy as np
import random
import os 
import PIL.Image as Image
import pathlib
from pprint import pprint

data = pathlib.Path("./test")
def test ():
    ans = random.randint(0, 9)
    candidates = os.listdir(data/str(ans))
    image_path = random.choice(candidates) #png
    image = Image.open(data/str(ans)/image_path) #GrayScale
    image = np.array(image)
    image = np.pad(image, ((1, 1), (1, 1)), 'constant') #padding to 30x30
    print("Image Shape: ", image.shape)
    image_bytes = image.tobytes() # 900 bytes
    print("Image Bytes Length: ", len(image_bytes))


    result = Lenet5_inference.inference(image_bytes)
    print(f"Image Path: {data/str(ans)/image_path}")
    #pprint(image)
    print(f"Answer: {ans}, Inference: {int.from_bytes(result, byteorder='little')}")
    return ans == int.from_bytes(result, byteorder='little')

if __name__ == "__main__":
    success = 0
    times = 100
    for i in range(times):
        success += test()
    print(f"Success Rate: {success/times}%")

