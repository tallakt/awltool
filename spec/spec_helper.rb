$:.push File.expand_path("../lib", __FILE__)


ELEMENTARY_DATA_TYPES = <<EOF
VAR_INPUT // Keyword for input variable
in1 : INT; // Variable name and type are separated by ":"
in3 : DWORD; // Every variable declaration is terminated with a semicolon
in2 : INT := 10; // Optional setting for an initial value in the declaration
END_VAR // End declaration of variables of the same declaration type
VAR_OUTPUT // Keyword for output variable
out1 : WORD;
END_VAR // Keyword for temporary variable
VAR_TEMP
temp1 : INT;
END_VAR
EOF


DATA_TYPE_ARRAY = <<EOF
VAR_INPUT // Input variable
array1 : ARRAY [1..20] of INT; // array1 is a one-dimensional array
array2 : ARRAY [1..20, 1..40] of DWORD; // array2 is a two-dimensional array
END_VAR
EOF

DATA_TYPE_STRUCTURE = <<EOF
VAR_OUT // Output variable
OUTPUT1: STRUCT // OUTPUT1 has the data type STRUCT
var1 : BOOL; // Element 1 of the structure
var2 : DWORD; // Element 2 of the structure
END_STRUCT; // End of the structure
END_VAR
EOF

EXAMPLE_OB = <<EOF
ORGANIZATION_BLOCK OB1
TITLE = Example for OB1 with different block calls
//The 3 networks show block calls
//with and without parameters
{S7_pdiag := 'true'} //System attribute for blocks
AUTHOR Siemens
FAMILY Example
NAME Test_OB
VERSION 1.1
VAR_TEMP
Interim value : INT; // Buffer
END_VAR
BEGIN
NETWORK
TITLE = Function call transferring parameters
// Parameter transfer in one line
CALL FC1 (param1 :=I0.0,param2 :=I0.1);
NETWORK
TITLE = Function block call
// transferring parameters
// Parameter transfer in more than one line
CALL Traffic light control , DB6 ( // Name of FB, instance data block
dur_g_p := S5T#10S, // Assign actual values to parameters
del_r_p := S5T#30S,
starter := TRUE,
t_dur_y_car := T 2,
t_dur_g_ped := T 3,
t_delay_y_car := T 4,
t_dur_r_car := T 5,
t_next_red_car := T 6,
r_car := "re_main", // Quotation marks show symbolic
y_car := "ye_main", // names entered in symbol table
g_car := "gr_main",
r_ped := "re_int",
g_ped := "gr_int");
NETWORK
TITLE = Function block call
// transferring parameters
// Parameter transfer in one line
CALL FB10, DB100 (para1 :=I0.0,para2 :=I0.1);
END_ORGANIZATION_BLOCK
EOF

EXAMPLE_FUNCTION = <<EOF
FUNCTION FC1: VOID
// Only due to call
VAR_INPUT
param1 : bool;
param2 : bool;
END_VAR
begin
end_function
FUNCTION FC2 : INT
TITLE = Increment number of items
// As long as the value transferred is < 1000, this function
// increases the transferred value. If the number of items
// exceeds 1000, "-1" is returned via the return value
// for the function (RET_VAL).
AUTHOR Siemens
FAMILY Throughput check
NAME : INCR_ITEM_NOS
VERSION : 1.0
VAR_IN_OUT
ITEM_NOS : INT; // No. of items currently manufactured
END_VAR
BEGIN
NETWORK
TITLE = Increment number of items by 1
// As long as the current number of items lies below 1000,
// the counter can be increased by 1
L ITEM_NOS; L 1000; // Example for more than one
> I; JC ERR; // statement in a line.
L 0; T RET_VAL;
L ITEM_NOS; INC 1; T ITEM_NOS; BEU;
ERR: L -1;
T RET_VAL;
END_FUNCTION
FUNCTION FC3 {S7_pdiag := 'true'} : INT
TITLE = Increment number of items
// As long as the value transferred is < 1000, this function
//increases the transferred value. If the number of items
//exceeds 1000, "-1" is returned via the return value
//for the function (RET_VAL).
//
//RET_VAL has a system attribute for parameters here
Creating STL Source Files
Programming with STEP 7
13-24 A5E00706944-01
AUTHOR : Siemens
FAMILY : Throughput check
NAME : INCR_ITEM_NOS
VERSION : 1.0
VAR_IN_OUT
ITEM_NOS {S7_visible := 'true'}: INT; // No. of items currently manufactured
//System attributes for parameters
END_VAR
BEGIN
NETWORK
TITLE = Increment number of items by 1
// As long as the cur rent number of items lies below 1000,
// the counter can be increased by 1
L ITEM_NOS; L 1000; // Example for more than one
> I; JC ERR; // statement in a line.
L 0; T RET_VAL;
L ITEM_NOS; INC 1; T ITEM_NOS; BEU;
ERR: L -1;
T RET_VAL;
END_FUNCTION
EOF


