`timescale 1ns/1ps
// Testbench tu kiem: 5 ca theo de + quet VET CAN moi mau (256) x moi cau hinh nguong (256).
module tb_sat_clamp_selfcheck;
    reg  [7:0] ui_in, uio_in;
    wire [7:0] uo_out, uio_out, uio_oe;
    integer errors = 0, checks = 0;
    integer a, b;

    sat_clamp dut (.ui_in(ui_in), .uio_in(uio_in),
                   .uo_out(uo_out), .uio_out(uio_out), .uio_oe(uio_oe));

    // Mo hinh tham chieu viet theo cach KHAC voi RTL (thu tuc, so nguyen)
    reg [7:0] exp_y; reg exp_f;
    reg [7:0] lo, hi;
    task tinh_chuan(input [7:0] s, input [7:0] cfg);
        begin
            lo = {cfg[7:4], 4'h0};
            hi = {cfg[3:1], 5'h1F};
            exp_y = s; exp_f = 1'b0;
            if (s < lo)      begin exp_y = lo; exp_f = 1'b1; end
            else if (s > hi) begin exp_y = hi; exp_f = 1'b1; end
        end
    endtask

    task kiem(input [7:0] s, input [7:0] cfg);
        begin
            ui_in = s; uio_in = cfg; #1;
            tinh_chuan(s, cfg);
            checks = checks + 1;
            if (uo_out !== exp_y || uio_out[0] !== exp_f) begin
                errors = errors + 1;
                if (errors <= 10)
                    $display("LOI: s=0x%02h cfg=0x%02h  got y=0x%02h f=%b  exp y=0x%02h f=%b",
                             s, cfg, uo_out, uio_out[0], exp_y, exp_f);
            end
        end
    endtask

    initial begin
        // 5 ca theo de bai (lo=0x40, hi=0xBF)
        kiem(8'h30, {4'h4,3'd5,1'b0});   // duoi nguong duoi
        kiem(8'h40, {4'h4,3'd5,1'b0});   // dung bien duoi
        kiem(8'h80, {4'h4,3'd5,1'b0});   // trong khoang
        kiem(8'hBF, {4'h4,3'd5,1'b0});   // dung bien tren
        kiem(8'hF0, {4'h4,3'd5,1'b0});   // tren nguong tren
        // vet can: chi xet cau hinh hop le lo <= hi
        for (b = 0; b < 256; b = b + 1) begin
            lo = {b[7:4], 4'h0}; hi = {b[3:1], 5'h1F};
            if (lo <= hi)
                for (a = 0; a < 256; a = a + 1) kiem(a[7:0], b[7:0]);
        end
        // ccac chan uio_oe phai dung
        if (uio_oe !== 8'h01) begin errors = errors + 1; $display("LOI: uio_oe=%h", uio_oe); end

        $display("so phep kiem: %0d, loi: %0d", checks, errors);
        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("TESTS FAILED");
        $finish;
    end
endmodule
