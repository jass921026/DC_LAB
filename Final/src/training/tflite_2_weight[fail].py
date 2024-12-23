import numpy as np
import tensorflow as tf
from pprint import pprint

tflite_model_file = 'quant_model.tflite'

with open(tflite_model_file, 'rb') as fid:
    tflite_model = fid.read()
    
interpreter = tf.lite.Interpreter(model_content=tflite_model)
interpreter.allocate_tensors()

input_index = interpreter.get_input_details()[0]["index"]
output_index = interpreter.get_output_details()[0]["index"]

pprint(interpreter.summary())