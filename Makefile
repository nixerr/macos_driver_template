BUILD = build
OBJ = obj

SDK = macosx
ARCH = arm64e

SYSROOT := $(shell xcrun --sdk $(SDK) --show-sdk-path)

CLANG := $(shell xcrun --sdk $(SDK) --find clang)
CLANGPP := $(shell xcrun --sdk $(SDK) --find clang++)

DSYMUTIL := $(shell xcrun --sdk $(SDK) --find dsymutil)

CC := $(CLANG) -isysroot $(SYSROOT) -arch $(ARCH)
CXX := $(CLANGPP) -isysroot $(SYSROOT) -arch $(ARCH)
NASM := nasm

PKG = com.inspector
TARGET = inspector

KFWK = $(SYSROOT)/System/Library/Frameworks/Kernel.framework
IOKIT_FWK = $(SYSROOT)/System/Library/Frameworks/IOKit.framework
DRIVERKIT_FWK = $(SYSROOT)/System/Library/Frameworks/DriverKit.framework

KERNEL_HEADERS = -I$(KFWK)/Headers -I$(IOKIT_FWK)/Headers -I/$(DRIVERKIT_FWK)/Headers

KERNEL_CSOURCES := $(wildcard kernel/*.c)
KERNEL_COBJECTS := $(patsubst kernel/%.c, $(OBJ)/%.o, $(KERNEL_CSOURCES))

KERNEL_CPPSOURCES := $(wildcard kernel/*.cpp)
KERNEL_CPPOBJECTS := $(patsubst kernel/%.cpp, $(OBJ)/%.o, $(KERNEL_CPPSOURCES))

CPATH := $(SYSROOT)/usr/include

CFLAGS += -g -I/usr/include -I/usr/local/include $(KERNEL_HEADERS) -O2 -fmodules -mkernel -I./kernel -nostdlib -nostdinc -DMACH_KERNEL_PRIVATE -O2 -D__KERNEL__ -DAPPLE -DNeXT
LDFLAGS += -g -std=c++20 -fno-builtin -fno-common -nostdinc -L/usr/lib -L/usr/local/lib -D__KERNEL__ -DMACH_KERNEL_PRIVATE -Wl,-kext -DAPPLE -DNeXT  -target arm64e-apple-macos14.5 -Xlinker -reproducible -Xlinker -kext -nostdlib -lkmodc++ -lkmod -lcc_kext
CXXFLAGS += -g -std=c++20 $(KERNEL_HEADERS) -fno-builtin -fno-common -nostdlib -nostdinc -DAPPLE -DNeXT 

.PHONY: all clean

all: $(OBJ) $(BUILD)/$(TARGET).kext/Contents/MacOS $(BUILD)/$(TARGET).kext/Contents/MacOS/$(TARGET) $(BUILD)/$(TARGET).kext/Contents/Info.plist codesign set_owner

$(KERNEL_COBJECTS): $(OBJ)/%.o: kernel/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(KERNEL_CPPOBJECTS): $(OBJ)/%.o: kernel/%.cpp
	$(CXX) $(CFLAGS) $(CXXFLAGS) -g -c $< -o $@

$(OBJ):
	rm $(OBJ)/*.o

$(BUILD)/$(TARGET).kext/Contents/MacOS:
	mkdir -p $@

$(BUILD)/$(TARGET).kext/Contents/MacOS/$(TARGET): $(KERNEL_COBJECTS)
	$(CC) $(LDFLAGS) -framework IOKit -o $@ $(KERNEL_COBJECTS)

$(BUILD)/$(TARGET).kext/Contents/Info.plist: Info.plist | $(BUILD)/$(TARGET).kext/Contents/MacOS
	cp -f $< $@

codesign: $(BUILD)/$(TARGET).kext/Contents/MacOS/$(TARGET)
	codesign --remove-signature $(BUILD)/$(TARGET).kext
	codesign --sign - --force --entitlements Info.plist $(BUILD)/$(TARGET).kext

set_owner: codesign
	sudo chown -R root:wheel $(BUILD)/$(TARGET).kext

clean:
	rm -rf obj/*
	sudo rm -rf $(BUILD)/$(TARGET).kext
