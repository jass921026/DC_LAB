import torch
import torchvision
import torchvision.transforms as transforms
import torch.nn as nn
import torch.nn.functional as F
import Lenet5
import numpy as np

batch_size = 64
num_classes = 10
learning_rate = 0.001
num_epochs = 20

device = torch.device('cpu')

model = Lenet5.LeNet5(num_classes).to(device)
##Load Checkpoint
checkpoint = torch.load('Lenet5.ckpt', weights_only=True)  
model.load_state_dict(checkpoint)

#inference
with torch.no_grad():
    def inference(data: bytes):
        # data is length 900 bytes
        data = np.frombuffer(data, dtype=np.uint8)
        data = data.reshape(30, 30)
        data = np.pad(data, ((1, 1), (1, 1)), 'constant')
        output = model(torch.tensor(data).unsqueeze(0).unsqueeze(0).float())
        output = torch.argmax(output, dim=-1)
        #print(f'Inference: {output}')
        return output.detach().numpy().tobytes()

