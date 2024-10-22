# move to the archaea_folder and enter the code below into the code.py file and run it to concat all the .fna or .fa sequence files into a single archaea_refseq.fna file

import os

# Directory containing the .fna and .fa files
directory = '/path/to/your/archaea_folder'  # Change this to your folder path
output_file = 'archaea_refseq.fna'

with open(output_file, 'w') as outfile:
    for filename in os.listdir(directory):
        if filename.endswith(('.fna', '.fa')):
            with open(os.path.join(directory, filename), 'r') as infile:
                lines = infile.readlines()
                for line in lines:
                    outfile.write(line.rstrip() + '\n')

print(f"Combined sequences saved to {output_file}")

# move to the fungi_folder and enter the code below into the code.py file and run it to concat all the .fna or .fa sequence files into a single fungi_refseq.fna file

import os

# Directory containing the .fna and .fa files
directory = '/path/to/your/fungi_folder'  # Change this to your folder path
output_file = 'fungi_refseq.fna'

with open(output_file, 'w') as outfile:
    for filename in os.listdir(directory):
        if filename.endswith(('.fna', '.fa')):
            with open(os.path.join(directory, filename), 'r') as infile:
                lines = infile.readlines()
                for line in lines:
                    outfile.write(line.rstrip() + '\n')

print(f"Combined sequences saved to {output_file}")

# move to the bacteria_folder and enter the code below into the code.py file and run it to concat all the .fna or .fa sequence files into a single bacteria_refseq.fna file

import os

# Directory containing the .fna and .fa files
directory = '/path/to/your/bacteria_folder'  # Change this to your folder path
output_file = 'bacteria_refseq.fna'

with open(output_file, 'w') as outfile:
    for filename in os.listdir(directory):
        if filename.endswith(('.fna', '.fa')):
            with open(os.path.join(directory, filename), 'r') as infile:
                lines = infile.readlines()
                for line in lines:
                    outfile.write(line.rstrip() + '\n')

print(f"Combined sequences saved to {output_file}")

#code to concat archaea_refseq.fna, fungi_refseq.fna and bacteria_refseq.fna files

import os

# Directory containing the .fna and .fa files
directory = '/path/to/your/new_folder'  # Change this to your folder path
output_file = 'all_refseq.fna'

with open(output_file, 'w') as outfile:
    for filename in os.listdir(directory):
        if filename.endswith(('.fna', '.fa')):
            with open(os.path.join(directory, filename), 'r') as infile:
                lines = infile.readlines()
                for line in lines:
                    outfile.write(line.rstrip() + '\n')

print(f"Combined sequences saved to {output_file}")
