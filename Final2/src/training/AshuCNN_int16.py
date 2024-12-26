# %%
# using binary image
import torch
import torchvision
import torchvision.transforms as transforms
import torch.nn as nn
import torch.nn.functional as F
from tqdm import tqdm

# Define relevant variables for the ML task
batch_size = 64
num_classes = 10
learning_rate = 0.001
num_epochs = 1

# %%

# Device will determine whether to run the training on GPU or CPU.
device = torch.device('cpu')

#Loading the dataset and preprocessing
train_dataset = torchvision.datasets.MNIST(root = './data',
                                            train = True,
                                            transform = transforms.Compose([
                                                    transforms.Resize((30,30)),
                                                    transforms.ToTensor(),
                                                    transforms.Normalize(mean = (0.1307,), std = (0.3081,))]),
                                            download = True)


test_dataset = torchvision.datasets.MNIST(root = './data',
                                            train = False,
                                            transform = transforms.Compose([
                                                    transforms.Resize((30,30)),
                                                    transforms.ToTensor(),
                                                    transforms.Normalize(mean = (0.1325,), std = (0.3105,))]),
                                            download=True)


train_loader = torch.utils.data.DataLoader(dataset = train_dataset,
                                            batch_size = batch_size,
                                            shuffle = True)


test_loader = torch.utils.data.DataLoader(dataset = test_dataset,
                                            batch_size = batch_size,
                                            shuffle = True)

# define a floating point model
#Defining the convolutional neural network
class LeNet5(nn.Module):
    def __init__(self, num_classes):
        super(LeNet5, self).__init__()
        # 30 x 30 x 1
        self.conv1 = nn.Conv2d(1, 16, (3, 3), padding=0, stride=1)
        # 28 x 28 x 16
        self.pool1 = nn.AvgPool2d((2, 2), stride=2)
        # 14 x 14 x 16
        self.conv2 = nn.Conv2d(16, 32, (3, 3), padding=0, stride=1)
        # 12 x 12 x 32
        self.pool2 = nn.AvgPool2d((2, 2), stride=2)
        # 6 x 6 x 32 = 1152
        self.fc1 = nn.Linear(1152, 64)
        self.fc2 = nn.Linear(64, 10)
        
    def forward(self, x):
        # binarize the input
        x = (torch.sign(x - 0.5) + 1) * 0.5
        x = F.relu(self.conv1(x))
        x = self.pool1(x)
        x = F.relu(self.conv2(x))
        x = self.pool2(x)
        # Choose either view or flatten (as you like)
        x = x.view(x.size(0), -1)
        # x = torch.flatten(x, start_dim=1)
        x = self.fc1(x)
        x = F.relu(x)
        x = self.fc2(x)
        x = torch.softmax(x, dim=-1)
        return x

# %%

model = LeNet5(num_classes).to(device)
    
#Setting the loss function
cost = nn.CrossEntropyLoss()

#Setting the optimizer with the model parameters and learning rate
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

#this is defined to print how many steps are remaining when training
total_step = len(train_loader)

total_step = len(train_loader)
for epoch in tqdm(range(num_epochs)):
    for i, (images, labels) in tqdm(enumerate(train_loader)):  
        images = images.to(device)
        labels = labels.to(device)
        
        #Forward pass
        outputs = model(images)
        loss = cost(outputs, labels)
        #Backward and optimize
        optimizer.zero_grad()
        loss.backward()
        optimizer.step()

# %%

# Test the model
# In test phase, we don't need to compute gradients (for memory efficiency)
      
with torch.no_grad():
    correct = 0
    total = 0
    for images, labels in test_loader:
        images = images.to(device)
        labels = labels.to(device)
        outputs = model(images)
        _, predicted = torch.max(outputs.data, 1)
        total += labels.size(0)
        correct += (predicted == labels).sum().item()
    print('Accuracy of the network on the 10000 test images: {} %'.format(100 * correct / total))

# %%

# create a model instance
#model_fp32 = M()
# create a quantized model instance
# torch.backends.quantized.engine = 'qnnpack'
# model_qint16 = torch.ao.quantization.quantize_dynamic(
#     model,  # the original model
#     {nn.Conv2d,nn.Linear},  # a set of layers to dynamically quantize
#     dtype=torch.quint16)  # the target dtype for quantized weights

# run the model

# %%

print(model.state_dict())

# %%
from copy import deepcopy
model_qint16 = deepcopy(model)
model_weights = dict()
for key in model.state_dict():
    weight = model.state_dict()[key]
    weight_clamp = torch.clamp(weight, min=-1, max=1)
    weight_qint16 = (weight_clamp.numpy() * 2**14).astype("int16")
    #weight_qint16 = torch.quantize_per_tensor(weight_clamp,scale = 2**-14 , zero_point = 0, dtype = torch.uint16)
    model_weights[key] = weight_qint16
    #print(weight_qint16.size())
print(model_weights)

# %%

# with torch.no_grad():
#     correct = 0
#     total = 0
#     for images, labels in test_loader:
#         images = images.to(device)
#         labels = labels.to(device)
#         outputs = model_qint16(images)
#         _, predicted = torch.max(outputs.data, 1)
#         total += labels.size(0)
#         correct += (predicted == labels).sum().item()
#     print('Accuracy of the quant model on the 10000 test images: {} %'.format(100 * correct / total))

# %%
# Save model weights
#torch.save(model_qint16.state_dict(), 'result/AshuCNN_int16.pth')

# %%

# Save weights by file
for key in model_weights:
    weight = model_weights[key]
    weight = weight.flatten()
    print(weight.shape)
    #print(weight)
    with open(f'result/{key}', 'w') as f:
        for item in weight:
            #print(hex(item))

            f.write(("%x\n"%(item&0xffff)).rjust(5,'0'))
# %%

