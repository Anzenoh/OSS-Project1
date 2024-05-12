#!/bin/bash
if [ $# -ne 3 ]; then
	echo "usage: ./prj1_12214201_choisunoh.sh file1 file2 file3"
	exit 1
fi

echo "**************OSS1 - Project1**************"
echo "*		StudentID: 12214201		*"
echo "*		Name: Choisunoh			*"
echo "*******************************************"
echo
while :
do
	echo '[MEMU]'
	echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in player.csv"
	echo '2. Get the team data to enter a league position in teams.csv'
	echo '3. Get the Top-3 Attendance matches in matches.csv'
	echo "4. Get the team's league position and team's top scorer in teams.csv & player.csv"
	echo "5. Get the modified format of date_GMT in matches.csv"
	echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
	echo "7. Exit"
	read -p "Enter your CHOICE[1~7] : " userinput
	if [ $userinput -eq 1 ]; then
		read -p "Do you want to get the Heung-Min Son's data? (y/n) :" userinput2
	       	if [ $userinput2 = "y" ]; then
			cat players.csv | awk -F',' '$1~"Heung"{print"Team: " $4", Apperance:"$6 ", Goal:"$7 ", Assist:"$8}'
		else continue
		fi

	elif [ $userinput -eq 2 ]; then
		read -p "What do you want to get the team data of league_position[1~20] :" position
		cat teams.csv | awk -F',' -v p=$position '$6==p{print $6 " " $1, $2/($2+$3+$4)}'

	elif [ $userinput -eq 3 ]; then
		read -p "Do you want to know Top-3 attendance data? (y/n)" userinput2
		if [ $userinput2 = "y" ]; then
			echo "*** Top-3 Attendance Match***"
			echo
			cat matches.csv | sort -r -t ',' -k 2 -n | awk -F',' 'NR==1 || NR==2 || NR==3 {print $3 " vs " $4 "("$1")\n" $2, $7"\n"}'
		else continue
		fi

	elif [ $userinput -eq 4 ]; then
		read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n) :" userinput2
		echo
		if [ $userinput2 = "y" ]; then
			league_position=$(cat teams.csv | sort -t ',' -k 6 -n | awk -F',' '{if($6 ~ /^[0-9]+$/) {printf "%s%s",sep,$6; sep=","}} END {print ""}')
			teamname=$(cat teams.csv | sort -t ',' -k 6 -n | awk -F',' '{if($6 ~ /^[0-9]+$/) {printf "%s%s",sep,$1; sep=","}} END {print ""}')
			IFS=',' read -a team_array <<< "$teamname"
			IFS=',' read -a position_array <<< "$league_position"
			i=0
			for team in "${team_array[@]}"; do
    				touch "$team.txt"
				cat players.csv | awk -F',' -v a="$team" '$4==a{print $1","$7}' > "$team.txt"
				{ cat "$team.txt" | sort -r -t ',' -k 2 -n | head -n 1 > tmp && mv tmp "$team.txt"; }
				sed -i 's/,/ /g' "$team.txt"
				echo "${position_array[i]} ${team}"
				cat "$team.txt"
				((i+=1))
				echo
			done
		else continue
		fi

	elif [ $userinput -eq 5 ]; then
		read -p "Do you want to modify the format of date? (y/n) :" userinput2
		if [ $userinput2 = "y" ]; then
			date=$(sed -n '2,11p' matches.csv | awk -F',' '{printf "%s%s",sep,$1; sep=","} END {print ""}')
			IFS=','	read -r -a date_array <<< "$date"
			for date_element in "${date_array[@]}"; do
				date_element=$(echo $date_element | sed -E 's/Jan/01/g;s/Feb/02/g;s/Mar/03/g;s/Apr/04/g;s/May/05/g;s/Jun/06/g;s/Jul/07/g;s/Aug/08/g;s/Sep/09/g;s/Oct/10/g;s/Nov/11/g;s/Dec/12/g')
				echo "$date_element" | sed -E 's/([0-9]+) ([0-9]+) ([0-9]+) - ([0-9]+:[0-9]+)(am|pm)/\3\/\1\/\2 \4\5/'
			done
		else continue
		fi

	elif [ $userinput -eq 6 ]; then
		read -p "1) Arsenal 		11) Liverpool
2) Tottenham Hotspur 	12) Chelsea
3) Manchester City 	13) West Ham United
4) Leicester City 	14) Watford
5) Crystal Palace 	15) Newcastle United
6) Everton 		16) Cardiff City
7) Burnley 		17) Fulham
8) Southampton 		18) Brighton & Hove Albion
9) AFC Bournemouth 	19) Huddersfield Town
10) Manchester United 	20) Wolverhampton Wanderers
Enter your team number: " userinput2
		echo
		teamname=$(cat teams.csv | awk -F',' '{if($6 ~ /^[0-9]+$/) {printf "%s%s",sep,$1; sep=","}} END {print ""}')
		IFS=',' read -a team_array <<< "$teamname"
		for i in {0..19}
		do
			if [ $userinput2 -eq $((i+1)) ]; then
				teamname="${team_array[$((userinput2-1))]}"
				max=$(cat matches.csv | awk -F',' -v team="$teamname" '$3==team {diff = $5 - $6; max = (diff>max) ? diff: max;} END {print max;}')
				cat matches.csv | awk -F',' -v team="$teamname" -v max="$max" '$3 == team && ($5 - $6) == max {print $1"\n"$3" " $5" vs " $6" "$4"\n"}'
			fi
		done
	elif [ $userinput -eq 7 ]; then
		echo "bye!"
		exit 0
	fi

	echo
done
