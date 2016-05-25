library verilog;
use verilog.vl_types.all;
entity testbench_Histogram is
    generic(
        num_rows        : integer := 32;
        num_cols        : integer := 32;
        full_frame_rows : integer := 36;
        full_frame_cols : integer := 36;
        invalidBorderWidthX: vl_notype;
        invalidBorderWidthY: vl_notype;
        num_bits_rgb    : integer := 12;
        output_width    : integer := 16;
        user_directory  : string  := "C:/Users/to300/GIT/ECE4063_Merlin_Tom_Project/TestBench/"
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of num_rows : constant is 1;
    attribute mti_svvh_generic_type of num_cols : constant is 1;
    attribute mti_svvh_generic_type of full_frame_rows : constant is 1;
    attribute mti_svvh_generic_type of full_frame_cols : constant is 1;
    attribute mti_svvh_generic_type of invalidBorderWidthX : constant is 3;
    attribute mti_svvh_generic_type of invalidBorderWidthY : constant is 3;
    attribute mti_svvh_generic_type of num_bits_rgb : constant is 1;
    attribute mti_svvh_generic_type of output_width : constant is 1;
    attribute mti_svvh_generic_type of user_directory : constant is 1;
end testbench_Histogram;
