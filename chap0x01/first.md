第一次作业

要求：

定制一个普通用户名和默认密码

定制安装OpenSSH Server

安装过程禁止自动联网更新软件包


问题：

如何配置无人值守安装iso并在Virtualbox中完成自动化安装？

Virtualbox安装完Ubuntu之后新添加的网卡如何实现系统开机自动启用和自动获取IP？

如何使用sftp在虚拟机和宿主机之间传输文件？


安装环境：

Virtualbox

Ubuntu 18.04.4Server amd64.iso

Putty

在虚拟机手动安装Ubuntu-18.04-server-amd64.iso磁盘

##  添加双网卡

- 在虚拟机里直接设置

![双网卡](/photos/双网卡.png)

- 查看网卡发现未启动

![网卡未启动](/photos/网卡未启动.png)

- 启动网卡后查看

![网卡启动后](/photos/启动网卡后.png)

获取IP：192.168.56.101

## 下载putty，将镜像文件传到虚拟机里

![Putty](/photos/Putty.png)

- 传输文件

![传输文件](/photos/传输.png)

## 挂载ubuntu镜像：

- 在当前用户目录下创建一个用于挂载iso镜像文件的目录
mkdir loopdir

- 挂载iso镜像文件到该目录
sudo mount -o loop ubuntu-18.04.4-server-amd64.iso loopdir

- 创建一个工作目录用于克隆光盘内容
mkdir cd

- 同步光盘内容到目标工作目录
rsync -av loopdir/ cd

- 卸载iso镜像
sudo umount loopdir

- 进入目标工作目录
cd cd/

## 编辑Ubuntu安装引导界面增加一个新菜单项入口

使用vim修改txt.cfg：
`vim isolinux/txt.cfg`

![修改](/photos/修改txt.cfg.png)

- 添加以下内容到该文件后强制保存退出

```
label autoinstall
  menu label ^Auto Install Ubuntu Server
  kernel /install/vmlinuz
  append  file=/cdrom/preseed/ubuntu-server-autoinstall.seed debian-installer/locale=en_US console-setup/layoutcode=us keyboard-configuration/layoutcode=us console-setup/ask_detect=false localechooser/translation/warn-light=true localechooser/translation/warn-severe=true initrd=/install/initrd.gz root=/dev/ram rw quiet
```


## 添加preseed文件

- 直接使用了老师提供的preseed文件，修改了用户名和密码后使用vim在/cd/preseed/中生成了ubuntu-server-autoinstall.seed


## 修改isolinux.cfg：

- 将timeout 300 改为timeout 10

![修改](/photos/修改timeout.png)




## 重新生成custom.iso：

- 重新生成MD5校验和：
`find . -type f -print0 | xargs -0 md5sum > md5sum.txt`

- 将/cd内文件生成custom.iso：
```
IMAGE=custom.iso
BUILD=/home/han15179/cd/
sudo mkisofs -r -V "Custom Ubuntu Install CD" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $IMAGE $BUILD
```

- 使用下方指令更新genisoimage
```
apt-get update
apt-get install genisoimage
```

- 下载数据包

![更新](/photos/更新.png)

- 更新完成

![更新完成](/photos/更新完成.png)



## 移动custom.iso
- 使用命令将custom.iso从/home/han15179/cd移到/home/han15179:
`mv custom.iso ../`

- 然后打开psftp窗口
`get custom.iso`

- custom.iso文件就被传到putty文件夹里了
![](/photos/传输custom.iso.png)

## 无人值守安装录屏

<https://www.bilibili.com/video/BV1D7411m7Ka/>


## 遇到过的问题

- 第一次启动网卡不知为什么只显示了ipv6地址，putty也可以连接

![ipv6](/photos/启动网卡后2.png)

- 在preseed里设置的密码过短会出现密码过短的提示，突破了无人值守……

![密码过短](/photos/密码过短.png)

- 第一次使用老师的preseed文件，安装出来的系统文字是黄色的，以为是老师的设置
- 但后续多次重装，没有改动代码，有时是黄色的，有时是白色的，没搞清楚为什么……

