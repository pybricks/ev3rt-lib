#
# Makefile for a Loadable User Module (LEGO Mindstorms EV3)
#

# Specify the directory of HRP2 source
KERNELDIR = @(SRCDIR)
TARGETDIR = $(KERNELDIR)/target/ev3_gcc
LOADERDIR = $(KERNELDIR)/target/ev3_gcc/dmloader
APPLDIR   = @(APPLDIRS)
APPL_DIR  = $(APPLDIR)
SRCDIRS  += $(APPL_DIR) $(KERNELDIR)/target/ev3_gcc/TLSF-2.4.6/src

#
# Common EV3RT Paths
#
EV3RT_SDK_COM_DIR := $(EV3RT_BASE_DIR)/sdk/common
INCLUDES += -I$(EV3RT_SDK_COM_DIR)

#
# EV3RT C Language API
#
EV3RT_SDK_API_DIR := $(EV3RT_BASE_DIR)/sdk/common/ev3api
APPL_DIRS += $(EV3RT_SDK_API_DIR)/src
INCLUDES += -I$(EV3RT_SDK_API_DIR) -I$(EV3RT_SDK_API_DIR)/include
include $(EV3RT_SDK_API_DIR)/Makefile

#
# Static libraries
#
EV3RT_SDK_LIB_DIR := $(EV3RT_BASE_DIR)/sdk/common/library

#
# Add include/ and src/ under application directory to search path
#
INCLUDES += $(foreach dir,$(shell find $(APPLDIRS) -type d -name include),-I$(dir))
APPL_DIRS += $(foreach dir,$(shell find $(APPLDIRS) -type d -name src),$(dir))
SRCDIRS += $(APPL_DIRS)

# Compiler options
COPTS += -DTOPPERS_OMIT_TECS @(COPTS)
GCC_TARGET = arm-none-eabi
INCLUDES += -I$(APPL_DIR) \
			-I$(APPL_DIR)/../common \
			-I$(LOADERDIR)/app \
			-I$(KERNELDIR)/target/ev3_gcc \
			-I$(KERNELDIR)/target/ev3_gcc/drivers/common/include \
			-I$(KERNELDIR)/arch/arm_gcc/am1808 \
			-I$(KERNELDIR)/arch/arm_gcc/common \
			-I$(KERNELDIR)/arch/gcc \
		   	-I$(KERNELDIR)/target/ev3_gcc/TLSF-2.4.6/include \
		   	-I$(KERNELDIR)/target/ev3_gcc/platform/include \
		   	-I$(KERNELDIR)/target/ev3_gcc/pil/include
INCLUDES += $(PROJECT_INCLUDE)


OBJNAME = app

OBJFILE = $(OBJNAME)

all: $(OBJFILE)

MODOBJS += t_perror.o strerror.o vasyslog.o tlsf.o

MODCFG = $(APPL_DIR)/app.cfg

MODDIR = $(PWD)

OMIT_DEBUG_INFO = 1

#
# Include common part
#
BUILD_LOADABLE_MODULE = 1
CONFIG_EV3RT_APPLICATION = 1
include $(APPL_DIR)/Makefile.inc
ifeq ($(SRCLANG),c++)
  USE_CXX = true
  APPL_CXXOBJS += @(APPLOBJS)
  CXXLIBS = -lstdc++ -lc -lm -lgcc
  #CXXRTS = crtbegin.o crtend.o
  #CXXRTS = cxxrt.o newlibrt.o
else
  MODOBJS += @(APPLOBJS)
endif
#include $(KERNELDIR)/target/ev3_gcc/api/Makefile
MODOBJS += $(APPL_COBJS)

include $(LOADERDIR)/app/Makefile.lum
