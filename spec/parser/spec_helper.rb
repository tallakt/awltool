# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)


ELEMENTARY_DATA_TYPES = <<EOF
VAR_INPUT
  in1 : INT ;	// Variable name and type are separated by ":"
  in3 : DWORD ;	// Every variable declaration is terminated with a semicolon
  in2 : INT  := 10;	// Optional setting for an initial value in the declaration
// End declaration of v
END_VAR
VAR_OUTPUT
  out1 : WORD ;	// Keyword for temporary variable
END_VAR
VAR_TEMP
  temp1 : INT ;	
END_VAR
EOF


DATA_TYPE_ARRAY = <<EOF
VAR_INPUT
  array1 : ARRAY  [1 .. 20 ] OF INT ;	// array1 is a one-dimensional array
  array2 : ARRAY  [1 .. 20, 1 .. 40 ] OF DWORD ;	// array2 is a two-dimensional array
END_VAR
EOF

DATA_TYPE_STRUCTURE = <<EOF
VAR_OUTPUT
  OUTPUT1 : STRUCT 	// OUTPUT1 has the data type STRUCT
   var1 : BOOL ;	// Element 1 of the structure
   var2 : DWORD ;	// Element 2 of the structure
  END_STRUCT ;	// End of the structure
END_VAR
EOF

EXAMPLE_OB = <<EOF
ORGANIZATION_BLOCK OB 1
TITLE = Example for OB1 with different block calls
//The 3 networks show block calls
//with and without parameters
//System attribute for blocks
{ S7_pdiag := 'true' }
AUTHOR : Siemens
FAMILY : Example
NAME : Test_OB
VERSION : 1.1


VAR_TEMP
  Interim_value : INT ;	// Buffer
END_VAR
BEGIN
NETWORK
TITLE = Function call transferring parameters
// Parameter transfer in one line
      CALL FC     1 (
           param1                   := "re_main",
           param2                   := "ye_main");
NETWORK
TITLE = Function block call
// transferring parameters
// Parameter transfer in more than one line
      CALL "Traffic Light Control" , DB     6 (// Name of FB, instance data block
           dur_g_p                  := S5T_10S,// Assign actual values to parameters
           del_r_p                  := S5T_30S,
           starter                  := TRUE,
           t_dur_y_car              := T      2,
           t_dur_g_ped              := T      3,
           t_delay_y_car            := T      4,
           t_dur_r_car              := T      5,
           t_next_red_car           := T      6,
           r_car                    := "re_main",// Quotation marks show symbolic
           y_car                    := "ye_main",// names entered in symbol table
           g_car                    := "gr_main",
           r_ped                    := "re_int",
           g_ped                    := "gr_int");
NETWORK
TITLE = Function block call
// transferring parameters
// Parameter transfer in one line
      CALL FB    10 , DB   100 (
           para1                    := "re_main",
           para2                    := "ye_main");
END_ORGANIZATION_BLOCK

(*$PDIAG <?xml version='1.0' encoding='UTF-8'?>
<PDIAGDATA>
<Unit Block="OB1" Type="8" Num="1" TypeBType="0" TypeBNum="0">
<At id="1001">OB1</At>
<At id="1003">06/06/2014 12:46:52 PM</At>
<At id="1004">06/06/2014 12:46:59 PM</At>
<At id="6109D">OB1</At>
<At id="8006109D">OB1</At>
<At id="6100E">3</At>
</Unit>
</PDIAGDATA> *)
EOF

EXAMPLE_FUNCTION = <<EOF
FUNCTION FC 1 : VOID
TITLE =
// Only due to call
VERSION : 0.0


VAR_INPUT
  param1 : BOOL ;	
  param2 : BOOL ;	
END_VAR
BEGIN
END_FUNCTION

FUNCTION FC 2 : INT
TITLE = Increment number of items
// As long as the value transferred is < 1000, this function
// increases the transferred value. If the number of items
// exceeds 1000, "-1" is returned via the return value
// for the function (RET_VAL).
AUTHOR : Siemens
NAME : INCRTNOS
VERSION : 1.0


VAR_IN_OUT
  ITEM_NOS : INT ;	// No. of items currently manufactured
END_VAR
BEGIN
NETWORK
TITLE = Increment number of items by 1
// As long as the current number of items lies below 1000,
// the counter can be increased by 1
      L     _ITEM_NOS; 
      L     1000; // Example for more than one
      JC    ERR; // statement in a line.
      L     0; 
      T     _RET_VAL; 
      L     _ITEM_NOS; 
      INC   1; 
      T     _ITEM_NOS; 
      BEU   ; 
ERR:  L     -1; 
      T     _RET_VAL; 
END_FUNCTION

FUNCTION FC 3 : INT
TITLE = Increment number of items
// As long as the value transferred is < 1000, this function
//increases the transferred value. If the number of items
//exceeds 1000, "-1" is returned via the return value
//for the function (RET_VAL).
//
//RET_VAL has a system attribute for parameters here
//Creating STL Source Files
//Programming with STEP 7
{ S7_pdiag := 'true' }
AUTHOR : Siemens
FAMILY : Throughp
NAME : GOERBA
VERSION : 1.0


VAR_IN_OUT
  ITEM_NOS { S7_visible := 'true' }: INT ;	// No. of items currently manufactured
