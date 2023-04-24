DIR=`readlink -f .`
MAIN=`readlink -f ${DIR}/..`

#!/bin/bash
# Resources
THREAD="-j4"

export CROSS_COMPILE_COMPAT=/opt/clang-r416183b/bin/arm-linux-androidkernel- 
export CROSS_COMPILE_ARM32=/opt/clang-r416183b/bin/arm-linux-androidkernel-
export CLANG_TRIPLE=/opt/clang-r416183b/bin/aarch64-linux-gnu-
export CROSS_COMPILE=/opt/clang-r416183b/bin/aarch64-linux-gnu- CC=clang CXX=clang++
export LD_LIBRARY_PATH=/opt/clang-r416183b/lib64:/usr/local/lib:$LD_LIBRARY_PATH
DEFCONFIG="gki_defconfig"

# Paths
KERNEL_DIR=`pwd`
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot"

# Vars
export ARCH=arm64
export SUBARCH=$ARCH
export KBUILD_BUILD_USER=Rohail

DATE_START=$(date +"%s")

echo  "DEFCONFIG SET TO $DEFCONFIG"
echo "-------------------"
echo "Making Kernel:"
echo "-------------------"
echo

make -j4 CC='ccache clang' ARCH=arm64 LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" CROSS_COMPILE_COMPAT=arm-linux-androidkernel- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-androidkernel- O=out gki_defconfig
make CC="ccache clang" CXX="ccache clang++" LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" O=out $DEFCONFIG
make CC='ccache clang' CXX="ccache clang++" LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" O=out $THREAD \
    CONFIG_MEDIATEK_CPUFREQ_DEBUG=m CONFIG_MTK_IPI=m CONFIG_MTK_TINYSYS_MCUPM_SUPPORT=m \
    CONFIG_MTK_MBOX=m CONFIG_RPMSG_MTK=m CONFIG_LTO_CLANG=y CONFIG_LTO_NONE=n \
    CONFIG_LTO_CLANG_THIN=y CONFIG_LTO_CLANG_FULL=n \
    CONFIG_DEBUG_INFO_SWARF4=y CONFIG_BPF=y CONFIG_DEBUG_INFO_BTF=y 2>&1 | tee kernel.log

echo
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
ls -a $ZIMAGE_DIR

cd $KERNEL_DIR

TIME="$(date "+%Y%m%d-%H%M%S")"
mkdir -p tmp
cp -fp $ZIMAGE_DIR/Image.gz tmp
cp -rp ./anykernel/* tmp
cd tmp
7za a -mx9 tmp.zip *
cd ..
rm *.zip
cp -fp tmp/tmp.zip RealKing_xiaomi_xaga-$TIME.zip
rm -rf tmp
echo $TIME
