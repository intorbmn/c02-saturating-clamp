# C02 — Bộ kẹp giá trị bão hoà 8-bit (saturating clamp)

Bài kiểm tra số 2, học phần **EEE703128 — Nhập môn Thiết kế Vi mạch Tích hợp** (giảng viên: Đinh Văn Nam).
Đề tài **C02**: thiết kế mạch số tổ hợp, đi từ đặc tả, RTL, mô phỏng, tổng hợp đến layout (GDSII) bằng công cụ nguồn mở, chạy tự động trên GitHub Actions.

- Sinh viên: Bạch Minh Nguyên · MSSV 24108270 · Lớp EEE703128-1-1-26 (N01)
- Lần chạy CI dùng cho báo cáo: <https://github.com/intorbmn/c02-saturating-clamp/actions/runs/40424187132>
- Commit của lần chạy đó: `d7796b3f44b92d79fae773fc531f9f417ac383a7`

## 1. Mạch làm gì

Nhận mẫu 8 bit không dấu `ui_in` và hai ngưỡng `lo`, `hi`, trả về mẫu bị ép vào đoạn `[lo, hi]`:

| Điều kiện | `uo_out` | `uio_out[0]` (cờ kẹp) |
|---|---|---|
| `s < lo` | `lo` | 1 |
| `lo <= s <= hi` | `s` | 0 |
| `s > hi` | `hi` | 1 |

So sánh là nghiêm ngặt và không dấu, nên mẫu bằng đúng ngưỡng được giữ nguyên và cờ bằng 0. Mạch **thuần tổ hợp**: không clock, không reset, 0 phần tử nhớ.

### Giao diện (kiểu Tiny Tapeout)

| Tín hiệu | Chiều | Ý nghĩa |
|---|---|---|
| `ui_in[7:0]` | vào | Mẫu cần kẹp |
| `uio_in[7:4]` | vào | Ngưỡng dưới: `lo = {uio_in[7:4], 4'h0}` |
| `uio_in[3:1]` | vào | Ngưỡng trên: `hi = {uio_in[3:1], 5'h1F}` |
| `uio_in[0]` | vào | Không dùng |
| `uo_out[7:0]` | ra | Mẫu sau khi kẹp |
| `uio_out[0]` | ra | Cờ kẹp |
| `uio_out[7:1]` | ra | Cố định 0 |
| `uio_oe[7:0]` | ra | Cố định `8'h01` (chỉ `uio[0]` là ngõ ra) |

> **Giả định cần lưu ý.** Đề cần 25 tín hiệu trên ô chỉ có 24 chân (`uio[0]` vừa là ngõ vào ngưỡng vừa là ngõ ra cờ). Cách chia ngưỡng 4 + 3 bit ở trên là giả định của người thực hiện và chưa được giảng viên xác nhận. Nếu đề gốc quy định khác, chỉ cần sửa hai dòng `lo`, `hi` ở module top.

## 2. Cấu trúc thư mục

```
.
├── rtl/
│   └── sat_clamp.v                 # clamp_cmp, clamp_mux, sat_clamp (top)
├── tb/
│   ├── tb_sat_clamp.v              # testbench thường: 5 ca của đề + TC-06, TC-07
│   └── tb_sat_clamp_selfcheck.v    # tự kiểm vét cạn + bất biến
├── sim/
│   ├── run_sim.sh                  # chạy mô phỏng (Icarus Verilog)
│   └── mutation_test.py            # phép thử phá mạch (10 lỗi cố tình)
├── synth/
│   ├── run_synth.sh                # Yosys: giữ phân cấp và làm phẳng
│   └── reports/                    # stat_phancap.*, stat_phang.* (đã commit)
├── openlane/
│   └── config.json                 # cấu hình LibreLane/OpenLane
├── .github/
│   ├── workflows/rtl2gds.yml       # CI: mô phỏng + RTL-to-GDSII
│   └── doc_metrics.py              # gom số liệu chính từ metrics.json
├── .gitignore
└── README.md
```

## 3. Yêu cầu công cụ

| Công cụ | Dùng để | Phiên bản đã dùng |
|---|---|---|
| Icarus Verilog (`iverilog`, `vvp`) | Mô phỏng RTL | 12.0 |
| Yosys | Đếm cell (giữ phân cấp / phẳng) | 0.52 |
| Python 3 | Script phá mạch, gom số liệu | 3.x |
| LibreLane + PDK sky130A | RTL-to-GDSII (chạy trên CI) | v3.0.17, PDK `8afc8346a57fe1ab7934ba5a6056ea8b43078e71` |
| GTKWave (tuỳ chọn) | Xem waveform | — |

Trên Ubuntu/WSL: `sudo apt install iverilog yosys gtkwave python3`.
Phần RTL-to-GDSII nặng và cần Nix, nên cách đơn giản nhất là để GitHub Actions chạy (mục 5).

## 4. Chạy local

