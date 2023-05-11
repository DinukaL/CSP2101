#!/bin/bash

#Student Name-Dinuka Liyanage
#Student ID- 10601996

#The 'getpdf.sh' script is developed as an automation to download all the hyperlinked PDF files of a website when given an URL from the user. The script uses variety of commands utilities and techniques taught from weeks 1-8 lectures. 
#I have developed the code diving the code into three main components as the  main required function, the components required to fulfill the main fucntion and the other required components.
#Developing the code part by part(ex:retrieving URL and the flag option part) made the code to be easily developed. 
#The main commands used in this script are curl, grep, sed, awk, sort and zip.
#The codes functionality is explained in in-situ comments.


#To display the texts in preferred colors, I have used ANSI escape sequences that allows the words to have a color when displaying.
RED='\033[0;31m' 
BLUE='\033[0;34m' 
GREEN='\033[0;32m' 
NC='\033[0m'
#'OPTERROR' variable contains the error message if an invalid flag is passed along with './getpdf.sh'. '${RED}' is used to make the text color red and '${NC}' is used to end the text being red and set it to no color.
OPTERROR="${RED}Invalid Option error. Only -z for zip file is valid - exiting...${NC}"


#I have defined a function called 'remove_temps' which it's function is to remove all the temporary files created from the last run or from the current run at the beginning and at the end of the script.
#The first 'if'condtion removes a temporary file that is created from the script called 'pdfs.txt' the 'if' state ment with the flag '-f' checks whether the current directory has a file called 'pdfs.txt' and if it has, then using the 'rm'command the file is deleted from the directory.
#The second 'if' statement's functionality is same as the first one except, this time it removes the temporary file 'temp.txt'.
#Third 'if' statement removes the temporary created file 'downloads.txt'
#In total, there are three temporary files created from the script and they are removed using the funtion 'remove_temps'.
#This condtional testing with special operators was taught during the lecture 3.
remove_temps() {
  if [[ -f pdfs.txt ]]; then
    rm pdfs.txt 
  fi
  
  if [[ -f temp.txt ]]; then
    rm temp.txt
  fi
  
  if [[ -f pdfurls.txt ]]; then
    rm pdfurls.txt
  fi
  
  if [[ -f downloads.txt ]]; then
    rm downloads.txt
  fi
}


# The 'getsize' function is used to convert the downloaded PDF files size into bytes, kilo bytes or megabytes as applicable. 
#The let command allows the variable 'mb' and 'kb' assign values into them. the byte value of megabytes and kilobytes is then assigned to them.
#Then'$1', which is the parameter that is requred for the fucntion as input is passed thrugh a conditional test if it's byte value is greater than megabyte value and if that's true the '$1' is echoed to the awk function.
#The awk function with 'printf' code returns a floating value. The number of floats requried in thic case, which is 2 floats are commanded through "%.2f" and then the byte value is converted in to megabytes by diving the byte value by 1024 twice(1 Megabyte=1024 Kilobytes, 1 Kilobyte=1024 Bytes).
#If the '$1' file's byte size is less then a megabyte but greater than a kilobyte, then it is converted into kilo bytes by the same procedure that is used o convert the file sixe into megabyte. Except herethe byte value is only divided by 1024 once to convert the bytes into kilo bytes
#If the file size('$1') isn't greater than 'mb' or 'kb', then it's size is shown as it is in bytes.
#The convertion of file size into megabytes, kilobytes and bytes was taught to us during lecture week 8.
getsize() {
    let mb=1048576
    let kb=1024
    if [[ $1 -ge $mb ]]; then
        echo "$(echo $1 | awk '{printf "%.2f", $1/1024/1024}')Mb"
    elif [[ $1 -ge $kb ]]; then
        echo "$(echo $1 | awk '{printf "%.2f", $1/1024}')kb"
    else
        echo "$1 b"
    fi
}


# 'removie_temps' function is called at the beggining of the script to remove if any temporary files existing from the last run in the directory.
remove_temps


