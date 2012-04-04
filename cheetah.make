# C Shared Library Makefile autogenerated by premake
# Don't edit this file! Instead edit `premake.lua` then rerun `make`

ifndef CONFIG
  CONFIG=Release
endif

# if multiple archs are defined turn off automated dependency generation
DEPFLAGS := $(if $(word 2, $(TARGET_ARCH)), , -MMD)

ifeq ($(CONFIG),Release)
  BINDIR := bin/Release
  LIBDIR := .
  OBJDIR := obj/Release
  OUTDIR := bin/Release
  CPPFLAGS := $(DEPFLAGS) -I "inc"
  CFLAGS += $(CPPFLAGS) $(TARGET_ARCH) -fPIC -g -O3 -fomit-frame-pointer -ffast-math -Wall
  CXXFLAGS += $(CFLAGS)
  LDFLAGS += -L$(BINDIR) -L$(LIBDIR) -shared -s -L"lib" -lSDL -lSDLmain -lGL
  LDDEPS :=
  RESFLAGS := -I "inc"
  TARGET := libcheetah.so
 BLDCMD = $(CC) -o $(OUTDIR)/$(TARGET) $(OBJECTS) $(LDFLAGS) $(RESOURCES) $(TARGET_ARCH)

  define postbuildcmd
	@echo Running post-build commands...
	./genheader.sh
  endef
endif

OBJECTS := \
	$(OBJDIR)/render.o \
	$(OBJDIR)/event.o \
	$(OBJDIR)/filesystem.o \
	$(OBJDIR)/thread.o \
	$(OBJDIR)/shader.o \
	$(OBJDIR)/font.o \
	$(OBJDIR)/graphics.o \
	$(OBJDIR)/framebuffer.o \
	$(OBJDIR)/SOIL.o \
	$(OBJDIR)/stb_image_aug.o \
	$(OBJDIR)/image_DXT.o \
	$(OBJDIR)/image_helper.o \

MKDIR_TYPE := msdos
CMD := $(subst \,\\,$(ComSpec)$(COMSPEC))
ifeq (,$(CMD))
  MKDIR_TYPE := posix
endif
ifeq (/bin,$(findstring /bin,$(SHELL)))
  MKDIR_TYPE := posix
endif
ifeq ($(MKDIR_TYPE),posix)
  CMD_MKBINDIR := mkdir -p $(BINDIR)
  CMD_MKLIBDIR := mkdir -p $(LIBDIR)
  CMD_MKOUTDIR := mkdir -p $(OUTDIR)
  CMD_MKOBJDIR := mkdir -p $(OBJDIR)
else
  CMD_MKBINDIR := $(CMD) /c if not exist $(subst /,\\,$(BINDIR)) mkdir $(subst /,\\,$(BINDIR))
  CMD_MKLIBDIR := $(CMD) /c if not exist $(subst /,\\,$(LIBDIR)) mkdir $(subst /,\\,$(LIBDIR))
  CMD_MKOUTDIR := $(CMD) /c if not exist $(subst /,\\,$(OUTDIR)) mkdir $(subst /,\\,$(OUTDIR))
  CMD_MKOBJDIR := $(CMD) /c if not exist $(subst /,\\,$(OBJDIR)) mkdir $(subst /,\\,$(OBJDIR))
endif

.PHONY: clean

$(OUTDIR)/$(TARGET): $(OBJECTS) $(LDDEPS) $(RESOURCES)
	@echo Linking cheetah
	-@$(CMD_MKBINDIR)
	-@$(CMD_MKLIBDIR)
	-@$(CMD_MKOUTDIR)
	@$(BLDCMD)
	$(postbuildcmd)

clean:
	@echo Cleaning cheetah
ifeq ($(MKDIR_TYPE),posix)
	-@rm -f $(OUTDIR)/$(TARGET)
	-@rm -rf $(OBJDIR)
else
	-@if exist $(subst /,\,$(OUTDIR)/$(TARGET)) del /q $(subst /,\,$(OUTDIR)/$(TARGET))
	-@if exist $(subst /,\,$(OBJDIR)) del /q $(subst /,\,$(OBJDIR))
	-@if exist $(subst /,\,$(OBJDIR)) rmdir /s /q $(subst /,\,$(OBJDIR))
endif

$(OBJDIR)/render.o: src/render.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/event.o: src/event.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/filesystem.o: src/filesystem.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/thread.o: src/thread.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/shader.o: src/shader.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/font.o: src/font.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/graphics.o: src/graphics.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/framebuffer.o: src/framebuffer.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/SOIL.o: src/SOIL/SOIL.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/stb_image_aug.o: src/SOIL/stb_image_aug.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/image_DXT.o: src/SOIL/image_DXT.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

$(OBJDIR)/image_helper.o: src/SOIL/image_helper.c
	-@$(CMD_MKOBJDIR)
	@echo $(notdir $<)
	@$(CC) $(CFLAGS) -o "$@" -c "$<"

-include $(OBJECTS:%.o=%.d)

