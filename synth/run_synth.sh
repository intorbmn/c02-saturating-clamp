#!/usr/bin/env bash
# Buoc 3: tong hop. Chay 2 lan: giu phan cap (de phan tich) + phang (de lay netlist).
set -e
cd "$(dirname "$0")"
mkdir -p reports netlist
yosys -q -l reports/yosys_phancap.log sat_clamp_phancap.ys
yosys -q -l reports/yosys_phang.log   sat_clamp.ys
echo "=== TONG HOP PHANG ==="
grep -E "Number of cells|cells$|\\\$_|sky130|^ +[0-9]+ +[A-Za-z_\$]" reports/stat_phang.txt | head -30
echo
echo "=== PHAN TICH SO SANH vs GHEP KENH (giu phan cap) ==="
python3 phan_tich.py
echo
echo "Netlist: synth/netlist/sat_clamp_netlist.v"
