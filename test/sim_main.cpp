// DESCRIPTION: Verilator: Verilog example module
//
// This file ONLY is placed under the Creative Commons Public Domain, for
// any use, without warranty, 2017 by Wilson Snyder.
// SPDX-License-Identifier: CC0-1.0
//======================================================================

// For std::unique_ptr
#include <memory>

// Include common routines
#include <verilated.h>

// Include model header, generated from Verilating "top.v"
#include "Vtestbench.h"

#include "Vtestbench__Dpi.h"

//extern "C" void LOAD_TEST (int);

// Legacy function required only so linking works on Cygwin and MSVC++
double sc_time_stamp() { return 0; }

//extern 'C' export "DPI-C" task LOAD_TEST(int TESTID);
//export "DPI-C" task EVAL_TEST(int TESTID, svBit test_status);
uint8_t test_status = 0;
svBitVecVal test_id;
svLogicVecVal* test_id1;

int main(int argc, char** argv, char** env) {
    // This is a more complicated example, please also see the simpler examples/make_hello_c.

    // Prevent unused variable warnings
    if (false && argc && argv && env) {}

    // Create logs/ directory in case we have traces to put under it
    Verilated::mkdir("logs");

    // Construct a VerilatedContext to hold simulation time, etc.
    // Multiple modules (made later below with Vclarvi_sim) may share the same
    // context to share time, or modules may have different contexts if
    // they should be independent from each other.

    // Using unique_ptr is similar to
    // "VerilatedContext* contextp = new VerilatedContext" then deleting at end.
    const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};

    // Set debug level, 0 is off, 9 is highest presently used
    // May be overridden by commandArgs argument parsing
    contextp->debug(0);

    // Randomization Reset_n policy
    // May be overridden by commandArgs argument parsing
    contextp->randReset(2);

    // Verilator must compute traced signals
    contextp->traceEverOn(true);

    // Pass arguments so Verilated code can see them, e.g. $value$plusargs
    // This needs to be called before you create any model
    contextp->commandArgs(argc, argv);

    // Construct the Verilated model, from Vclarvi_sim.h generated from Verilating "top.v".
    // Using unique_ptr is similar to "Vclarvi_sim* top = new Vclarvi_sim" then deleting at end.
    // "TOP" will be the hierarchical name of the module.
    const std::unique_ptr<Vtestbench> top{new Vtestbench{contextp.get(), "TOP"}};

    // Set Vclarvi_sim's input signals
    top->Reset_n = !1;
    top->clock = 1;
    uint32_t count_cyc = 0;

    // Simulate until $finish
    //while (!contextp->gotFinish()) {
    while (count_cyc < 2000 && test_status == 0) {
        // Historical note, before Verilator 4.200 Verilated::gotFinish()
        // was used above in place of contextp->gotFinish().
        // Most of the contextp-> calls can use Verilated:: calls instead;
        // the Verilated:: versions simply assume there's a single context
        // being used (per thread).  It's faster and clearer to use the
        // newer contextp-> versions.

        contextp->timeInc(1);  // 1 timeprecision period passes...
        // Historical note, before Verilator 4.200 a sc_time_stamp()
        // function was required instead of using timeInc.  Once timeInc()
        // is called (with non-zero), the Verilated libraries assume the
        // new API, and sc_time_stamp() will no longer work.

        // Toggle a fast (time/2 period) clock
        top->clock = !top->clock;

        // Toggle control signals on an edge that doesn't correspond
        // to where the controls are sampled; in this example we do
        // this only on a negedge of clk, because we know
        // Reset_n is not sampled there.
        //if (!top->clock) {
        //    if (contextp->time() > 1 && contextp->time() < 10) {
        //        top->Reset_n = !1;  // Assert Reset_n
        //    } else {
        //        top->Reset_n = !0;  // Deassert Reset_n
        //    }
        //}
        //int test_id1 = 0;
        if(count_cyc > 100) {
            test_id = 0;
            //printf("Before svGetScopeFromName\n");
            svSetScope(svGetScopeFromName("TOP.testbench"));
            //printf("Before LOAD_TEST\n");
            LOAD_TEST(&test_id);
            top->Reset_n = !0;
        } else if (count_cyc > 200) {
            test_id = 0;
            EVAL_TEST(&test_id, &test_status);
        }

        count_cyc ++;
        // Evaluate model
        // (If you have multiple models being simulated in the same
        // timestep then instead of eval(), call eval_step() on each, then
        // eval_end_step() on each. See the manual.)
        top->eval();


        // Read outputs
        VL_PRINTF("[%" VL_PRI64 "d] clk=%x rst=%x \n",
                  contextp->time(), top->clock, top->Reset_n);
    }

    // Final model cleanup
    top->final();

    // Coverage analysis (calling write only after the test is known to pass)
#if VM_COVERAGE
    Verilated::mkdir("logs");
    contextp->coveragep()->write("logs/coverage.dat");
#endif

    // Return good completion status
    // Don't use exit() or destructor won't get called
    return 0;
}

