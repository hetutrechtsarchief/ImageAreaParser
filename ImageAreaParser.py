#!/usr/bin/env python3

import xml.parsers.expat
import json,sys,os,argparse,time,re
from html.parser import HTMLParser
import logging
import datetime

class Parse(HTMLParser):
  
  def handle_comment(self, data):
    global obj

    m = re.findall(r"#\$AUTHOR:(.*)", data) 
    for r in m:
      obj["modifiedBy"] = r.strip()

    m = re.findall(r"#\$DATE:(.*)", data)
    for r in m:
      obj["modifiedDate"] = r.strip()

  def handle_starttag(self, name, attrs):
    global obj

    # get image src
    if name=="img":
      for k,v in attrs:
        if k=="class" and v=="mapper":
          for k,v in attrs:
            if k=="src":
              obj["image"] = v

    if name=="area":
      row = {}
      for k,v in attrs:
        if k in ["title","id","rel","href","coords"]:
          row[k] = v
          if k=="href":
            row[k] = "http://www.documentatie.org" + row[k] # prepend to make absolute URL

          m = re.findall(r"Ob\d+n", v) 
          for r in m:
            row["ObjNr"] = r

      if row["title"]!="@" and row["coords"]!="@": 
        obj["rows"].append(row)
        
####################################################

# parse command line parameters/arguments
argparser = argparse.ArgumentParser(description='UDS Image Area parser')
argparser.add_argument('--html',help='input html file', required=True)
args = argparser.parse_args()

obj = {
  "@context": "context.json",
  "image": "",
  "modifiedBy": "",
  "modifiedDate": "",
  "rows": []
}

# open xml file and read lines
with open(args.html, 'r') as file:  
  for line in file:
    xml = Parse()
    xml.feed(line)

print(json.dumps(obj, indent=4, sort_keys=True, ensure_ascii=False))

