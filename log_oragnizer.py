import os

log_folder_path = 'execution_1'

output_file = 'log-all-in-one.json'


file_names = os.listdir(log_folder_path)


with open(output_file, 'w') as output:
    
    for file_name in file_names:
        
        full_path = os.path.join(log_folder_path, file_name)
        
        if full_path.endswith('.log'):
            # Apri ogni file in modalità lettura
            with open(full_path, 'r') as input_file:
                
                output.write(input_file.read())
                output.write('\n')

print("file creato")