echo "************* LEX **********"                                  		&&
flex scanner.l                                          &&
echo "************* OK ************"         			  		&&

echo "********** BISON **********"           	&&
bison -d -v parser.y                                    &&
echo "****** OK ****"				                &&

echo "************ GCC ********"                            			&&
gcc tablasimbolos.c parser.tab.c lex.yy.c -lfl -ggdb -o final -Wall -Wextra   &&
echo "********** OK *********"         					&&
