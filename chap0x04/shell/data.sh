#!/usr/bin/env bash


function helpInfo {

	echo -e "data.sh - 处理世界杯球员数据所写的程序\n"

	echo -e "注意：处理数据之前，数据要和程序放在同一文件夹里\n"

	echo "Usage: bash data.sh [arguments]"

	echo "Arguments:"

	echo "  -ad		: 统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比"

	echo "  -am		: 列出年龄最大和年龄最小的球员的名字"

	echo "  -p		: 统计不同场上位置的球员数量、百分比"

	echo "  -n		: 列出名字最长和名字最短的球员的名字"

	echo "  -h or --help	: 打印帮助项目"
}

#统计不同年龄区间范围的球员数量和百分比
function AgeData {
	
	below=0
	between=0
	above=0

	data=$(awk -F "\t" '{print $6}' "$1")

        for age in $data; do

		if [[ "$age" != 'Age' ]]; then

			if [[ "$age" -lt 20 ]];then
			  below=$((below+1))

			elif [[ "$age" -ge 20 && "$age" -le 30 ]];then
			  between=$((between+1))

			elif [[ "$age" -gt 30 ]];then
			  above=$((above+1))

			fi

			line_num=$((line_num+1))

		fi
	done

        
	#计算百分比

	below_ratio=$(printf "%.3f" "$(echo "100*${below}/$line_num" | bc -l)")

	between_ratio=$(printf "%.3f" "$(echo "100*${between}/$line_num" | bc -l)")

	above_ratio=$(printf "%.3f" "$(echo "100*${above}/$line_num" | bc -l)")


	echo -e "\n-------- 年龄划分 --------"

	echo -e "(0, 20) \t$below\t${below_ratio}%"

	echo -e "[20, 30]\t$between\t${between_ratio}%"

	echo -e "(30, +∞)\t$above\t${above_ratio}%"
}



#统计不同场上位置的球员数量、百分比
function Position {

	declare -A positions_dict 	#声明关联数组

	position_data=$(awk -F "\t" '{ print $5 }' "$1")

	for position in $position_data; do

		if [[ "$position" != 'Position' ]];then

			if [[ -z "${positions_dict[$position]}" ]];then
				positions_dict[$position]=1

			else
				temp="${positions_dict[$position]}"
				positions_dict[$position]=$((temp+1))
			fi

			line_num=$((line_num+1))

		fi
	done


	#遍历关联数组输出结果

	echo -e "\n-------- 位置数据统计 --------"

	for position in "${!positions_dict[@]}";do

		count="${positions_dict[$position]}"

		ratio=$(printf "%.3f" "$(echo "100*${count}/$line_num" | bc -l)")

		echo -e "$position\t$count\t${ratio}%"

	done

}


#比较年龄大小，得到最大与最小年龄

function AgeM {

	max=0
	min=100

	data=$(awk -F "\t" '{ print $6 }' "$1")

	for age in $data; do

		if [[ "$age" != 'Age' ]]; then

			if [[ "$min" -gt "$age" ]]; then
				min="$age"
			fi


			if [[ "$max" -lt "$age" ]]; then
				max="$age"
			fi

			line_num=$((line_num+1))

		fi
	done

        
	#最大年龄的球员可能有多个

	oldest=$(awk -F '\t' '{if($6=='"${max}"') {print $9}}' "$1");

	echo -e "\n-------- 以下是年纪最大的球员 --------"

	for name in $oldest; do
		echo -e "$name\t$max"
	done


	youngest=$(awk -F '\t' '{if($6=='"$min"') {print $9}}' "$1");

	echo -e "\n-------- 以下是年纪最小的球员 --------"

	for name in $youngest ;do
		echo -e "$name\t$min"
	done
}


#统计名字最长最短的球员

function NameM {

	longest=0
	shortest=1000


	data=$(awk -F "\t" '{ print length($9) }' "$1")

	for name_len in $data; do

		if [[ "$longest" -lt "$name_len" ]]; then
			longest="$name_len"
		fi

		if [[ "$shortest" -gt "$name_len" ]]; then
			shortest="$name_len"
		fi
	done



	longest_name=$(awk -F '\t' '{if (length($9)=='"$longest"'){print $9}}' "$1")

	echo -e "\n-------- 以下是最长的名字 --------"

	echo -e "$longest_name\t$longest"


	shortest_name=$(awk -F '\t' '{if (length($9)=='"$shortest"'){print $9}}' "$1")

	echo -e "\n-------- 以下是最短的名字 --------"

	echo -e "$shortest_name\t$shortest"
}

#main

if [[ "$#" -eq 0 ]]; then

	echo -e "请输入一些参数，以下是帮助:\n"
	helpInfo

fi

while [[ "$#" -ne 0 ]]; do

	case "$1" in

		"-ad")AgeData "worldcupplayerinfo.tsv"; shift;;

		"-am")AgeM "worldcupplayerinfo.tsv"; shift;;

		"-p")Position "worldcupplayerinfo.tsv"; shift;;

		"-n")NameM "worldcupplayerinfo.tsv"; shift;;

		"-h" | "--help")helpInfo; exit 0;;

                *)echo "没有对应操作！使用-h查看帮助";exit 0

	esac

done
