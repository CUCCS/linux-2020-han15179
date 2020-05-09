#!/usr/bin/env bash

LANG=en_US.UTF-8

function helpInfo {

	echo -e "weblog.sh - 用于处理服务器日志\n"

	echo -e "注意：使用前确保web_log.tsv和脚本处于同一文件夹\n"

	echo "Usage: bash weblog.sh [arguments]"

	echo "Arguments:"

	echo "  -t		: 统计访问来源主机TOP 100和分别对应出现的总次数"

	echo "  -i		: 统计访问来源主机TOP 100 IP和分别对应出现的总次数"

	echo "  -u 		: 统计最频繁被访问的URL TOP 100"

	echo "  -s       	: 统计不同响应状态码的出现次数和对应百分比"

	echo "  -s4 		: 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"

	echo "  -uh <URL>	: 给定URL输出TOP 100访问来源主机"

	echo "  -h or --help	: 帮助信息"

}

#统计访问来源主机TOP 100和分别对应出现的总次数

function HostTop {

	file=$1

	host=$(sed '1d' "$file" | awk -F '\t' '{print $1}' | sort | uniq -c | sort -nr | head -n 100)

	echo -e "Top100 Host:\n$host\n"  >> HostTop.log

}


#统计访问来源主机TOP 100 IP和分别对应出现的总次数

function IpTop {

	file=$1

	IP=$(sed '1d' "$file" | awk '{if ($1~/^([0-2]*[0-9]*[0-9])\.([0-2]*[0-9]*[0-9])\.([0-2]*[0-9]*[0-9])\.([0-2]*[0-9]*[0-9])$/){print $1}}'| awk -F '\t' '{a[$1]++} END{for(i in a) {print (a[i],i)}}' | sort -nr | head -n 100)

	echo -e "Top100 IP:\n$IP\n" >> IpTop.log

}


#统计最频繁被访问的URL TOP 100

function UrlTop {

	file=$1

	URL=$(sed '1d' "$file" | awk -F '\t' '{print $5}' | sort | uniq -c | sort -nr | head -n 100)

	echo -e "Top100 URL:\n$URL\n" >> UrlTop.log

}


#统计不同响应状态码的出现次数和对应百分比

function States {

	file=$1

	code=$(sed '1d' "$file" | awk -F '\t' 'BEGIN{ans=0}{a[$6]++;ans++} END{for(i in a) {printf ("%-10s%-10d%10.3f\n",i,a[i],a[i]*100/ans)}}')

	echo -e " 响应状态码的出现次数和对应百分比:\n$code\n" >> States.log

}



#分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数

function States4XX {

	file=$1

	code=$(sed '1d' "$file" | awk -F '\t' '{if($6~/^4/) {print $6}}' | sort -u )

	for n in $code ; do

		top=$(awk -F '\t' '{ if($6=='"$n"') {a[$5]++}} END {for(i in a) {print a[i],i}}' "$1" | sort -nr | head -n 100)

		echo -e "${n} Top100 URL:\n$top\n" >> States4xxTop.log

	done

}

#给定URL输出TOP 100访问来源主机

function SpecifiedURLHosts {

	file=$1

	URL=$2

	uh=$(sed '1d' "$file" | awk -F '\t' '{if($5=="'$URL'") {host[$1]++}} END{for (i in host) {print host[i],i}}' | sort -nr | head -n 100)

	echo -e "URL: $URL\n\n${uh}" >> SpecifiedURLHost.log

}


#main 


if [[ "$#" -eq 0 ]]; then

	echo -e "请输入一些参数，以下是帮助:\n"

	helpInfo

fi

while [[ "$#" -ne 0 ]]; do

	case "$1" in

		"-t")HostTop "web_log.tsv"; shift 1;;

		"-i")IpTop "web_log.tsv"; shift 1;;

		"-u")UrlTop "web_log.tsv"; shift 1;; 

		"-s")States "web_log.tsv"; shift ;;

		"-s4")States4XX "web_log.tsv"; shift 1;;

		"-uh")


			if [[ -n "$2" ]]; then

				SpecifiedURLHosts "web_log.tsv" "$2"

				shift 2

			else

				echo "在'-uh'后输入URL地址"

				exit 0

			fi

			;;

		"-h" | "--help")helpInfo;exit 0;;
		
		*)echo "没有对应操作！使用-h查看帮助";exit 0

        esac

done