#This part of the code is checking whether any command line arguments have been passed to the script. If there are command line arguments, then it enters a while loop and uses getopts command to parse the options passed to the script.
#In this case, there is only one valid option, '-z', which sets the zipit variable to be true. If any other option is passed or if there is an error in the syntax of the option, the script prints an error message stored in '$OPTERROR' and exits with a status of 1.
#The if statement at the end ensures that the script continues to execute even if no command line arguments were passed.
if [[ $# -gt 0 ]]; then
    while getopts "z" opt; do
        case $opt in
            z) zipit=true;;
            *) sleep 1
                echo -e "$OPTERROR" && exit 1;;
        esac
    done
fi


#read command with the '-p' arguement allows the script to take input from the user with the text displayed. The first argument passed will be asigned to the variable called 'URL'. This stores the URL entered by the user.
read -p "Enter a URL: " url


#The first line of this code downloads the content of the specified URL by using the curl command and saves it into a temporary file named temp.txt. the '-s' flag allows the process to be done quietly without displaying the download process in the interface.
#The second line extracts all the links that contain ".pdf" from the temp.txt file using the grep command and saves them in the pdfurls.txt file. The 'cat' command is used to pass the text in the 'temp.txt' and '|' is used to pipe the output into grep where it filters the first part of the command, grep -Eo '(http|https)://[^"]+', is using a regular expression to match any HTTP or HTTPS URLs that start with http:// or https://, respectively, and then followed by any non-quote character until the end of the URL.
#The output of the first command is then piped to the next command, grep ".pdf", which searches for all lines that contain the ".pdf" string in them.
#Finally, the output of the second command is redirected to a file called pdfurls.txt, which will contain a list of all the URLs that match the pattern http(s)://*.pdf.
#The third line extracts the filenames of the pdf files from the pdfurls.txt file by removing the URL prefix and saving them to the pdfs.txt file using the sed command.
#To sumup, this code extracts the links of all PDF files from the URL provided by the user, and saves them in a separate file named pdfurls.txt. It also extracts the names of these PDF files, removing the URL prefix, and saves them in a separate file named pdfs.txt.
curl -s "$url"> temp.txt
cat temp.txt | grep -Eo '(http|https)://[^"]+' | grep ".pdf" > pdfurls.txt
cat temp.txt | grep -Eo '(http|https)://[^"]+' | grep ".pdf" | sed 's/.*\///' > pdfs.txt


#To create unique directories, I have used the current date and time of the creation of the directory to be the name of it.To create unique directories for storing PDF files, the current date and time of the creation of the directory are used as the name of the directory. This is done by obtaining the current date and time using the 'date' command with a specific format of year-month-day_hours-minutes-seconds (YYYY-MM-DD_HH-MM-SS) and assigning it to a variable called 'unique'.
#Then, the variable 'directory' is set to the concatenation of the string "pdfs_" and the value of the 'unique' variable, which will be the name of the directory.
unique=$(date '+%Y-%m-%d_%H-%M-%S')
directory="pdfs_$unique"


#This part of the code checks if there are any PDF files found at the specified URL. 
#In the code above, the 'pdfurls.txt is used to sore all the URL links of the PDFs in the website. If the number of lines in the pdfs.txt file is less than or equal to 0, which means no PDFs are found, then it displays an error message using the RED color and exits the script.
#The sleep command is used in this code to pause the script for a specified number of seconds. It is used to create a pause between the execution of certain commands to make the output more readable for the user.
#The the sleep command is used to create a delay of one second between the display of error messages to give the user a chance to read the message before the script exits. It is also used to create a pause between the removal of temporary files and the exit of the script, allowing the user to see the result of the file removal before the script.
#Before exiting the script he 'remove_temps' function is called to remove any temporary files created during the execution of the script.
if ! [[ $(cat pdfs.txt | wc -l) -gt 0 ]]; then
    sleep 1
    echo -e "${RED}No PDFs found at this URL${NC}"
    remove_temps
    sleep 1
    echo -e "${RED}- exiting...${NC}"
    sleep 1
    exit 1
fi


#This line of code creates a variable named "path" which stores the current working directory (using the "pwd" command) and concatenates it with the directory name variable "directory". This results in the full path of the new directory that will be created to store the downloaded PDF files.
path=$(pwd)/$directory


