import json
import sys
from datetime import datetime 

def number_of_days(timestamp):
  date_split = timestamp.split("T")
  creation_date = datetime.strptime(str(date_split[0]), "%Y-%m-%d")
  today = datetime.today()
  diff = today - creation_date
  return diff.days

n = len(sys.argv)
if(n != 4):
  print("Please enter 3 arguments: Path of file, retention days and prefix string in the same order")
else:
   try:
    path = sys.argv[1]
    retention_days = int(sys.argv[2])
    prefix = sys.argv[3]
    f = open (path, "r")
    data = json.loads(f.read())
    prefix_count = 0
    count = 0
    for i in data:
      name = i['name']
      timestamp = i['creationTimestamp']
      if(name.startswith(prefix) and int(number_of_days(timestamp)) >= retention_days):
        prefix_count += 1
      if(int(number_of_days(timestamp)) >= retention_days):
        count += 1
    print("Total no. of images - ", count)
    print("Total no. of images with Prefix", prefix, " - ", prefix_count)
    f.close()
   except:
     print("Oops!", sys.exc_info()[0], "occurred.")
