CHAINPREFIX=/opt/mipsel-linux-uclibc
CROSS_COMPILE=$(CHAINPREFIX)/usr/bin/mipsel-linux-

BUILDTIME=$(shell date +'\"%Y-%m-%d %H:%M\"')

CC = $(CROSS_COMPILE)gcc
CXX = $(CROSS_COMPILE)g++
STRIP = $(CROSS_COMPILE)strip

SYSROOT     := $(CHAINPREFIX)/usr/mipsel-buildroot-linux-uclibc/sysroot
SDL_CFLAGS  := $(shell $(SYSROOT)/usr/bin/sdl-config --cflags)
SDL_LIBS    := $(shell $(SYSROOT)/usr/bin/sdl-config --libs)

CFLAGS = -DTARGET_RETROFW -D__BUILDTIME__="$(BUILDTIME)" -DLOG_LEVEL=0 -g0 -Os $(SDL_CFLAGS) -I$(CHAINPREFIX)/usr/include/ -I$(SYSROOT)/usr/include/  -I$(SYSROOT)/usr/include/SDL/ -mhard-float -mips32 -mno-mips16
CFLAGS += -std=c++11 -fdata-sections -ffunction-sections -fno-exceptions -fno-math-errno -fno-threadsafe-statics

LDFLAGS = $(SDL_LIBS) -lfreetype -lSDL_image -lSDL_ttf -lSDL -lpthread
LDFLAGS +=-Wl,--as-needed -Wl,--gc-sections -s

pc:
	gcc iotester.c -g -o iotester.dge -ggdb -O0 -DDEBUG -lSDL_image -lSDL -lSDL_ttf -I/usr/include/SDL

retrogame:
	$(CXX) $(CFLAGS) $(LDFLAGS) iotester.c -o iotester.dge

ipk: retrogame
	@rm -rf /tmp/.iotester-ipk/ && mkdir -p /tmp/.iotester-ipk/root/home/retrofw/apps/iotester /tmp/.iotester-ipk/root/home/retrofw/apps/gmenu2x/sections/applications
	@cp -r iotester.dge iotester.png backdrop.png /tmp/.iotester-ipk/root/home/retrofw/apps/iotester
	@cp iotester.lnk /tmp/.iotester-ipk/root/home/retrofw/apps/gmenu2x/sections/applications
	@sed "s/^Version:.*/Version: $$(date +%Y%m%d)/" control > /tmp/.iotester-ipk/control
	@tar --owner=0 --group=0 -czvf /tmp/.iotester-ipk/control.tar.gz -C /tmp/.iotester-ipk/ control
	@tar --owner=0 --group=0 -czvf /tmp/.iotester-ipk/data.tar.gz -C /tmp/.iotester-ipk/root/ .
	@echo 2.0 > /tmp/.iotester-ipk/debian-binary
	@ar r iotester.ipk /tmp/.iotester-ipk/control.tar.gz /tmp/.iotester-ipk/data.tar.gz /tmp/.iotester-ipk/debian-binary

clean:
	rm -rf iotester.dge iotester.ipk
