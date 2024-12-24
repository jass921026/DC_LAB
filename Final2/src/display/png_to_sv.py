import numpy as np
from PIL import Image

def read_png_to_grayscale(image_path):
    """
    讀取 PNG 圖片並轉換為灰階 NumPy 陣列

    參數:
    image_path (str): 圖片的路徑

    返回:
    np.ndarray: 灰階圖像的 NumPy 陣列
    """
    image = Image.open(image_path).convert('L')
    return np.array(image)

# 範例使用
# grayscale_array = read_png_to_grayscale('path_to_image.png')
# print(grayscale_array)