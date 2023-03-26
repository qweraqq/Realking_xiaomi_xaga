DIR=`readlink -f .`
MAIN=`readlink -f ${DIR}/..`
KERNEL_DIR=`pwd`
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot"
export ARCH=arm64
git  clone  --depth 1 https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b clang-r416183b
export PATH="$MAIN/clang-r416183b/bin:$PATH"
export LD_LIBRARY_PATH=/$MAIN/clang-r416183b/lib64:$LD_LIBRARY_PATH

make gki_defconfig mgk_xaga.config entry_level.config -j$(nproc --all) O=out/ LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" CC=clang CROSS_COMPILE_COMPAT=arm-linux-androidkernel- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-androidkernel-

make Image.gz -j$(nproc --all) O=out/ LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" CC=clang CROSS_COMPILE_COMPAT=arm-linux-androidkernel- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-androidkernel-

make dtbs -j$(nproc --all) O=out/ LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" CC=clang CROSS_COMPILE_COMPAT=arm-linux-androidkernel- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-androidkernel-

make modules -j$(nproc --all) O=out/ LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" CC=clang CROSS_COMPILE_COMPAT=arm-linux-androidkernel- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-androidkernel-

make mediatek/mt6895.dtb mediatek/k6895v1_64.dtbo -j$(nproc --all) O=out/ LLVM=1 LLVM_IAS=1 CPATH="/usr/include:/usr/include/x86_64-linux-gnu" HOSTLDFLAGS="-L/usr/lib/x86_64-linux-gnu -L/usr/lib64 -fuse-ld=lld" CC=clang CROSS_COMPILE_COMPAT=arm-linux-androidkernel- CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-androidkernel-

python /data/jenkins/kernel/libufdt/src/mkdtboimg.py create $ANYKERNEL/dtbo.img out/arch/arm64/boot/dts/mediatek/k6895v1_64.dtbo

TIME="$(date "+%Y%m%d-%H%M%S")"
mkdir -p tmp
cp -fp $ZIMAGE_DIR/Image.gz tmp
cp -rp ./anykernel/* tmp
cd tmp
7za a -mx9 tmp.zip *
cd ..
rm *.zip
cp -fp tmp/tmp.zip A.Z.R.A.E.L--KERNEL-$TIME.zip
rm -rf tmp
echo $TIME