```bash
git clone https://github.com/intorbmn/c02-saturating-clamp
cd c02-saturating-clamp

bash sim/run_sim.sh --thuong     # mô phỏng thường: in từng ca để đọc bằng mắt
bash sim/run_sim.sh              # tự kiểm vét cạn, kỳ vọng dòng ALL TESTS PASSED
python3 sim/mutation_test.py     # phép thử phá mạch
bash synth/run_synth.sh          # Yosys: bảng so sánh / ghép kênh
```

Kết quả kỳ vọng:

- Tự kiểm: **36.869 phép kiểm, 0 lỗi** (`5 + 144 × 256`: 5 ca của đề; 72 cấu hình `lo <= hi` nhân 2 giá trị của bit `uio_in[0]` không dùng; 256 mẫu).
- Phá mạch: 9 trên 10 lỗi bị bắt; lỗi M5 (đảo thứ tự ưu tiên) sống sót vì chỉ khác kết quả khi `lo > hi`, vùng đề không định nghĩa.
- Yosys: giữ phân cấp cho so sánh : ghép kênh : cờ = 71 : 16 : 1 (tổng 88); làm phẳng còn 51 cell.
- Waveform nằm ở `waveforms/sat_clamp.vcd`, mở bằng `gtkwave`.

## 5. Chạy RTL-to-GDSII trên GitHub Actions

Workflow `.github/workflows/rtl2gds.yml` chạy mỗi lần push lên `main` (và chạy tay được):

1. Job **mo-phong**: chạy `run_sim.sh --thuong` và `run_sim.sh`, thất bại nếu thấy `LOI:`, `TESTS FAILED`, `FATAL` hoặc thiếu `ALL TESTS PASSED`.
2. Job **rtl2gds**: cài LibreLane bằng Nix, chạy `openlane/config.json`, rồi tải lên artifact `rtl2gds-C02` (GDS, `metrics.json`, các file `.rpt`, `resolved.json`, `flow_versions.txt`, `metrics_chinh.txt`).

Chạy tay và tải kết quả:

```bash
gh workflow run "RTL to GDSII"
gh run list --limit 3                       # lấy số hiệu run (ví dụ 40424187132)
gh run watch 40424187132
gh run download 40424187132 -D ci_ket_qua   # nhớ thay bằng số hiệu thật, không gõ dấu < >
```

Cấu hình chính (`openlane/config.json`): `DESIGN_NAME = sat_clamp`, `CLOCK_PORT = null` (không có clock nên bỏ qua CTS), `FP_SIZING = absolute`, `DIE_AREA = [0, 0, 160, 100]` (µm), `PL_TARGET_DENSITY_PCT = 55`, `RUN_LINTER = true`. Chu kỳ 10 ns, độ trễ vào/ra 2 ns và uncertainty 0,25 ns là mặc định của flow (ghi trong `resolved.json`), chỉ là giả định phân tích.

## 6. Kết quả chính (CI run 40424187132)

| Hạng mục | Giá trị |
|---|---|
| Cell sau tổng hợp (sky130) | 41 (15 `conb_1` + 5 `inv_2` + 21 cell logic), 276,515 µm², 0 flip-flop |
| Sau layout | 230 instance (165 tap + 24 buffer + 41 logic), 723,194 µm², mật độ 6,39% |
| Setup slack | tệ nhất 1,640 ns (`max_ss_100C_1v60`); 3,731 ns ở `nom_tt` |
| Hold slack | tệ nhất 4,288 ns |
| DRC / LVS / antenna | 0 / 0 / 0 |
| Công suất (`nom_tt`) | 36,93 µW (ước lượng theo giả định mặc định) |
| CTS | Không chạy (mạch không có clock) |

Các con số này chỉ có nghĩa ở các giả định nêu trong báo cáo: slack dương không cho biết tần số tối đa, và file GDS không chứng minh chức năng đúng hay khả năng chế tạo.

## 7. Giới hạn đã biết

- Chưa mô phỏng gate-level trên netlist sau layout.
- Hành vi khi `lo > hi` (56 trong 128 mã ngưỡng) không được kiểm thử; RTL ưu tiên `lo`.
- Số liệu Yosys (51, 88, 71 : 16 : 1) được tạo ở máy local và commit trong `synth/reports/`, không phải artifact của CI.
- Cách mã hoá ngưỡng 4 + 3 bit là giả định, chưa được giảng viên xác nhận.

## 8. Báo cáo

Báo cáo đầy đủ (PDF/DOCX, 15 trang) nộp kèm; mọi số liệu trong báo cáo lấy từ CI run nêu ở đầu file này.

## 9. Công cụ AI đã dùng

Claude (Anthropic) hỗ trợ dựng khung báo cáo, soạn bản nháp, viết script mô phỏng và phép thử phá mạch, và giải thích khái niệm. Số liệu do tác giả chạy và đối chiếu với artifact của CI.
