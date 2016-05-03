.SUFFIXES : .c .cpp .o#变量"SUFFIXE"用来定义默认的后缀列表

OBJECTS = ./main.o						\
		  ./Common/performance.o		\
		  ./Common/LogMsg.o				\
		  ./FrameExtractor/FileRead.o 		\
		  ./FrameExtractor/FrameExtractor.o 	\
		  ./FrameExtractor/H263Frames.o		\
		  ./FrameExtractor/H264Frames.o		\
		  ./FrameExtractor/MPEG4Frames.o	\
		  ./FrameExtractor/VC1Frames.o		\
		  ./JPEG_API/JPGApi.o			\
		  ./MFC_API/SsbSipH264Decode.o	\
		  ./MFC_API/SsbSipH264Encode.o	\
		  ./MFC_API/SsbSipMfcDecode.o	\
		  ./MFC_API/SsbSipMpeg4Decode.o	\
		  ./MFC_API/SsbSipMpeg4Encode.o	\
		  ./MFC_API/SsbSipVC1Decode.o \
		  ./CharSet.o            \
		  ./YUVOSDMixer.o        \
		  ./Raptor/raptorcode.o		\
		  ./Raptor/matrix.o     

SRCS =    ./main.cpp   				\
		  ./Common/performance.c		\
		  ./Common/LogMsg.c			\
		  ./FrameExtractor/FileRead.c 		\
	  	  ./FrameExtractor/FrameExtractor.c 	\
		  ./FrameExtractor/H263Frames.c		\
		  ./FrameExtractor/H264Frames.c		\
		  ./FrameExtractor/MPEG4Frames.c	\
		  ./FrameExtractor/VC1Frames.c		\
		  ./JPEG_API/JPGApi.c			\
		  ./MFC_API/SsbSipH264Decode.c	\
		  ./MFC_API/SsbSipH264Encode.c	\
		  ./MFC_API/SsbSipMfcDecode.c	\
		  ./MFC_API/SsbSipMpeg4Decode.c	\
		  ./MFC_API/SsbSipMpeg4Encode.c	\
		  ./MFC_API/SsbSipVC1Decode.c   \
		  ./CharSet.cpp            \
		  ./YUVOSDMixer.cpp        \
		  ./Raptor/raptorcode.c          \
		  ./Raptor/matrix.c          
		  

#SRCS = $(OBJECTS:.o=.c)#和“$(patsubst %.o,%.c,$(objects))”是一样的,patsubst模式字符串替换函数
DEPENDENCY = ./Common/lcd.h 			\
		     ./Common/LogMsg.h 			\
		     ./Common/mfc.h 			\
		     ./Common/MfcDriver.h 		\
		     ./Common/MfcDrvParams.h 	\
		     ./Common/performance.h 	\
			 ./Common/post.h			\
			 ./Common/videodev2.h		\
			 ./Common/videodev2_s3c.h	\
			 ./Common/videodev2_s3c_tv.h	\
			 ./FrameExtractor/FileRead.h 		\
		     ./FrameExtractor/FrameExtractor.h 	\
		     ./FrameExtractor/H263Frames.h 		\
		     ./FrameExtractor/H264Frames.h 		\
		     ./FrameExtractor/MPEG4Frames.h 	\
		     ./FrameExtractor/VC1Frames.h 		\
			 ./JPEG_APIJPGApi.h					\
			 ./MFC_API/SsbSipH264Decode.h		\
		     ./MFC_API/SsbSipH264Encode.h		\
		     ./MFC_API/SsbSipMfcDecode.h		\
		     ./MFC_API/SsbSipMpeg4Decode.h		\
		     ./MFC_API/SsbSipMpeg4Encode.h		\
		     ./MFC_API/SsbSipVC1Decode.h		\
		     ./CharSet.h             \
		     ./YUVOSDMixer.h         \
		     ./myHead.h              \
		     ./YUVOSDMixerT.h        \
			 ./Raptor/raptorcode.h   \
			 ./Raptor/matrix.h       \
	  		 ./main.h							
#			 ./lt_enc.h                         \
#			 ./g729a_src/g729a/typedef.h        \
#			 ./g729a_src/g729a/basic_op.h       \
#			 ./g729a/ld8a.h                     \


#音频处理库
#LIBRARY = /nfsboot/usr/share/arm-alsa/lib/libasound.s729a_arm.a
#CC = /root/usr/local/arm/4.3.2/bin/arm-linux-gcc-4.3.2
#CC = /usr/local/arm/4.3.2/bin/arm-linux-gcc-4.3.2
#CFLAGS = -g -c -lm -DLCD_SIZE_43 -Os -std=gnu99

LIBRARY = /usr/share/arm-alsa/lib/libasound.so ./libg729a_arm.a 

CC = arm-none-linux-gnueabi-g++ 

CFLAGS = -g -c -Os -Wall -DLCD_SIZE_43 
#INC = -I./Common -I./FrameExtractor -I./MFC_API -I./JPEG_API -I./g729a_src -I/nfsboot/usr/share/arm-alsa/include -I./
#INC = -I./Common -I./FrameExtractor -I./MFC_API -I./JPEG_API -I/home/xuyy/arm-alsa/include -I./Raptor
#INC = -I./g729a_src -I./Common -I./FrameExtractor -I./MFC_API -I./JPEG_API -I/usr/share/arm-alsa/include  -I./Raptor -I/usr/local/arm/4.3.2/arm-none-linux-gnueabi/include/opencv
INC = -I./g729a_src -I./Common -I./FrameExtractor -I./MFC_API -I./JPEG_API -I/usr/share/arm-alsa/include  -I./Raptor -I/usr/local/include/opencv

KERNEL_PATH = ~/download/s3c-linux-2.6.28.6-TOP6410

INC += -I$(KERNEL_PATH)/include

TARGET = multimedia_test

all : common frame_extractor jpeg_api mfc_api raptor multimedia_test
common : 
		cd Common; $(MAKE)

frame_extractor : 
		cd FrameExtractor; $(MAKE)

jpeg_api : 
		cd JPEG_API; $(MAKE)

mfc_api : 
		cd MFC_API; $(MAKE)

raptor :
		cd Raptor; $(MAKE)

$(TARGET) : $(OBJECTS) $(LIBRARY)
		$(CC) $(OBJECTS) $(LIBRARY) -L/usr/local/arm/4.3.2/arm-none-linux-gnueabi/lib -lcv -lcxcore -lrt -lcvaux -lm -lpng -ljpeg -lz -lml -lhighgui -ldl -lpthread -o$(TARGET)
#规则表示所有的 .o文件都是依赖与相应的.c文件的
.c.o :
		$(CC) $(INC) $(CFLAGS) $<
.cpp.o :
		$(CC) $(INC) $(CFLAGS) $<

clean :
		rm -rf $(OBJECTS) $(TARGET) core