#This part of the code does the downloading process of the PDF file using the 'Wget'command.
# The first line checks if the number of lines in the pdfs.txt file is greater than zero. If so, the script continues to download the PDF files.
#The second line displays a message showing the number of PDF files to be downloaded in green color. The number of file to be downloaded is calculated using the number of link in the 'pdfs.txt' which hold the all the names of the names of the files to be downloaded. And the line count is taken as the number of file to be downloaded.
#In the third line, a for loop iterates over the URLs of the PDF files stored in pdfurls.txt file, and downloads each file using wget command with -q option which makes the download quiet, and -P option which specifies the directory to save the downloaded files in.
#After completition of downloading the files. the 7th line displays a message showing the number of PDF files that have been successfully downloaded and the name of the directory in which the files have been saved. The ${GREEN} is used to display the directories in green color.
#The following line after, displays a header for a table that will show the file name and its size.
#The last for  loop iterates over the files in the directory where the PDF files have been downloaded, and for each file, it extracts the file name and size in bytes. The awk command is used to format the output as a table with the file name and size separated by a blue vertical bar (|). The output is then appended to the downloads.txt file
#In this line of code, the awk command is used to format the output of the downloaded files' names and sizes and write them to the downloads.txt file.
#The echo command is used to concatenate the 'fname' (file name) and 'fsize' (file size) variables, separated by a space. This output is then piped to the awk command for formatting.
#Within the awk command, the 'printf' function is used to format the output. The '%-25s' is used to format the 'fname' variable as a left-aligned string with a field width of 25 characters. The ${BLUE}|${NC} is used to insert a blue vertical bar separator between the 'fname' and 'fsize' variables. The '%5s' is used to format the fsize variable as a right-aligned string with a field width of 5 characters.
#Finally, the ''>>'' operator is used to append the formatted output to the downloads.txt file.
if [[ $(cat pdfs.txt | wc -l) -gt 0 ]]; then
    echo -e "Downloading ${GREEN}$(cat pdfs.txt | wc -l)${NC} PDF files. . . . . . " 
    for link in $(cat pdfurls.txt)
        do
            wget -q "$link" -P $directory
        done
    echo -e "${GREEN}$(cat pdfs.txt | wc -l)${NC} PDF files have been downloaded to the directory ${GREEN}$directory${NC}"
    echo -e "${BLUE}FILENAME\t\t\tSIZE${NC}"
    for item in $path/*
        do
            if [[ -f $item ]]; then
                fname=$(basename $item)
                fsize=$(getsize $(du -b $item | cut -f 1))
                echo $fname $fsize | awk "{printf \"%-25s ${BLUE}|${NC}%5s\n\", \$1, \$2}" >> downloads.txt
            fi
        done
fi    


#This part of the code sorts the contents of the downloads.txt file based on the first column in each line, while ignoring the case of the text in that column (--ignore-case option). The -k 1 option specifies that the sorting should be done based on the first column.
#The cat command is used to display the contents of the file on the terminal, and the output of this command is then piped (|) to the sort command. The --ignore-case option specifies that the sorting should be case-insensitive. Finally, the -k 1 option specifies that the sorting should be done based on the first column.
cat downloads.txt | sort --ignore-case -k 1


#Finally, if the user has passed '-z' flag to zip the downloads this part of the code will execute.
#The first line checks if the $zipit variable is true (meaning the user specified to create a zip archive of the downloaded PDFs), then execute the following commands.
#Firstly the code will create a zip archive of the $directory folder (where the downloaded PDFs are stored) with the name $directory.zip and -q flag to mutes the zip command's output.
#Then move the newly created zip archive $directory.zip to the $directory folder.
#finally Print a message indicating that the PDFs have been archived to the newly created zip file and the location of the zip file and the directory where it is stored.
if [[ $zipit == true ]]; then
    zip -qr "$directory.zip" "$directory"
    mv $directory.zip $directory
    sleep 1
    echo -e "PDFs archived to ${GREEN}$directory.zip${NC} in the ${GREEN}$directory${NC} directory."

fi



#At the end of the script, all the temporary files created by the script("temp.txt","pdfs.txt", "pdfurls.txt") will be removed by calling the remove_temps function.
remove_temps

#End of script.
exit 0

