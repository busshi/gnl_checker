#!/bin/bash

DIR="../get_next_line/"

### COLORS
red="\e[1;31m"
green="\e[1;32m"
white="\e[0;m"
purple="\e[0;35m"
orange="\e[0;33m"
grey="\e[1;30m"

error="error.txt"
leak="leak.txt"

#######################
clear
source srcs/fonctions.sh
#######################


printf "${orange}____________________________________________________________________________________________________________\n"
printf "_________________________________________________ GNL CHECKER ______________________________________________\n"
printf "____________________________________________________________________________________________________________\n\n"


### START TESTS
printf "${orange}FILES\033[40GTESTS\033[60GMEMORY LEAK\033[90GRESULT\n"

### RUN TESTS
fail=0
case $1 in
	"bonus")
		run_tests "_bonus"
		multi_fd_test
		;;
	"all")
		run_tests
		printf "\n\n${orange}BONUS PART :\n"
		run_tests "_bonus"
		multi_fd_test
		;;
	*)
		run_tests
		;;
esac



### PRINT RESULT
[ $fail -eq 0 ] && grade="${green}[ OK ]" || grade="${red}[ KO ]"
printf "\n\n${orange}>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> FINAL GRADE ${grade} ${orange}<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n"

[ "$1" != "bonus" -a "$1" != "all" -a $fail -eq 0 ] && printf "${purple}==> Try bonus part : ./gnl_checker.sh <bonus|all>\n\n"





### PRINT ERRORS
check_error=$( cat "$error" )
if [ "$check_error" != "" ] ; then
	printf "${orange}\nPrint generated errors during tests (y/n) ? ${white}"
        read
        [ "$REPLY" = "o" -o "$REPLY" = "y" ] && echo "$check_error"
fi



### CLEANING
rm -f get_next_line*.c get_next_line*.h get_next_line_utils*.c
rm -f "$error" "$leak"
rm -f *.out



exit 0
