#!/usr/bin/env python3

import xml.parsers.expat
import json,sys,os,argparse,time,re
from html.parser import HTMLParser
import logging
from datetime import datetime

def makeAbsoluteURL(url):
  if (url.startswith('/')):
    return 'http://www.documentatie.org' + url
  else:
    return url

def is_coord(coord):
    # Do we have commas?
    if "," not in coord:
        return False

    # Split up by comma and check if all values are digits
    values = [v.isdecimal() for v in coord.split(",")]
    return all(values)

class Parse(HTMLParser):
  
  def handle_comment(self, data):
    global obj

    m = re.findall(r"#\$AUTHOR:(.*)", data) 
    for r in m:
      obj["modifiedBy"] = r.strip()

    m = re.findall(r"#\$DATE:(.*)", data)
    for r in m: 
      date = datetime.strptime(r.strip(), "%a %b %d %H:%M:%S %Y") # Wed Feb 29 16:58:18 2012
      obj["modifiedDate"] = date.isoformat()

  def handle_starttag(self, name, attrs):
    global obj
    row = { "@context": "http://www.w3.org/ns/anno.jsonld" }



    # get image src
    if name=="img":
      print("img",name,attrs,file=sys.stderr)
      for k,v in attrs:
        if k=="usemap":
        # if k=="class" and v=="mapper":
          for k,v in attrs:
            if k=="src":
              # print("image"+v,file=sys.stderr)
              obj["image"] = args.base_url + v

    if name=="area":
      row = {}
      # row["image"] = obj["image"]

      for k,v in attrs:
        if k in ["title","rel","coords", "href"]: #"href", "id",
        
          if k!="href":
            row[k] = v
        
          #   row[k] = makeAbsoluteURL(row[k]) # prepend to make absolute URL

          m = re.findall(r"Ob\d+n", v) 
          for r in m:
            row["ObjNr"] = "object/"+r

          # del row["href"]

      if row["title"]!="@" and is_coord(row["coords"]): #and row["coords"]!="@" : 
        obj["rows"].append(row)
        # print(row)
        # print(json.dumps(row, indent=4, sort_keys=True, ensure_ascii=False))
        # print(',')

        
####################################################

# parse command line parameters/arguments
argparser = argparse.ArgumentParser(description='UDS Image Area parser')
argparser.add_argument('--html',help='input html file', required=True)
argparser.add_argument('--base_url',help='base url', required=True)
args = argparser.parse_args()

print(args.html,file=sys.stderr)

obj = {
  "@context": "context.json",
  "image": args.base_url,
  "id": args.base_url + args.html ,
  "modifiedBy": "",
  "modifiedDate": "",
  "rows": []
}

# open xml file and read lines
with open(args.html, 'r') as file:  
  xml = Parse()
  # print('{ "@context": "context.json", "@graph": [')
  for line in file:    
    xml.feed(line)
  # print('{ }')
  # print('] }')


print(json.dumps(obj, indent=4, sort_keys=True, ensure_ascii=False))
