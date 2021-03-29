#!/bin/bash
# Before using, please upload your  wls patch  to /home/rocklei123/Oracle/Middleware/utils/bsu/cache_dir directory 
#使用前上传补丁介质到/home/rocklei123/Oracle/Middleware/utils/bsu/cache_dir  目录，同时修改bsu.sh 内存大小 -Xmx4096 
#cd /home/rocklei123/Oracle/Middleware/utils/bsu && vi bsu.sh 

set -x
##############################################################################
# 1.set Parameters
# Before use, set the parameters
# Parameter Meaning
############################################################################## 
wls_home="/home/rocklei123/Oracle/Middleware"
wls_soft_dir="${wls_home}/wlserver_10.3/"
bsu_dir="${wls_home}/utils/bsu"
cache_dir="${bsu_dir}/cache_dir"
patch_file="p25388747_1036_Generic.zip"
patch_catalog_file="patch-catalog_25022.xml"
patch_name="RVBS.jar"
dates="20170622"

cd "$cache_dir" && mv patch-catalog.xml patch-catalog.xml.ZLNA && mv README.txt README.txt.bak && unzip  "$patch_file" && echo "unzip file success ......"
ls -l $cache_dir |grep $patch_name
r=$?
if [ $r == 1 ]; then
        echo "Can not found patch media,please check ......"
        exit 1
else
	cd "$cache_dir" && mv "$patch_catalog_file" patch-catalog.xml && echo "kill all java process ......"
	killall java && sleep 5 &&  ps -ef | grep java
	cd "$bsu_dir" && ./bsu.sh -view -status=applied -prod_dir="$wls_soft_dir" > patch_version.log
	filenames=`ls ${bsu_dir} |grep patch_version.log`
	echo "$filenames"
	for filename in $filenames; do
		 succeskey1=`grep "EJUW (20780171)" ${bsu_dir}/patch_version.log`
		 echo "$succeskey1"
		 if [ -n "$succeskey1" ];then
			cd "$bsu_dir" && ./bsu.sh -remove -patchlist=ZLNA -prod_dir="$wls_soft_dir" -verbose >> remove_patch.log
			cd "$bsu_dir" && ./bsu.sh -remove -patchlist=EJUW -prod_dir="$wls_soft_dir" -verbose >> remove_patch.log
			cd "$bsu_dir" && ./bsu.sh -view -status=applied -prod_dir="$wls_soft_dir" > patch_version.log
			succeskey2=`grep "Patch ID" ${bsu_dir}/patch_version.log`
			echo "$succeskey2"
			if [ -z "$succeskey2" ];then
				cd "$bsu_dir" && ./bsu.sh -install -patchlist=RVBS -prod_dir="$wls_soft_dir" -verbose > install_patch.log
				succeskey3=`grep "Result: Success" ${bsu_dir}/install_patch.log`
				if [ -n "$succeskey3" ];then
					echo "$succeskey3" && echo "patch success ********************************"
				fi
			fi
		fi
	done
fi
