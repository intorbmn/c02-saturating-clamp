"""In cac chi so chinh tu metrics.json cua LibreLane/OpenLane de chep vao bao cao.
Dung: python3 .github/doc_metrics.py <duong_dan>/metrics.json
"""
import json
import sys

m = json.load(open(sys.argv[1]))
MAU = ("instance__count", "instance__area", "design__die", "design__core",
       "utilization", "wire", "timing__setup", "timing__hold", "skew",
       "drc", "lvs", "antenna", "power", "route__")
for k, v in sorted(m.items()):
    if any(p in k for p in MAU):
        print(f"{k} = {v}")
