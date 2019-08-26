#!/bin/bash

# ================================================
# Define the text formats / colors
# ================================================

# Define if colors are available
declare colorIsAvailable=$([ $(tput colors 2>/dev/null || echo 0) -ge 16 ] && [ -t 1 ])
if ${colorIsAvailable}
then
    # Text reset
    RCol='\e[0m';

    # Regular
    Bla='\e[0;30m';
    Red='\e[0;31m';
    Gre='\e[0;32m';
    Yel='\e[0;33m';
    Blu='\e[0;34m';
    Pur='\e[0;35m';
    Cya='\e[0;36m';
    Whi='\e[0;37m';

    # Bold
    BBla='\e[1;30m';
    BRed='\e[1;31m';
    BGre='\e[1;32m';
    BYel='\e[1;33m';
    BBlu='\e[1;34m';
    BPur='\e[1;35m';
    BPur='\e[1;35m';
    BCya='\e[1;36m';
    BWhi='\e[1;37m';

    # Underline
    UBla='\e[4;30m';
    URed='\e[4;31m';
    UGre='\e[4;32m';
    UYel='\e[4;33m';
    UBlu='\e[4;34m';
    UPur='\e[4;35m';
    UPur='\e[4;35m';
    UCya='\e[4;36m';
    UWhi='\e[4;37m';

    # High intensity
    IBla='\e[0;90m';
    IRed='\e[0;91m';
    IGre='\e[0;92m';
    IYel='\e[0;93m';
    IBlu='\e[0;94m';
    IPur='\e[0;95m';
    ICya='\e[0;96m';
    IWhi='\e[0;97m';

    # BoldHigh intense
    BIBla='\e[1;90m';
    BIRed='\e[1;91m';
    BIGre='\e[1;92m';
    BIYel='\e[1;93m';
    BIBlu='\e[1;94m';
    BIPur='\e[1;95m';
    BICya='\e[1;96m';
    BIWhi='\e[1;97m';

    # Background
    On_Bla='\e[40m';
    On_Red='\e[41m';
    On_Gre='\e[42m';
    On_Yel='\e[43m';
    On_Blu='\e[44m';
    On_Pur='\e[45m';
    On_Cya='\e[46m';
    On_Whi='\e[47m';

    # High intensity backgrounds
    On_IBla='\e[0;100m';
    On_IRed='\e[0;101m';
    On_IGre='\e[0;102m';
    On_IYel='\e[0;103m';
    On_IBlu='\e[0;104m';
    On_IPur='\e[0;105m';
    On_ICya='\e[0;106m';
    On_IWhi='\e[0;107m';
else
    # Text reset
    RCol='';

    # Regular
    Bla='';
    Red='';
    Gre='';
    Yel='';
    Blu='';
    Pur='';
    Cya='';
    Whi='';

    # Bold
    BBla='';
    BRed='';
    BGre='';
    BYel='';
    BBlu='';
    BPur='';
    BPur='';
    BCya='';
    BWhi='';

    # Underline
    UBla='';
    URed='';
    UGre='';
    UYel='';
    UBlu='';
    UPur='';
    UPur='';
    UCya='';
    UWhi='';

    # High intensity
    IBla='';
    IRed='';
    IGre='';
    IYel='';
    IBlu='';
    IPur='';
    ICya='';
    IWhi='';

    # BoldHigh intense
    BIBla='';
    BIRed='';
    BIGre='';
    BIYel='';
    BIBlu='';
    BIPur='';
    BICya='';
    BIWhi='';

    # Background
    On_Bla='';
    On_Red='';
    On_Gre='';
    On_Yel='';
    On_Blu='';
    On_Pur='';
    On_Cya='';
    On_Whi='';

    # High intensity backgrounds
    On_IBla='';
    On_IRed='';
    On_IGre='';
    On_IYel='';
    On_IBlu='';
    On_IPur='';
    On_ICya='';
    On_IWhi='';
fi