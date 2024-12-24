import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont
import shutup
import math

def get_pixel_occupancy(character, font_path='ttf/Square.ttf', font_size=20):
    """
    Given a character, font path, and font size, calculate the percentage of pixel occupancy of the character.
    
    Args:
    - character (str): The character to analyze (e.g., 'A').
    - font_path (str): The path to the font file (e.g., 'arial.ttf').
    - font_size (int): The font size for rendering the character.
    
    Returns:
    - float: Percentage of pixel occupancy by the character.
    """
    # Create an image large enough to hold the character
    image_size = (50, 50)  # Define an image size based on the font size
    image = Image.new('L', image_size, color=255)  # Create a white image (255 is white in grayscale)
    
    # Load the font and create a drawing context
    try:
        font = ImageFont.truetype(font_path, 50)
    except IOError:
        font = ImageFont.load_default()  # Fallback to default font if the specified one is unavailable
    
    draw = ImageDraw.Draw(image)
    # Get the width and height of the character
    char_width, char_height = draw.textsize(character, font=font)
    # Draw the character on the image, centering it
    text_position = ((image_size[0] - char_width) // 2, (image_size[1] - char_height) // 2)
    draw.text(text_position, character, fill=0, font=font)  # Fill=0 draws the character in black
    
    # Convert the image to a numpy array and threshold it (if necessary)
    img_array = np.array(image)
    # Count the number of pixels occupied by the character (non-background pixels)
    occupied_pixels = np.sum(img_array/255)  # Black pixels represent the character
    '''
    if(character == 'B') :
        for k in range(len(img_array)):
            for l in range(len(img_array[0])):
                print(img_array[k][l], end = ' ');
            print()
    '''
    # Calculate total number of pixels
    total_pixels = img_array.size
    
    # Calculate the percentage of pixel occupancy
    occupancy_percentage = occupied_pixels
    
    img_array_avg = np.zeros((font_size, font_size))
    if(font_size < 50):
        S = int(50/font_size)
        for i in range(font_size):
            for j in range(font_size):
                img_array_avg[i][j] = np.sum(img_array[int(i*S):int(i*S+S),int(j*S):int(j*S+S)], axis = (0,1)) / (S*S)
    else :
        S = font_size / 50
        for i in range(font_size):
            for j in range(font_size):
                img_array_avg[i][j] = img_array[int(i/S)][int(j/S)]
    
    return occupancy_percentage, img_array_avg, img_array


SS = [10]
FILE = open("ascii.txt", 'w')
FILE.close()
for S in SS :
    
#S = 8
    #MAX = 126
    CHARS = [48,49,50,51,52,53,54,55,56,57,43,45,42,47,61]
    OCC = np.zeros(15)
    IMG = np.zeros((15,S,S))
    img = np.zeros((15,50,50))
    shutup.please()
    for index in range(len(CHARS)):
        character = chr(CHARS[index])
        occupancy, IMG[index], img[index] = get_pixel_occupancy(character, font_size = S)
        #print(f"Percentage of pixel occupancy for character '{character}': {occupancy:.2f} pixels")
        OCC[index] = occupancy
    print("Finisned!")
    I = np.array(IMG, dtype = int)
    
    ind = np.lexsort((CHARS,OCC))
    A = [[CHARS[i], OCC[i]] for i in ind]

    OCC = 1 - (OCC / OCC[ind[-1]])
    OCC = 1 - OCC / OCC[ind[0]] * 0.95
    OCC = OCC * 255

    for index in ind:
        print(str(chr(CHARS[index])) + " : " + str(OCC[index]))
    FILE = open("ascii.txt", 'a')
    FILE.write("\tif (iPixel == " + str(int(np.log2(S))) + ") begin\n")
    FILE.close()
    last_ind = ind[-1]
    last_occ = -1
    first = True
    for INDEX in ind:
        FILE = open("ascii.txt", 'a')
        if(OCC[INDEX] == last_occ):
            last_occ = OCC[INDEX]
            continue
        last_occ = OCC[INDEX]
        if(first) :
            FILE.write("\t\tif (gray < 8'h" + str(hex(int(OCC[INDEX])))[2:3+1] + ") begin // " + str(chr(CHARS[INDEX])) + '\n')
            first = False
        elif(INDEX == last_ind):
            FILE.write("\t\telse begin // " + str(chr(CHARS[INDEX])) + "\n")
        else :
            FILE.write("\t\telse if (gray < 8'h" + str(hex(int(OCC[INDEX])))[2:3+1] + ") begin // " + str(chr(CHARS[INDEX])) + '\n')

        FILE.write("\t\t\tcase(addr)\n")
        for i in range(S):
            for j in range(S):
                FILE.write("\t\t\t\t8'd")
                FILE.write(str(hex(i))[2])
                FILE.write(str(hex(j))[2])
                FILE.write(":asciipixel = 8'h" + str(hex(I[INDEX][j][i]))[2:3+1] + ";\n")
        FILE.write("\t\t\t\tdefault:asciipixel = 0;\n")
        FILE.write("\t\t\tendcase\n")
        FILE.write("\t\tend\n")
        FILE.close()
    FILE = open("ascii.txt", 'a')
    FILE.write("\tend\n")
    FILE.close()
    print("FINISH : " + str(S))
