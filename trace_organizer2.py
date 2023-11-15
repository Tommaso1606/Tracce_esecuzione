import json
import os

# Obiettivo è ottenere un dizionario dove la chiave è il traceID e i valori sono una lista di span unici

# Dizionario per organizzare gli oggetti in base al traceID
tracce_organizzate = {}

# Ciclo che itera attraverso ciascun file nella lista ottenuta dalla directory
for filename in os.listdir('tracce'): # Lista di tutti i file nella directory 'traces'
    
    file_path = os.path.join('tracce', filename) # traces/filename.json
     
    # Carica i dati dal file JSON
    with open(file_path, 'r') as file:
        dati = json.load(file) # dati contiene un oggetto Python che rappresenta il singolo file JSON
        
    # Itera attraverso la lista di oggetti data e li raggruppa per traceID
    for entry in dati['data']: #data è l'intero oggetto in ogni file.json
        
        # Per ogni oggetto prendo il traceID e la lista di spans associati a quel traceID
        trace_id = entry['traceID'] 
        span = entry['spans'] 
            
        # Se il traceID è già presente nel dizionario
        if trace_id in tracce_organizzate:
            
            # Cicla su ogni oggetto all'interno della lista span
            for s in span:
                if s not in tracce_organizzate[trace_id]:
                    tracce_organizzate[trace_id].append(s)
        # Altrimenti, crea una nuova lista con gli span
        else:
            tracce_organizzate[trace_id] = span

# Scrive i dati in formato JSON organizzati senza duplicati nel nuovo file.json
with open('trace-all-in-one.json', 'w') as output_file:
    json.dump(tracce_organizzate, output_file, indent=4)

print(f"file creato con {len(tracce_organizzate.keys())}")