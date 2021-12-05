#!/usr/bin/env bash

## Compile script
KERNEL_NAME=CRYO
DEVICE_NAME=joyeuse
IMAGE=out/arch/arm64/boot/Image.gz
ANYKERNEL=https://github.com/wolverine998/AnyKernel3
DATE=$(date +"%F-%H-%M")
START=$(date +"%s")
LLVM_DIR=/usr/lib/llvm-12/bin
function compile() {
	make -j$(nproc) O=out ARCH=arm64 ${DEFCONFIG}
	make -j$(nproc) ARCH=arm64 O=out \
		CC=${LLVM_DIR}/clang \
		AR=${LLVM_DIR}/llvm-ar \
		NM=${LLVM_DIR}/llvm-nm \
		OBJCOPY=${LLVM_DIR}/llvm-objcopy \
		OBJDUMP=${LLVM_DIR}/llvm-objdump \
		STRIP=${LLVM_DIR}/llvm-strip \
		LD=${LLVM_DIR}/ld.lld \
		CROSS_COMPILE=aarch64-linux-gnu- \
		CROSS_COMPILE_ARM32=arm-linux-gnueabi-

	if ! [ -a "$IMAGE" ]; then
		exit 1
	fi

	cp $IMAGE AnyKernel3

	}

function zipper() {
	cd AnyKernel3 || exit 1
	zip -r9 $KERNEL_NAME-$DEVICE_NAME-${DATE}.zip *
	mkdir -p /sdcard/KERNEL
	cp $KERNEL_NAME-$DEVICE_NAME-${DATE}.zip /sdcard/KERNEL
	cd ..
}

compile
zipper
END=$(date +"%s")
DIFF=$(($END - $START))
echo "Compile took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s)."
