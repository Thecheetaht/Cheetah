TARGET := libcheetah.so
CFLAGS += -Wall -Winline -pipe -fPIC
LDFLAGS += -shared -L"lib" -lSDL -lGL
INCLUDES := -I"inc"
SOURCEDIR := $(shell find src -type d)

SOURCES := $(wildcard $(addsuffix /*.c*, $(SOURCEDIR)))
OBJECTS := $(SOURCES:.c=.o)
PROFILING := $(SOURCES:.c=.gcda)
HEADERS := $(wildcard $(addsuffix /*.h*, $(SOURCEDIR)))

all : $(TARGET)
 
$(TARGET) : $(OBJECTS)
	@echo "Linking $(TARGET)";\
	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS)

%.o : %.c $(HEADERS)
	@echo "Building $<";\
	$(CC) $(CFLAGS) $(INCLUDES) -o "$@" -c "$<"
 
clean :
	@echo "Cleaning...";\
	rm -f $(OBJECTS) $(PROFILING)
