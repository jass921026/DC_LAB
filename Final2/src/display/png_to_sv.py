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
    alpha_channel = np.array(image)[:, :, 3]
    return alpha_channel

# 範例使用
# grayscale_array = read_png_to_grayscale('path_to_image.png')
# print(grayscale_array)

fnt_map = "123456789=+-*/ "

def np_img_2_verilog(image: np.ndarray, i):
    image = image.astype(np.uint8).T
    out = [f"\t4'd{i:02d}: begin // {fnt_map[i]}", 
           "\tcase(addr)"]
    for y, row in enumerate(image):
        for x, pixel in enumerate(row):
            out.append(f"\t\t8'd{y}{x}: asciipixel = 8'h{hex(pixel)[2:].rjust(2,"0")};")
    out.append("\tdefault: asciipixel = 8'h0;")
    out.append("\tendcase")
    out.append("\tend")
    return out



if __name__ == "__main__":
    files = [f"./fonts/pixil-frame-{i}.png" for i in range(14)]
    text_to_save = ["module num2pixel(", 
                    "input [3:0] num,", 
                    "input [7:0] addr,", 
                    "output [9:0] brightness",
                    ");",
                    "logic [7:0] asciipixel;",
                    "assign brightness = {asciipixel, 2'b00};",
                    "always_comb begin",
                    "case(num)"]
    for i, file in enumerate(files):
        grayscale_array = read_png_to_grayscale(file)
        text_to_save += np_img_2_verilog(grayscale_array, i)
    text_to_save.extend(["\tdefault: asciipixel = 8'h0;", 
                         "endcase", 
                         "end",
                         "endmodule"])
    
    with open("./num2pixel.sv", "w") as f:
        f.write("\n".join(text_to_save))
