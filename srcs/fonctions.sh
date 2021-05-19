#!/bin/bash

copy()
{
cpy=$( cp ${DIR}get_next_line${1}.c ${DIR}get_next_line${1}.h ${DIR}get_next_line_utils${1}.c . )
[ $? -ne 0 ] && echo -e "\n\n===> Check the variable DIR in the gnl_checker.sh file..." && exit 0
}


compil()
{
compil=$( gcc -Wall -Wextra -Werror -D BUFFER_SIZE=${BUFFER_SIZE} get_next_line${1}.c get_next_line_utils${1}.c srcs/main${1}.c -o ${BUFFER_SIZE}${1}.out 2>> "$error" )
[ -n "$compil" ] && { printf "${red}Compilation failed\n"; exit 0; }
}


check_sig()
{
if [ $sig -eq 134 ] ; then
	printf "${red}A" && nb_errors=$(( $nb_errors + 1 ))
elif [ $sig -eq 138 ] ; then
	printf "${red}B" && nb_errors=$(( $nb_errors + 1 ))
elif [ $sig -eq 139 ] ; then
	printf "${red}S" && nb_errors=$(( $nb_errors + 1 ))
elif [ $sig -eq 142 ] ; then
	printf "${red}T" && nb_errors=$(( $nb_errors + 1 ))
fi
}


diff_tests()
{
if [ ! "$file" = "one_big_line_no_newline" ] ; then
	test=$( ./${BUFFER_SIZE}${1}.out "files/$file" 2>> "$error" )
	sig=$?
	if [ $sig -eq 0 ] ; then
		cmp=$( cat "files/$file" 2>> "$error" )
		[ "$test" = "$cmp" ] && printf "${green}√" || { printf "${red}❌"; nb_errors=$(( $nb_errors + 1 )); }
	else
		check_sig
	fi
fi

test=$( ./${BUFFER_SIZE}${1}.out "files/$file" 2>> "$error" | wc -l )
sig=$?
if [ $sig -eq 0 ] ; then
	cmp=$( cat "files/$file" | wc -l 2>> "$error" )
	[ $test -eq $cmp ] && printf "${green}√" || { printf "${red}❌"; nb_errors=$(( $nb_errors + 1 )); }
else
	check_sig
fi
}


memory_check()
{
check_val=$( command -v valgrind 2>> "$error" )
if [ "$check_val" = "" ] ; then
	printf "${grey}\033[60GValgrind missing..."
else
	if [ "$1" = "neg_fd" ] ; then
		mem_check=$( valgrind ./${1}.out &> "$leak" )
	elif [ "$1" = "multi_fd" ] ; then
		mem_check=$( valgrind ./${BUFFER_SIZE}_multi_fd.out &> "$leak" )
	else
		mem_check=$( valgrind ./${BUFFER_SIZE}${1}.out "files/$file" &> "$leak" )
	fi
	sig=$?
	if [ $sig -eq 0 ] ; then
		no_leaks=$( cat "$leak" | grep "no leaks are possible" | wc -l )
		if [ $no_leaks -gt 0 ] ; then
				printf "\033[60G${green}√"
		else
			printf "\033[60G${red}memory leak"
			nb_errors=$(( $nb_errors + 1 ))
			cat "$leak" >> "$error"
		fi
	else
		check_sig
	fi
fi
}


run_tests()
{
copy "$1"
size_list=($RANDOM 42 10 1 10000000 32)
files=$( ls files/ )
files=$( echo "$files" | tr '\n' ' ')
for file in ${files[@]} ; do
	printf "${purple}< $file >\033[40G"
	nb_errors=0
	for BUFFER_SIZE in ${size_list[@]} ; do
		compil "$1"
		diff_tests "$1"
	done
	memory_check "$1"
	[ $nb_errors -eq 0 ] && printf "\033[90G${green}[ OK ]\n" || { printf "\033[90G${red}[ KO ]\n"; fail=$(( $fail + 1 )); }
done
negative_fd_test "$1"
}


multi_fd_test()
{
nb_errors=0
printf "${purple}\nMulti File Descriptor Test : \033[40G"
for BUFFER_SIZE in ${size_list[@]} ; do
	compil=$( gcc -Wall -Wextra -Werror -D BUFFER_SIZE=${BUFFER_SIZE} get_next_line_bonus.c get_next_line_utils_bonus.c srcs/main_multi_fd.c -o ${BUFFER_SIZE}_multi_fd.out 2>> "$error" )
	multi_test=$( ./${BUFFER_SIZE}_multi_fd.out 2>> "$error" )
	sig=$?
	if [ $sig -eq 0 ] ; then
		expected=$( cat srcs/output/multi_fd.out )
		[ "$multi_test" = "$expected" ] && printf "${green}√" || { printf "${red}❌"; nb_errors=$(( $nb_errors + 1 )); }
	else
		check_sig
	fi
done
memory_check "multi_fd"
[ $nb_errors -eq 0 ] && printf "\033[90G${green}[ OK ]\n" || { printf "\033[90G${red}[ KO ]\n"; fail=$(( $fail + 1 )); }
}


negative_fd_test()
{
nb_errors=0
printf "${purple}< negative_file_descriptor >\033[40G"
compil=$( gcc -Wall -Wextra -Werror -D BUFFER_SIZE=32 get_next_line${1}.c get_next_line_utils${1}.c srcs/main_neg_fd${1}.c -o neg_fd.out 2>> "$error" )
neg_fd=$( ./neg_fd.out 2>> "$error" )
[ "$neg_fd" = "" ] && printf "${green}√" || { printf "${red}❌"; nb_errors=$(( $nb_errors + 1 )); }
memory_check "neg_fd"
[ $nb_errors -eq 0 ] && printf "\033[90G${green}[ OK ]\n" || { printf "\033[90G${red}[ KO ]\n"; fail=$(( $fail + 1 )); }
}

