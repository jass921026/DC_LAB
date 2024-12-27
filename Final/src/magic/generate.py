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
    image = Image.open(image_path)
    image = image.convert('L')
    # to numpy array
    image = np.array(image)
    #invert
    image = 255 - image
    #print(image)
    return image

# 範例使用
# grayscale_array = read_png_to_grayscale('path_to_image.png')
# print(grayscale_array)

def array_to_text(arr):
    brr = np.zeros((30, 30))
    for i in range(10):
        for j in range(10):
            if arr[i][j]:
                for p in range(3):
                    for q in range(3):
                        brr[3*i+p][3*j+q] = 1

    txt = ""
    for i in range(30):
        txt += "30'b"
        for j in range(30):
            if brr[i][j]:
                txt += '1'
            else:
                txt += '0'
        txt += ",\n"

    return txt
        



if __name__ == "__main__":
    files = [f"./fonts/pixil-frame-{i}.png" for i in range(10)]

    for i, file in enumerate(files):
        grayscale_array = read_png_to_grayscale(file)
        print(f"Processing \n{grayscale_array} \nfrom {file}")

        text = array_to_text(grayscale_array)
        with open (f"./text/{i}.txt", 'w') as file:
            file.write(text)


