import json
import re
from datetime import datetime
import pytz

with open('trace-all-in-one.json','r') as file:
    data = json.load(file)
 
dataset = []

status_code_count = {}
    
severity_count = {}

log_entries = {}

involved_services = ""

involved_urls = ""

# Creo la struttura campione per gli status code osservabili
for trace_ID, spans in data.items():
 
    for span in spans:
                
        for tag in span.get("tags", []):
            
            if tag.get("key") == "http.status_code":
    
                status_code = int(tag.get("value"))
                
                if status_code not in status_code_count:
                    status_code_count[status_code] = 0
                
# Creo la struttura campione per i livelli di severity osservabili             
with open('log-all-in-one.json', 'r') as file:
        for line in file:
            
            line = line.strip() # Rimuove gli spazi bianchi prima e dopo la stringa
            
            # Se line non è vuota, quindi != None
            if line:
                data = json.loads(line)

                log_line = data.get('log')
                
                # "log":"2023-11-10 23:03:21.480  INFO 1 --- [io-12346-exec-4] travel.service.TravelServiceImpl: [Train Service] calculate time：0  time: Sat May 04 07:00:00 CST 2013\n"                
                pattern = re.compile(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3})\s+([A-Z]+)\s+.*', re.IGNORECASE) 
                #\s spazio re.IGNORECASE ignora la distinzione tra maiuscole e minuscole  .* qualsiasi cosa

                # Cerca il pattern nella riga del log
                match = pattern.search(log_line) # Resitutisce la corrisponde oppure None

                # Se match != None
                if match: 
                    log_severity = str(match.group(2))
                    
                    if log_severity not in severity_count:
                        severity_count[log_severity] = 0              
                

with open('trace-all-in-one.json','r') as file:
    data = json.load(file)

for trace_ID, spans in data.items():

    urls = []

    services = []
    #start_time = 0
    #end_time = 0
    min_start_time = float('inf') 
    max_end_time = float('-inf') 
    #log_severity = ""
    logs = ""
    
    for span in spans:
        
        # Svuoto le strutture per gli status code e i livelli di severity ogni volta che cambia traceID       
        for key in status_code_count:
            status_code_count[key] = 0

        for key in severity_count:
            severity_count[key] = 0
        
        # Analizzo i tag per recuperare le informazioni
        for tag in span.get("tags", []):
            
            # Status code
            if tag.get("key") == "http.status_code":
    
                status_code = int(tag.get("value"))
                
                if status_code in status_code_count:
                    status_code_count[status_code] += 1            
                                     
            # Involved_urls
            if tag.get("key") == "http.url":
                urls.append(tag.get("value"))
                
                # http://ts-admin-user-service:16115/api/v1/userservice/users/register
                
                match = re.search(r"\/\/(.*?):", tag.get("value")) # Prende tutto quello che trova tra // e :
    
                # Involved_services
                if match:
                    services.append(match.group(1))

        # Start_time e End_time per ogni traccia
        start_time = span["startTime"]
        end_time = start_time + span["duration"]

        # Min_start_time e Max_end_time
        min_start_time = min(min_start_time, start_time)
        max_end_time = max(max_end_time, end_time)
        
        # Converto in formato date i timestamp in formato microsecondi 1e6
        max_end_time_ms = datetime.fromtimestamp(max_end_time/1e6)
        min_start_time_ms = datetime.fromtimestamp(min_start_time/1e6)
       
    with open('log-all-in-one.json', 'r') as file:
        
        for line in file:
            
            line = line.strip()
            
            if line:
                data = json.loads(line)

                log_line = data.get('log')
                
                # "log":"2023-11-10 23:03:21.480  INFO 1 --- [io-12346-exec-4] travel.service.TravelServiceImpl: [Train Service] calculate time：0  time: Sat May 04 07:00:00 CST 2013\n"
                
                pattern = re.compile(r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.\d{3})\s+([A-Z]+)\s+.*', re.IGNORECASE)

                match = pattern.search(log_line)

                if match:
                    log_severity = str(match.group(2))
                    
                    if log_severity in severity_count:
                        severity_count[log_severity] += 1                                  
                
                # Recupero il timestamp del log dal campo time: "2023-11-10T15:03:21.458228216Z" con fuso orario quindi avrò 1h indietro rispetto alle altre date
                log_date = data.get('time')
                
                # Gli tolgo la Z e le ultimi 3 numeri perchè le date delle tracce hanno una precisione dei millisecondi di 6 cifre
                log_date = log_date[:-4]
                
                # Gli tolgo anche la T per eliminare il fuso orario
                log_date = log_date.replace('T', ' ')
                
                log_date_date = datetime.strptime(log_date, "%Y-%m-%d %H:%M:%S.%f")
                
                # Converto la data in formato UTC
                log_date_date = log_date_date.replace(tzinfo=pytz.UTC) 
                   
                # Concateno tutti i campi "log" che hanno timestamp compreso tra il minimo start time e il massimo end time di ogni traccia
                
                # min_start_time e max_end_time sono nel giusto fuso orario ma la log_date è 1h indietro 
                # Il confronto lo faccio tra date tutte in formato UTC per mantenere la coerenza degli intervalli
                if  datetime.fromtimestamp(min_start_time/1e6,tz=pytz.UTC) <= log_date_date <= datetime.fromtimestamp(max_end_time/1e6,tz=pytz.UTC):   
                    logs += log_line

    # Calcolo la latenza
    latency = (max_end_time_ms - min_start_time_ms).total_seconds()
    
    # Converto le date in stringhe per il dataset
    max_end_time_ms = datetime.fromtimestamp(max_end_time/1e6).strftime("%Y-%m-%d %H:%M:%S.%f")
    min_start_time_ms =  datetime.fromtimestamp(min_start_time/1e6).strftime("%Y-%m-%d %H:%M:%S.%f")
    
    # Elimino i duplicati trasformando le liste in set
    services = list(set(services))
    urls = list(set(urls))
    
    # Concateno tutto in delle stringhe con "--" come carattere separatore
    for service in services:
        involved_services += str(service) + "--"
    
    for url in urls:
        involved_urls += str(url) + "--"

    # Elimino i "--" dalla fine delle stringhe
    involved_services = involved_services[:-2]
    involved_urls = involved_urls[:-2]
    
    # Creo un entry grezza per il dataset per uno specifico traceID
    entry_row = {"trace_id": trace_ID,        
                "involved_services": involved_services, 
                "involved_urls": involved_urls, 
                "min_start_time":min_start_time_ms, 
                "max_end_time":max_end_time_ms, 
                "latency_sec":latency,
    }
    
    # Aggiungo la struttuta degli status code
    entry_row.update(status_code_count)
    
    # Aggiungo la struttura dei livelli di severity
    entry_row.update(severity_count)
    
    # Aggiugno i log
    entry_row.update({"log_entries":logs})
    
    # Aggiungo tutta la entry al dataset
    dataset.append(entry_row)

print("Dataset creato")

# Salvo il dataset in formato json su un file
with open('dataset.json', 'w') as output_file:
    json.dump(dataset, output_file, indent=4)