EXAMPLE_FUNCTION_BLOCK = <<EOF
FUNCTION_BLOCK FB6
TITLE = Simple traffic light switching
// Traffic light control of pedestrian crosswalk
// on main street
{S7_m_c := 'true'} //System attribute for blocks
AUTHOR : Siemens
FAMILY : Traffic light
NAME : Traffic light01
VERSION : 1.3
VAR_INPUT
starter : BOOL := FALSE; // Cross request from pedestrian
t_dur_y_car : TIMER; // Duration green for pedestrian
t_next_r_car : TIMER; // Duration between red phases for cars
t_dur_r_car : TIMER;
number {S7_server := 'alarm_archiv'; S7_a_type := 'alarm_8'} :DWORD;
// Number of cars
// number has system attributes for parameters
END_VAR

VAR_OUTPUT

g_car : BOOL := FALSE; // GREEN for cars_

END_VAR

VAR
condition : BOOL := FALSE; // Condition red for cars
END_VAR
BEGIN
NETWORK
TITLE =Condition red for main street traffic
// After a minimum duration has passed, the request for green at the
// pedestrian crosswalk forms the condition red
// for main street traffic.
     A(;
       A #starter; // Request for green at pedestrian crosswalk and
       A #t_next_r_car; // time between red phases up
       O #condition; // Or condition for red
      );
      AN #t_dur_y_car; // And currently no red light
      = #condition; // Condition red
        NETWORK
      TITLE = Green light for main street traffic
      AN #condition; // No condition red for main street traffic
      = #g_car; // GREEN for main street traffic
        Creating STL Source Files
      Programming with STEP 7
      13-26 A5E00706944-01
      NETWORK
      TITLE = Duration of yellow phase for cars
      // Additional program required for controlling
      // traffic lights
      END_FUNCTION_BLOCK
      FUNCTION_BLOCK FB10
      VAR_INPUT
      para1 : bool;
      para2: bool;
end_var
begin
end_function_block
data_block db10
FB10
begin
end_data_block
data_block db6
FB6
begin
end_data_block
EOF

EXAMPLE_DATA_BLOCK = <<EOF
DATA_BLOCK DB10
TITLE = DB Example 10
STRUCT
aa : BOOL; // Variable aa of type BOOL
bb : INT; // Variable bb of type INT
cc : WORD;
END_STRUCT;
BEGIN // Assignment of initial values
aa := TRUE;
bb := 1500;
END_DATA_BLOCK
EOF

EXAMPLE_DB_WITH_UDT = <<EOF
DATA_BLOCK DB20
TITLE = DB (UDT) Example
UDT 20 // Associated user-defined data type
BEGIN
start := TRUE; // Assignment of initial values
setp := 10;
END_DATA_BLOCK
EOF

EXAMPLE_DB_WITH_FB = <<EOF
DATA_BLOCK DB30
TITLE = DB (FB) Example
FB30 // Associated function block
BEGIN
start := TRUE; // Assignment of initial values
setp := 10;
END_DATA_BLOCK
EOF


EXAMPLE_UDT = <<EOF
TYPE UDT20
STRUCT
start : BOOL; // Variable of type BOOL
setp : INT; // Variable of type INT
value : WORD; // Variable of type WORD
END_STRUCT;
END_TYPE
EOF

