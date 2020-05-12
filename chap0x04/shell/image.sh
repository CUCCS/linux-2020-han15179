#!/usr/bin/env bash


#帮助文档

function helpInfo {

	echo -e "image.sh - 用于图像处理\n"

	echo -e "Tips: 使用脚本前，先确认是否安装了ImageMagick，输入'sudo apt install imagemagick'进行安装\n"

	echo "Usage: bash image.sh [arguments]"

	echo "Arguments:"

	echo "  -d <path>	: 输入你想处理的图片路径"

	echo "  -q <percentage>	: 压缩图片质量,

			  eg: -q 50% (意味着压缩 50%)."

	echo "  -r <width>		: 压缩分辨率,

			  eg: -r 50 (意味着压缩到 50)."

	echo "  -w <text>		: 在图片右下角附加自定义文本水印"

	echo "  -p <text>		: 添加文件名前缀"

	echo "  -s <text>		: 添加文件名后缀"

	echo "  -c			: 把png/svg图片转化成jpg格式文件"

	echo "  -h or --help		: 展示帮助"

}



#对jpeg格式图片进行图片质量压缩

function QualityCompress {

	dir=$1

	pec=$2

	images="$(find "$dir" -regex '.*\(jpg\|JPG\|jpeg\)')"

        for img in $images;do

		fullname="$(basename "$img")"

		filename="${fullname%.*}"

		typename="${fullname##*.}"

		convert "$img" -quality "$pec" ./"$filename"_output_q."$typename"

	done

	echo "成功压缩图片"

}



#对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率

function ResolutionCompress {

	dir=$1

	width=$2
	
	images="$(find "$dir" -regex '.*\(jpg\|JPG\|jpeg\|png\|PNG\|svg\|SVG\)')"

	for img in $images; do

		fullname="$(basename "$img")"

                filename="${fullname%.*}"

                typename="${fullname##*.}"

                convert "$img" -resize "$width" ./"$filename"_output_r."$typename"

        done

        

	echo "成功压缩分辨率"

}



#对图片批量添加自定义文本水印

function AddWatermark {

	dir=$1

	text=$2

	images="$(find "$dir" -regex '.*\(jpg\|JPG\|jpeg\|png\|PNG\|svg\|SVG\)')"

        for img in $images;do

		fullname="$(basename "$img")"

		filename="${fullname%.*}"

		typename="${fullname##*.}"

		convert "$img" -gravity southeast -fill red -pointsize 16 -draw "text 5,5 '$text'" ./"$filename"_output_w."$typename"

	done

	echo "成功添加水印"

}



#批量重命名--统一添加文件名前缀

function AddPrefix {

	dir=$1

	prefix=$2

	for img in "$dir"; do

		fullname="$(basename "$img")"

		filename="${fullname%.*}"

		typename="${fullname##*.}"

		cp "$img" ./"$prefix""$filename"."$typename"

	done

	echo "成功添加前缀"

}



#统一添加文件名后缀

function AddSuffix {

        dir=$1

        suffix=$2

        for img in "$dir"; do

                fullname="$(basename "$img")"

                filename="${fullname%.*}"

                typename="${fullname##*.}"

                cp "$img" ./"$filename""$suffix"."$typename"

        done

        echo "成功添加后缀"

}



#将png/svg图片统一转换为jpg格式图片

function Conversion {

	dir=$1

	images="$(find "$dir" -regex '.*\(png\|PNG\|svg\|SVG\)')"

	for img in $images; do

		fullname="$(basename "$img")"

		filename="${fullname%.*}"

		convert "$img" ./"$filename"".jpg"

	done

	echo "成功修改为JPG文件"

}



#main


path=""


if [[ "$#" -eq 0 ]];then

	echo -e "请输入一些参数，以下是帮助:\n"

	helpInfo

fi


while [[ "$#" -ne 0 ]]

do

	case "$1" in

		"-d")

			if [[ "$2" != '' ]];then
				path="$2"
				shift 2 
			else
				echo "请在'-d'后输入图片路径."
				exit 0
			fi

			;;

		"-q")

			if [[ "$2" != '' ]];then
                QualityCompress "$path" "$2"
				shift 2
			else
				echo "请输入一个参数，例如: -q 50%"
				exit 0
			fi

			;;

		"-r")

			if [[ "$2" != '' ]];then
				ResolutionCompress "$path" "$2"
				shift 2
			else
				echo "请输入一个参数，例如:-r 50"
				exit 0
			fi

			;;

		"-w")

			if [[  "$2" != ''  ]]; then
				AddWatermark "$path" "$2"
				shift 2
			else
				echo "请输入水印文本，例如: -w hello"
				exit 0
			fi

			;;

		"-p")
			if [[  "$2" != ''  ]]; then
				AddPrefix "$path" "$2"
				shift 2
			else
				echo "请在'-p'后输入文本作为添加的前缀"
				exit 0
			fi

			;;

		"-s")

			if [[  "$2" != ''  ]]; then
           		    	 AddSuffix "$path" "$2"

           		    	 shift 2

           	        else

                  	  	echo "请在'-s'后输入文本作为添加的后缀"

                   	 exit 0

            fi

            ;;

		"-c")Conversion "$path"; shift;;

		"-h" | "--help")helpInfo; exit 0;;

                *)echo "没有对应操作！使用-h查看帮助";exit 0


	esac

done
