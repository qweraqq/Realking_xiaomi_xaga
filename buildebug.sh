#!/bin/bash
DIR=`readlink -f .`
MAIN=`readlink -f ${DIR}/..`
make CC='ccache clang' ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out gki_defconfig
# Resources
THREAD="-j$(nproc --all)"

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
export KBUILD_BUILD_USER=localhost
export KBUILD_BUILD_HOST=xaga-arm64

DATE_START=$(date +"%s")

echo  "DEFCONFIG SET TO $DEFCONFIG"
echo "-------------------"
echo "Making Kernel:"
echo "-------------------"
echo

make CC='ccache clang' ARCH=arm64 LLVM=1 LLVM_IAS=1 O=out gki_defconfig
make CC="ccache clang" CXX="ccache clang++" LLVM=1 LLVM_IAS=1 O=out $DEFCONFIG
make CC='ccache clang' CXX="ccache clang++" LLVM=1 LLVM_IAS=1 O=out $THREAD \
    LOCALVERSION=-Android12-9-00001-g41ff3fa8fff9-ab8171928 \
    CONFIG_LOCALVERSION_AUTO=n \
    CONFIG_MEDIATEK_CPUFREQ_DEBUG=m CONFIG_MTK_IPI=m CONFIG_MTK_TINYSYS_MCUPM_SUPPORT=m \
    CONFIG_MTK_MBOX=m CONFIG_RPMSG_MTK=m CONFIG_LTO_CLANG=y CONFIG_LTO_NONE=n \
    CONFIG_LTO_CLANG_THIN=y CONFIG_LTO_CLANG_FULL=n 2>&1 | tee kernel.log

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

mkdir -p tmp
cp -fp $ZIMAGE_DIR/Image.gz tmp
cp -rp ./anykernel/* tmp
cd tmp
7za a -mx9 tmp.zip *
cd ..
rm *.zip
cp -fp tmp/tmp.zip Android12-$(grep "# Linux/" out/.config | cut -d " " -f 3)-v$(date +%Y%m%d-%H).zip
rm -rf tmp
