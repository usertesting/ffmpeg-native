export ANDROID_NDK=/home/chrisf/adt/android-ndk-r8e/
export TOOLCHAIN=/home/chrisf/projects/annotate/cross/
export SYSROOT=$TOOLCHAIN/sysroot/
export PATH=$TOOLCHAIN/bin:$PATH
export CC=arm-linux-androideabi-gcc
export LD=arm-linux-androideabi-ld
export AR=arm-linux-androideabi-ar

#DEBUG=-g

OLD_CFLAGS="-O3 -Wall -mthumb -pipe -fpic -fasm \
  -finline-limit=300 -ffast-math \
  -fstrict-aliasing -Werror=strict-aliasing \
  -fmodulo-sched -fmodulo-sched-allow-regmoves \
  -Wno-psabi -Wa,--noexecstack \
  -D__ARM_ARCH_5__ -D__ARM_ARCH_5E__ \
  -D__ARM_ARCH_5T__ -D__ARM_ARCH_5TE__ \
  -DANDROID -DNDEBUG"
OLD_EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=softfp "

CFLAGS="--arch=armv7-a --cpu=cortex-a8"
EXTRA_CFLAGS="-O3 $DEBUG -ffast-math -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad -DANDROID -DNDEBUG"
EXTRA_LDFLAGS="$DEBUG -Wl,--fix-cortex-a8"
LDFLAGS="$DEBUG --fix-cortex-a8"

FFMPEG_FLAGS="--prefix=/$TOOLCHAIN/build \
  --target-os=linux \
  --enable-cross-compile \
  --cross-prefix=arm-linux-androideabi- \
  --enable-shared \
  --enable-avresample \
  --disable-symver \
  --disable-doc \
  --disable-ffplay \
  --disable-ffmpeg \
  --disable-ffprobe \
  --disable-ffserver \
  --disable-avdevice \
  --disable-avfilter \
  --disable-devices \
  --disable-bsfs \
  --disable-network \
  --enable-swscale  \
  --enable-encoders \
  --enable-muxers \
  --enable-filters \
  --enable-asm \
  --disable-libx264 \
  --disable-encoder=libx264 \
  --enable-encoder=h264 \
  --enable-decoder=h264 \
  --enable-decoder=aac \
  --enable-demuxer=mpeg4 \
  --enable-demuxer=acc \
  --enable-parser=mpeg4 \
  --disable-encoder=flac \
  --enable-version3"

./configure $FFMPEG_FLAGS --enable-neon $CFLAGS --extra-cflags="$EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS"
make clean
make -j4
rm libavcodec/log2_tab.o libswresample/log2_tab.o libavformat/log2_tab.o

$LD -o ../obj/armv7neon/libffmpeg.so -shared -soname libffmpeg.so --sysroot=$SYSROOT -z noexecstack $LDFLAGS ../_ashldi3.o libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o  libavformat/*.o  libswscale/*.o libswresample/arm/*.o -lz -lm -lc

CFLAGS="--arch=armv6"
EXTRA_CFLAGS="-O3 $DEBUG -ffast-math -mfloat-abi=softfp -DANDROID -DNDEBUG"
LDFLAGS="$DEBUG"
./configure $FFMPEG_FLAGS $CFLAGS --extra-cflags="$EXTRA_CFLAGS" --extra-ldflags="$EXTRA_LDFLAGS"
make clean
make -j4
rm libavcodec/log2_tab.o libswresample/log2_tab.o libavformat/log2_tab.o

$LD -o ../obj/armv6/libffmpeg.so -shared -soname libffmpeg.so --sysroot=$SYSROOT -z noexecstack $LDFLAGS libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o  libavformat/*.o  libswscale/*.o libswresample/arm/*.o ../_ashldi3.o -lz -lm -lc
