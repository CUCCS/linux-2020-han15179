#!/usr/bin/env bash

err=0;
flag=1;

while [ ${flag} -eq 1 ]
do

	echo '输入两个整数：';

	read a b;

	if [[ -z "$a" || -z "$b" ]]; then

		err=1;
		echo "输入错误！你需要输入两个数字。";
		break;

	fi

	if [[ ! -z  "$(echo "$a" | grep '[.]')" || ! -z  "$(echo "$b" | grep '[.]')" ]]; then

                err=1
                echo "输入错误！你需要输入整数！"
                break;

    fi

	expr $a + 1 &> /dev/null

	END_CODE1=$?

	expr $b + 1 &> /dev/null

	END_CODE2=$?



	if [[ ${END_CODE1} -ne 0 || ${END_CODE2} -ne 0 ]]; then

		err=1;
		echo "输入错误！你需要输入数字！";
		break;

	fi


	if [[ ${err} -eq 0 ]]; then

		
		c=$((a%b));
		while [ ${c} -ne 0 ]
		do

			gys=${c};
			a=${b};
			b=${c};
			c=$((a%b));

		done

		echo a和b的最大公约数为：${gys};


		echo '继续计算? yes(1) or no(0):';
		read f;
		flag=${f};

	fi

done
