all: all2
BUILD_VERBOSE = 0

#
# Various directories
#
ARDUINO = C:\devt\arduino\arduino-1.0.5
TOOLS_PATH = $(ARDUINO)\hardware\tools
COMPILER_PATH = $(TOOLS_PATH)\arm-none-eabi\bin
CORE_PATH = $(ARDUINO)\hardware\teensy\cores/teensy3
CORE_PATH2 := $(subst \,/,$(CORE_PATH))
BUILD = build
PYTHON = C:\Python27\python

PY_ROOT = C:/devt/arduino/micropython
PY_SRC = $(PY_ROOT)/py
PY_BUILD = $(BUILD)/py

STM_SRC = $(PY_ROOT)/stm
MPTEENSY_SRC = $(PY_ROOT)/teensy

QSTR_DEFS = $(STM_SRC)/qstrdefsport.h

#
# includes
#
include util.mk
include py.mk

ECHO = @echo

#
# ARM compiler toolchain...
#
AS = $(COMPILER_PATH)\arm-none-eabi-as
AR = $(COMPILER_PATH)/arm-none-eabi-ar
CC = $(COMPILER_PATH)\arm-none-eabi-gcc
CXX = $(COMPILER_PATH)\arm-none-eabi-g++
LD = $(COMPILER_PATH)\arm-none-eabi-ld
RANLIB = $(COMPILER_PATH)/arm-none-eabi-ranlib
OBJCOPY = $(COMPILER_PATH)\arm-none-eabi-objcopy
SIZE = $(COMPILER_PATH)\arm-none-eabi-size

#
# Sources for this project...
#

SRC_C = \
	stubs.c \
	printf.c \

#	led.c \
#	usart.c \
#	lexermemzip.c \
#	lexerfatfs.c \

SRC_OBJS := $(SRC_C:.c=.o) 

#
# Micropython source files...
#
MPTEENSY_SRC_C = \
	lcd.c \
	usb.c \
	usart.c \
	led.c \

#	memzip.c \
#	lexermemzip.c \
#	lexerfatfs.c \


#
# NOTE: The following are using modified versions located in the libmpython project
# until these changes can be pushed into the main micropython repository
#
#	servo.c \

STM_SRC_C = \
	malloc0.c \

#	string0.c \
#	printf.c \


STM_SRC_S = \
	gchelper.s \

MP_OBJS = $(addprefix $(BUILD)/, $(MPTEENSY_SRC_C:.c=.c.o) $(STM_SRC_C:.c=.c.o) $(STM_SRC_S:.s=.s.o)) $(PY_O)

LIB_OBJS := $(addprefix $(BUILD)/, $(SRC_OBJS)) $(MP_OBJS) 

# The following rule uses | to create an order only prereuisite. Order only
# prerequisites only get built if they don't exist. They don't cause timestamp
# checkng to be performed.
#
# $(sort $(var)) removes duplicates
#
# The net effect of this, is it causes the objects to depend on the
# object directories (but only for existence), and the object directories
# will be created if they don't exist.
OBJ_DIRS = $(sort $(dir $(LIB_OBJS))) $(BUILD)/py/
$(LIB_OBJS): | $(BUILD) $(OBJ_DIRS)
$(OBJ_DIRS):
	-mkdir $(subst /,\,$@)

#$(BUILD):
#	-mkdir $(subst /,\,$@)

#
# configurable options
#
OPTIONS = -DF_CPU=96000000 -DUSB_SERIAL -DLAYOUT_US_ENGLISH -D__MK20DX256__ -DTEENSYDUINO=117 -DUSB_VID=null -DUSB_PID=null -DARDUINO=105 

#
# CPPFLAGS = compiler options for C and C++
#
CPPFLAGS = -Wall -g -Os -mcpu=cortex-m4 -mthumb -nodefaultlibs -MMD $(OPTIONS) -I. -I $(MPTEENSY_SRC) -I $(PY_SRC) -I $(STM_SRC) -I$(CORE_PATH) -Ilibraries

# compiler options for C only
CFLAGS = -std=gnu99

# linker options
LDFLAGS = -nodefaultlibs -Os -Wl,--gc-sections -mcpu=cortex-m4 -mthumb -T$(CORE_PATH)\mk20dx256py.ld

LIBS = -lm -lgcc -mthumb 

all2: libraries/libmpython.a 

libraries/libmpython.a: $(PY_BUILD)/qstrdefs.generated.h $(LIB_OBJS)
	$(Q)$(AR) rcu "$@" $(LIB_OBJS) 
	$(Q)$(RANLIB) $@

#
# .c to .o inference rule
#
$(BUILD)/%.o: %.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(BUILD)/%.c.o: $(MPTEENSY_SRC)/%.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

$(BUILD)/%.s.o: $(STM_SRC)/%.s
	$(ECHO) "AS $<"
	$(Q)$(AS) -o $@ $<

$(BUILD)/%.c.o: $(STM_SRC)/%.c
	$(ECHO) "CC $<"
	$(Q)$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

#$(BUILD):
#	-mkdir $(subst /,\,$(BUILD))

#$(BUILD)/teensy: $(BUILD)
#	-mkdir $(subst /,\,$(BUILD))\teensy

#$(BUILD)/py: $(BUILD)
#	-mkdir $(subst /,\,$(BUILD))\py

#$(BUILD)/py/: $(BUILD)
#	-mkdir $(subst /,\,$(BUILD))\py

clean:
	-rd /q /s $(subst /,\,$(BUILD))
	-del libraries\*.a

test:
#	@echo $(LIB_OBJS)
	@echo $(OBJ_DIRS)

.PHONY: all all2 clean