//System attributes for parameters
END_VAR
BEGIN
NETWORK
TITLE = Increment number of items by 1
// As long as the cur rent number of items lies below 1000,
// the counter can be increased by 1
      L     _ITEM_NOS; 
      L     1000; // Example for more than one
      >I    ; 
      JC    ERR; // statement in a line.
      L     0; 
      T     _RET_VAL; 
      L     _ITEM_NOS; 
      INC   1; 
      T     _ITEM_NOS; 
      BEU   ; 
ERR:  L     -1; 
      T     _RET_VAL; 
END_FUNCTION
EOF


EXAMPLE_FUNCTION_BLOCK = <<EOF
FUNCTION_BLOCK FB 60
TITLE = Simple traffic light switching
// Traffic light control of pedestrian crosswalk
// on main street
//System attribute for blocks
{ S7_m_c := 'true' }
AUTHOR : Siemens
FAMILY : Trafight
NAME : Trafht01
VERSION : 1.3


VAR_INPUT
  starter : BOOL ;	// Cross request from pedestrian
  t_dur_y_car : TIMER ;	// Duration green for pedestrian
  t_next_r_car : TIMER ;	// Duration between red phases for cars
  t_dur_r_car : TIMER ;	
  number { S7_server := 'alarm_archiv'; S7_a_type := 'alarm_8' }: DWORD ;	// Number of cars
// number has system attributes for parameters
END_VAR
VAR_OUTPUT
  g_car : BOOL ;	// GREEN for cars_
END_VAR
VAR
  condition : BOOL ;	// Condition red for cars
END_VAR
BEGIN
NETWORK
TITLE =Condition red for main street traffic
// After a minimum duration has passed, the request for green at the
// pedestrian crosswalk forms the condition red
// for main street traffic.
      A(    ; 
      A     _starter; // Request for green at pedestrian crosswalk and
      A     _t_next_r_car; // time between red phases up
      O     _condition; // Or condition for red
      )     ; 
      AN    _t_dur_y_car; // And currently no red light
      =     _condition; // Condition red
NETWORK
TITLE = Green light for main street traffic

      AN    _condition; // No condition red for main street traffic
      =     _g_car; // GREEN for main street traffic
NETWORK
TITLE = Duration of yellow phase for cars
// Additional program required for controlling
// traffic lights
END_FUNCTION_BLOCK

(*$ALARM_SERVER <HEADERS STEP7_VERSION="262144" CODING="true"><LANGUAGE LCID="1044">Norwegian (Bokmål)</LANGUAGE><STD_LANGUAGE>1044</STD_LANGUAGE><HEADER PARENT="RkI2MA=="><VERSION>Q1BVX1dJREVfQUxBUk1OUg==</VERSION><STRUCTTYPE>1</STRUCTTYPE><ATTR_STATE>0</ATTR_STATE><PRODUCER>1</PRODUCER><ALARM NAME="bnVtYmVy"><ATTR_STATE>0</ATTR_STATE><ALARMNR>0</ALARMNR><ALARMTYPE>YWxhcm1fOA==</ALARMTYPE><DISPLAYGROUP>0</DISPLAYGROUP><SUBCOUNT>8</SUBCOUNT><RANGE>0</RANGE><PROTOCOL>0</PROTOCOL><SUBALARM ID="1"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM><SUBALARM ID="2"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM><SUBALARM ID="3"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM><SUBALARM ID="4"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM><SUBALARM ID="5"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM><SUBALARM ID="6"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM><SUBALARM ID="7"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM><SUBALARM ID="8"><ALARM_CLASS>1</ALARM_CLASS><ALARM_ART>1</ALARM_ART><QUITGROUP>0</QUITGROUP><PRIORITY>1</PRIORITY><QUIT>1</QUIT><TRIGGER_ACTION>0</TRIGGER_ACTION><ATTR_STATE>0</ATTR_STATE></SUBALARM></ALARM></HEADER></HEADERS> *)
EOF

EXAMPLE_DATA_BLOCK = <<EOF
DATA_BLOCK DB 10
TITLE = DB Example 10
VERSION : 0.0


  STRUCT 	
   aa : BOOL ;	// Variable aa of type BOOL
   bb : INT ;	// Variable bb of type INT
   cc : WORD ;	
  END_STRUCT ;	
BEGIN
   aa := TRUE; 
   bb := 1500; 
   cc := W_16_0; 
END_DATA_BLOCK
EOF

EXAMPLE_DB_WITH_UDT = <<EOF
DATA_BLOCK DB 20
TITLE = DB (UDT) Example
// Associated user-defined data type
VERSION : 0.0

 UDT 20
BEGIN
   start := TRUE; 
   setp := 10; 
   value := W_16_0; 
END_DATA_BLOCK
EOF

EXAMPLE_DB_WITH_FB = <<EOF
DATA_BLOCK DB 60
TITLE =
{ S7_m_c := 'true' }
VERSION : 0.0

 FB 60
BEGIN
   starter := FALSE; 
   t_dur_y_car := T 0; 
   t_next_r_car := T 0; 
   t_dur_r_car := T 0; 
   number := DW_16_0; 
   g_car := FALSE; 
   condition := FALSE; 
END_DATA_BLOCK
EOF


EXAMPLE_UDT = <<EOF
TYPE UDT 20


  STRUCT 	
   start : BOOL ;	// Variable of type BOOL
   setp : INT ;	// Variable of type INT
   value : WORD ;	// Variable of type WORD
  END_STRUCT ;	
END_TYPE
EOF

