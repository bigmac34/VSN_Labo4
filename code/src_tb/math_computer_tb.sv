/******************************************************************************
Project Math_computer

File : math_computer_tb.sv
Description : This module implements a test bench for a simple
              mathematic calculator.
              Currently it is far from being efficient nor useful.

Author : Y. Thoma
Team   : REDS institute

Date   : 13.04.2017

| Modifications |--------------------------------------------------------------
Ver    Date         Who    Description
1.0    13.04.2017   YTA    First version

******************************************************************************/

`include "math_computer_macros.sv"
`include "math_computer_itf.sv"
`include "class_variables.sv"

module math_computer_tb#(integer testcase = 0,
                         integer errno = 0);

    // Déclaration et instanciation des deux interfaces
    math_computer_input_itf input_itf();
    math_computer_output_itf output_itf();

    // Seulement deux signaux
    logic      clk = 0;
    logic      rst;

    // instanciation du compteur
    math_computer dut(clk, rst, input_itf, output_itf);

	// Création de l'objet InDUT
	InDUTspec inputDUT = new;

    // Génération de l'horloge
    always #5 clk = ~clk;

    // clocking block
    default clocking cb @(posedge clk);
        output #3ns rst,
               a            = input_itf.a,
               b            = input_itf.b,
               c            = input_itf.c,
               input_valid  = input_itf.valid,
               output_ready = output_itf.ready;
        input  input_ready  = input_itf.ready,
               result       = output_itf.result,
               output_valid = output_itf.valid;
    endclocking

	// Covergroup
	covergroup cov_group_in;
		cov_a: coverpoint input_itf.a {
			wildcard bins petit = {`DATASIZE'b00000000000000??};
			wildcard bins grand = {`DATASIZE'b11??????????????};
			bins autres = default;
		}
		cov_b: coverpoint input_itf.b {
			wildcard bins petit = {`DATASIZE'b00000000000000??};
			wildcard bins grand = {`DATASIZE'b11??????????????};
			bins autres = default;
		}
		cov_c: coverpoint input_itf.c {
			bins moyen = {[1000:2000]};
			bins autres = default;
		}
		cov_cross: cross cov_a, cov_b;
	endgroup

	covergroup cov_group_out;
		cov_result: coverpoint output_itf.result;
	endgroup

	cov_group_in cg_inst_in = new;
	cov_group_out cg_inst_out = new;

	always @ (cb.a) cg_inst_in.sample();
	always @ (cb.b) cg_inst_in.sample();
	always @ (cb.c) cg_inst_in.sample();

	always @ (cb.result) cg_inst_out.sample();

    task test_case0();
        $display("Let's start first test case");
        cb.a <= 0;
        cb.b <= 0;
        cb.c <= 0;
        cb.input_valid  <= 0;
        cb.output_ready <= 0;

        ##1;
        // Le reset est appliqué 5 fois d'affilée
        repeat (5) begin
            cb.rst <= 1;
            ##1 cb.rst <= 0;
            ##10;
        end

        repeat (10) begin
            cb.input_valid <= 1;
            cb.a <= 1;
            ##1;
            ##($urandom_range(100));
            cb.output_ready <= 1;
        end
    endtask

	// Exercice 1
    task test_case1();
        $display("Let's start second test case");
        cb.a <= 0;
        cb.b <= 0;
        cb.c <= 0;
        cb.input_valid  <= 0;
        cb.output_ready <= 0;

        ##1;
        // Le reset est appliqué 5 fois d'affilée
        repeat (5) begin
            cb.rst <= 1;
            ##1 cb.rst <= 0;
            ##10;
        end

        repeat (10) begin
			cb.output_ready <= 1;
			##1;
			cb.output_ready <= 0;
			##1;
        	cb.a <= $random;
        	cb.b <= $random;
			if (cb.input_ready == 1)
				cb.input_valid <= 1;
			##1;
			cb.input_valid <= 0;
			##($urandom_range(100));
        end
    endtask

	task test_case2();
		$display("Let's start third test case");
		if(!inputDUT.randomize()) $error(" No solutions for randomize");

		cb.a <= 0;
		cb.b <= 0;
		cb.c <= 0;
		cb.input_valid  <= 0;
		cb.output_ready <= 0;

		##1;
		// Le reset est appliqué 5 fois d'affilée
		repeat (5) begin
			cb.rst <= 1;
			##1 cb.rst <= 0;
			##10;
		end

		do
			begin
				cb.output_ready <= 1;
				##1;
				cb.output_ready <= 0;
				##1;
				// randomisation des valeurs
				assert (inputDUT.randomize()) else $error(" No solutions for randomize");

				cb.a <= inputDUT.a;
				cb.b <= inputDUT.b;
				cb.c <= inputDUT.c;

				if (cb.input_ready == 1)
					cb.input_valid <= 1;
				##1;
				cb.input_valid <= 0;

				##($urandom_range(100));
			end
		//while (cg_inst_in.get_inst_coverage() < 100);
		while (1);
	endtask

	task wait_for_coverage();
		do
			@(posedge clk);
		while ((cg_inst_in.get_inst_coverage() < 100) || (cg_inst_out.get_inst_coverage() < 100));
	endtask

    // Programme lancé au démarrage de la simulation
    program TestSuite;
        initial begin
            if (testcase == 0)
                test_case0();
            else if (testcase == 1)
                test_case1();
			else if (testcase == 2)
				begin
					fork
						test_case2();
						wait_for_coverage();
					join_any
					disable fork;
				end
            else
                $display("Ach, test case not yet implemented");
            $display("done!");
		 	$display("Ending with input coverage : %f", cg_inst_in.get_inst_coverage());
			$display("Ending with output coverage : %f", cg_inst_out.get_inst_coverage());

            $stop;
        end
    endprogram

endmodule
