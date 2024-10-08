#
# Makefile for a workspace of EV3 Platform.
#

#
# Include configurations of EV3RT SDK
#

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
EV3RT_BASE_DIR := $(patsubst %/sdk/common/Makefile,%,$(mkfile_path))
export EV3RT_BASE_DIR

SDKDIR              = $(EV3RT_BASE_DIR)/sdk
WSPDIR              = $(EV3RT_BASE_DIR)/sdk/workspace
EV3RT_PRJ_OBJ_DIR   = $(EV3RT_BASE_DIR)/sdk/OBJ/
EV3RT_LIBKERNEL_DIR = $(EV3RT_BASE_DIR)/sdk/common/library/

# Configuration
SRCLANG := c
KERNEL := hrp

#
# Functions
#
get_relpath = $(shell perl -MFile::Spec -e "print File::Spec->abs2rel(q($1),q($2))")

#
# Paths
#
KERNELDIR    := $(EV3RT_BASE_DIR)
OBJDIR       := $(EV3RT_PRJ_OBJ_DIR)
LIBKERNELDIR := $(EV3RT_LIBKERNEL_DIR)
TARGETDIR    := $(EV3RT_BASE_DIR)/target/ev3_gcc

# Object files
OBJFILENAME := $(KERNEL)
OBJBINARY := $(OBJDIR)/$(KERNEL).bin

#
# Determine Makefile for application
# OUTPUT:
# $(APPLDIR):         Absolute path of application folder
# $(MKFILENAME):      File name of Makefile
# $(MKFILE_DIR):      Absolute path of the folder holding Makefile
#
ifdef img
APPLDIR := $(WSPDIR)/$(img)
MKFILENAME := img.mk
endif
ifdef app
APPLDIR := $(WSPDIR)/$(app)
MKFILENAME := app.mk
endif
MKFILE_DIR := $(APPLDIR)
ifeq (,$(wildcard $(mkfile_dir)/$(MKFILENAME)))
MKFILE_DIR := $(SDKDIR)/common
endif



# Target for an application (static)
#
ifdef img

include $(APPLDIR)/Makefile.inc

ifeq (,$(wildcard $(LIBKERNELDIR)/libkernel.a))
# Build libkernel.a if not exist
img: $(APPLDIR) $(LIBKERNELDIR)/libkernel.a prepare-obj-folder
else
img: $(APPLDIR) prepare-obj-folder
endif
	@cd $(OBJDIR) && \
	make offset.h kernel_cfg.h && \
	make -j8 > /dev/null && \
	arm-none-eabi-objcopy -O binary \
	    $(OBJFILENAME) $(call get_relpath,$(OBJBINARY),$(OBJDIR))
	@mkimage -A arm -O linux -T kernel -C none -a 0xc0008000 -e 0xc0008000 \
        -n "TOPPERS/$(KERNEL) Kernel (EV3)" \
		-d $(call get_relpath,$(OBJBINARY),$(WSPDIR)) uImage
	@chmod +x uImage
	@cp $(OBJDIR)/$(OBJFILENAME) $(WSPDIR)

$(LIBKERNELDIR)/libkernel.a: prepare-obj-folder
	@cd $(OBJDIR) && \
	make clean && \
	make libkernel.a && \
	cp libkernel.a $(LIBKERNELDIR)/libkernel.a

endif

#
# Target for an application module (dynamic)
#
ifdef app

include $(APPLDIR)/Makefile.inc

app: $(APPLDIR) prepare-obj-folder
	@cd $(OBJDIR) && \
	make module_cfg.h && \
	make -j8 && \
	cp app $(WSPDIR)/app # && cp app $(WSPDIR)/app-$(subst /,,$(app))

endif

usage:
	@echo make img="<folder>"
	@echo make app="<folder>"
	@echo "make upload [ip=<ev3_ip_address>] [from=<local_file_name>] [to=<remote_file_name>]"
	@echo "make uploadimg [ip=<ev3_ip_address>] [from=<local_image_path>]"

# TODO: check file name carefully
ifndef ip # Default IP
ip := 10.0.10.1
endif
ifndef from # Default local application (or uImage) file name
from := app
uploadimg: from := uImage
endif
ifndef to
to := $(from)
endif
upload:
	@echo = "Upload user application file"
	@echo "  BT PAN IP: $(ip)"
	@echo "  FILE NAME: (Local) \"$(from)\" -> (Remote) \"$(to)\""
	@echo = "Execute cURL:"
	@curl -f --noproxy "*" -H "Content-Type: ev3rt/app" -H 'Content-Disposition: inline; filename="$(to)"' --data-binary @$(from) http://$(ip)/upload > /dev/null
	@echo = Application has been successfully uploaded.

uploadimg:
	@echo = "Upload uImage file"
	@echo "  BT PAN IP: $(ip)"
	@echo "  FILE NAME: (Local) \"$(from)\" -> (Remote) \"/uImage\""
	@echo = "Execute cURL:"
	@curl -f --noproxy "*" -H "Content-Type: ev3rt/img" --data-binary @$(from) http://$(ip)/upload > /dev/null
	@echo = uImage has been successfully uploaded.


clean:
	rm -rf $(OBJDIR)

realclean: clean
	rm -rf $(notdir $(OBJFILENAME)) uImage app $(LIBKERNELDIR)/libkernel.a

#
# Phony target for preparing $(OBJDIR) folder
#
ifdef app
configure_copts := -DBUILD_MODULE
endif
prepare-obj-folder: clean
	@mkdir -p $(OBJDIR)
	@cd $(OBJDIR) && \
	$(KERNELDIR)/configure.rb -w -T ev3_gcc -A app \
		-S "banner.o syslog.o serial.o logtask.o" \
		-a $(call get_relpath,$(APPLDIR),$(OBJDIR)) \
		-D $(call get_relpath,$(KERNELDIR),$(OBJDIR)) \
		-L $(call get_relpath,$(LIBKERNELDIR),$(OBJDIR)) \
		-l $(SRCLANG) \
		-m $(call get_relpath,$(MKFILE_DIR)/$(MKFILENAME),$(OBJDIR)) \
		-o "$(configure_copts)" \
		-U "$(APPLOBJS)" && \
	make clean


.PHONY: clean realclean prepare-obj-folder img app

