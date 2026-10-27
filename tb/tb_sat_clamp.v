`timescale 1ns/1ps
// Testbench thuong: 5 ca theo de bai, in tung dong de doc bang mat.
module tb_sat_clamp;
    reg  [7:0] ui_in, uio_in;
    wire [7:0] uo_out, uio_out, uio_oe;

    sat_clamp dut (.ui_in(ui_in), .uio_in(uio_in),
                   .uo_out(uo_out), .uio_out(uio_out), .uio_oe(uio_oe));

    // lo = 0x40 (uio_in[7:4]=4), hi = 0xBF (uio_in[3:1]=5)
    localparam [7:0] CFG = {4'h4, 3'd5, 1'b0};

    task ca(input [127:0] ten, input [7:0] s);
        begin
            ui_in = s; uio_in = CFG; #10;
            $display("%-18s s=0x%02h  lo=0x40 hi=0xBF  ->  out=0x%02h  clamp=%b",
                     ten, s, uo_out, uio_out[0]);
        end
    endtask

    // Ca tu xay dung: cho phep doi cau hinh nguong (cfg = uio_in)
    task ca_cfg(input [127:0] ten, input [7:0] s, input [7:0] cfg);
        begin
            ui_in = s; uio_in = cfg; #10;
            $display("%-18s s=0x%02h  cfg=0x%02h  ->  out=0x%02h  clamp=%b",
                     ten, s, cfg, uo_out, uio_out[0]);
        end
    endtask

    initial begin
        $dumpfile("waveforms/sat_clamp.vcd");
        $dumpvars(0, tb_sat_clamp);
        ca("duoi nguong duoi", 8'h30);
        ca("dung bien duoi",   8'h40);
        ca("trong khoang",     8'h80);
        ca("dung bien tren",   8'hBF);
        ca("tren nguong tren", 8'hF0);
        // Hai ca tu xay dung (giai thich o bao cao, muc 4.3)
        ca_cfg("TC06a sat duoi",    8'h3F, 8'h4A);  // lo=0x40 hi=0xBF: ky vong out=0x40 clamp=1
        ca_cfg("TC06b sat tren",    8'hC0, 8'h4A);  // lo=0x40 hi=0xBF: ky vong out=0xBF clamp=1
        ca_cfg("TC07a lo=00 s=00",  8'h00, 8'h0E);  // lo=0x00 hi=0xFF: ky vong out=0x00 clamp=0
        ca_cfg("TC07b hi=FF s=FF",  8'hFF, 8'h0E);  // lo=0x00 hi=0xFF: ky vong out=0xFF clamp=0
        $finish;
    end
endmodule
