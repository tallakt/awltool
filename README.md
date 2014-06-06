# AWL Tool

## Subcommands


### List files

Lists files in the source folder

    awltool ls ./path/to/project


### Pretty print awl file

Prints the contents of an AWL file or DB with addresses.

    awltool pp /path/to/file.awl
    awltool pp ./path/to/project:DB1200
    awltool pp ./path/to/project:"My DB"


### Dump raw AWL code

Dumps core from an Step7 program folder

    awltool cat ./path/to/project:"My function block"


### Symlist

Prints the symlist of a project

    awltool symbols -f ./path/to/project

### DB compare

Lists the contents of two DBS side by side for comparison

    awltool compare -a ./path/to/first/project:DB123:A.B.C -b ./path/to.second/project:DB234:B
    awltool compare -a ./path/to/first/project:DB123.A.B.C -b ./path/to/file.awl

Note that a general diff between two blocks in AWL source format may be performed from the command line by using two pipes like this:

    $ diff <(awltool dump DB123) <(cat ./path/to/awl/file.awl)

### Git integration

All commands support git integration like

    awltool dump HEAD^:./path/to/project:"My function block"

Path specs are done by having git:path:block_name


### Zip file integration

An archived zip file from Step7 may be processed directly by issuing the name of the zip file as a path:

    awltool dump ./path/to/zip/file.zip:"My function block"



### HTTP support

Any zip file reference or a `.awl` file may be supplied as a http reference that is downloaded and processed directly.

    awltool dump http://www.host.com/file.zip:"My function block"

### Read actual values from PLC

A DB may be read from the PLC using the following command.


    awltool read ./path/to/project:DB123 --address 192.168.1.1

It will use the Step7 protocol for this.


  
