#!/bin/bash
#Student Name-Dinuka Liyanage
#Student Number-10601996

#This code was developed by using the lecturer materials provided through week 1-5.
#I have piped the conditions of checking the 6 requirements mentioned in the assignment which would reduce the number of coding needed to work this program properly and it's effeicient. 
#The main commmands I have used in this code are 'read' command to read user input, 'if' statement to check if the user input file exist indirectory, 'grep' command to search for a string with specific requirements, 'wc' command to cound number of passwords in the file

RED='\033[0;31m' #to set the text color red
BLUE='\033[0;34m' #to set the text color Blue
GREEN='\033[0;32m' #to set the text color Green
NC='\033[0m' #to set the text color to end from previous formatting

accepted_count=0 #set the accepted passwords counter to 0
rejected_count=0 #set the rejected passwords counter to 0

read -p "Enter the name of the candidate password file(including ext): " txt #read the user input with using '-p' to show text prompting user to what to input and store it in a variable named 'txt'
if [ ! -f "$txt" ]; then #'if' codition checks wether the file user entered exists in the current directory using '-f' flag to check if this is a file
    echo "No the file does not exist or empty" #If no such file is found/ condition is true, then the echo command display file not found in the terminal
    exit 1 #exit 1 is used to terminate the program
fi

echo -e "  ${BLUE}Password      Status${NC}" #to display the header

#While loop reads line by line the words and does the requirement check. The first word read from the file is echoed and sent through a pipe to'grep' filter '-E' extended regualr expression of a word that has atleast 10 characters or more The length requirement is showed using curly brackets and the minimum length, which is 10. And if any matches are found it is piped to another requriement check using grep command with providing thr requirements which are 1 uppercase letter which can be shwon using the range [A-Z] and in the same manner any matches are piped to another grep command to find a lowercase letter and a digit from 1-9. 
#If any matches were found by then it is again piped to check the final validity which are the characters that should be not included in the password. This is acheived using '-v' which gives inverse of the matches found through the grep command.
#And then if any matches of strings that are found it will be printed in the terminal and the accepted passwords counter increments by one. If the word does not match, then it is echoed with red text as rejected and rejected passowrds counter increments by one.
while read password; do 
    if echo "$password" | grep -E "^.{10,}$" | grep -E "[A-Z]+" | grep -E "[a-z]+" | grep -E "[0-9]+" | grep -E "[!#-_\$\?\.\,:;+*=d|&%~@^<>]+" | grep -vE "[\\\/\(\)\[\]\{\}\`\ \]+"; then
        echo -e "$password:  ${GREEN}Accepted${NC}" 
        ((accepted_count++))
    else 
        echo -e "$password: ${RED}Rejected${NC}"
        ((rejected_count++))
    fi
done < "$txt" #<"$txt directly tells where to search for the while command/inputs the words from the file"

pswds=$(cat "$txt" | wc -l) #gets the total number of words in the file
echo "Out of $pswds passwords, $accepted_count passwords were accepted and $rejected_count were rejected." #prints the summary of out of how many passwords how many were accepted and how many were rejected. '$' sign with variable is used here to let the program know that this is a variable.

#However there are some issues  with the code. It does not read the last line of the file. And some files wont be prited in the proper alignment and sometimes the password does print twice repeatedly.  I have found no solutions to fix this issue. Apologies for the mistake.







