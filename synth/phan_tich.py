#!/usr/bin/env python3
"""Doc stat_phancap.json -> bang so cell: SO SANH vs GHEP KENH (cho muc 8 bao cao)."""
import json

d = json.load(open("reports/stat_phancap.json"))
rows = {k.lstrip("\\"): m for k, m in d["modules"].items()}
SUB = ("clamp_cmp", "clamp_mux")

def cells_rieng(m):
    """Cell cua chinh module, bo qua cac dong 'instance module con'."""
    return {k: v for k, v in m.get("num_cells_by_type", {}).items() if k not in SUB}

cmp_c, mux_c, top_c = (cells_rieng(rows[n]) for n in ("clamp_cmp", "clamp_mux", "sat_clamp"))
cmp_n, mux_n, top_n = (sum(c.values()) for c in (cmp_c, mux_c, top_c))
tong = cmp_n + mux_n + top_n

print(f"{'Phan':<28}{'So cell':>8}{'Ty le':>9}")
print("-" * 45)
for ten, n in (("So sanh (clamp_cmp)", cmp_n),
               ("Ghep kenh (clamp_mux)", mux_n),
               ("Con lai o top (co kep)", top_n)):
    print(f"{ten:<28}{n:>8}{100*n/tong:>8.1f}%")
print("-" * 45)
print(f"{'Tong (giu phan cap)':<28}{tong:>8}")
print(f"\nTy le so sanh : ghep kenh = {cmp_n} : {mux_n} = {cmp_n/mux_n:.2f} : 1")
print("\nChi tiet loai cell:")
for ten, c in (("clamp_cmp", cmp_c), ("clamp_mux", mux_c), ("sat_clamp (top)", top_c)):
    print(f"  {ten}: " + ", ".join(f"{k} x{v}" for k, v in sorted(c.items())))
print("\nLUU Y: tong giu phan cap thuong LON HON tong phang, vi Yosys khong lan truyen")
print("hang so (lo[3:0]=0, hi[4:0]=1) qua ranh gioi module. Xem so 'phang' o tren.")
