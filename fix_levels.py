import os
import io
import sys


for folder_obj in os.listdir("."):
    if folder_obj.endswith(".txt"):
        print("\n\nFound a level file:{}".format(folder_obj))
        print("Checking for broken lines...")

        new_txt=""

        file = open(folder_obj,"r")
        orig_lines = file.readlines()
        file.close()

        for line in orig_lines:
            clean_line = line.strip()
            if not clean_line.startswith('{"') and clean_line.startswith("{"):
                first_comma_pos = clean_line.find(",")
                fixed_line ="{"+'"'+clean_line[1:first_comma_pos]+'"'+clean_line[first_comma_pos:]
                new_txt+=fixed_line+"\n"
            else:
                new_txt+=clean_line+"\n"

        print(new_txt)

        fixed_file = open(folder_obj,"w")
        fixed_file.write(new_txt)
        fixed_file.close()

        
        



