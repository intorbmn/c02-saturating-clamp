#!/usr/bin/env bash
# Dung:  bash run_sim.sh --thuong   (buoc 1: xem tung dong)
#        bash run_sim.sh            (buoc 2: may tu danh gia)
set -e
cd "$(dirname "$0")"                 # tu tim duong ve sim/
mkdir -p waveforms
RTL=../rtl/sat_clamp.v
if [ "$1" = "--thuong" ]; then
    iverilog -g2012 -o waveforms/thuong.out $RTL ../tb/tb_sat_clamp.v
    vvp waveforms/thuong.out
else
    iverilog -g2012 -o waveforms/selfcheck.out $RTL ../tb/tb_sat_clamp_selfcheck.v
    vvp waveforms/selfcheck.out | tee waveforms/selfcheck.log
    grep -q "ALL TESTS PASSED" waveforms/selfcheck.log || { echo ">>> TU KIEM THAT BAI - KHONG DI TIEP"; exit 1; }
fi
