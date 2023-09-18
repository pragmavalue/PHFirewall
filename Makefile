## Haiku Generic Makefile v2.6 ##

NAME = PFirewall
TYPE = APP
APP_MIME_SIG = x-vnd.PFirewall

SRCS = \
	src/main.cpp \
	$(wildcard src/gui/*.cpp) \
	$(wildcard src/heuristic/*.cpp) \
	$(wildcard src/include/*.h) \
	$(wildcard src/network/*.cpp) \
	$(wildcard src/preferences/*.cpp) \
	$(wildcard src/taskbar/*.cpp) \

RDEFS = PFirewall.rdef
LIBS = be tracker shared localestub yaml-cpp $(STDCPPLIBS)

LIBPATHS = $(shell findpaths -e -a $(shell uname -p) B_FIND_PATH_DEVELOP_LIB_DIRECTORY)
SYSTEM_INCLUDE_PATHS = \
	$(shell findpaths -e B_FIND_PATH_HEADERS_DIRECTORY private/interface) \
	$(shell findpaths -e B_FIND_PATH_HEADERS_DIRECTORY private/shared) \
	$(shell findpaths -e B_FIND_PATH_HEADERS_DIRECTORY private/storage) \
	$(shell findpaths -e B_FIND_PATH_HEADERS_DIRECTORY private/tracker) \
	
LOCAL_INCLUDE_PATHS = src/gui src/heristic src/network src/taskbar \
	src/preferences src/include
LOCALES = en pl

SYMBOLS := TRUE
DEBUGGER := TRUE
# -gno-column-info is a workaround for Debugger issue (#15159)
COMPILER_FLAGS = -gno-column-info -std=c++17 -Werror

## Include the Makefile-Engine
DEVEL_DIRECTORY := \
	$(shell findpaths -r "makefile_engine" B_FIND_PATH_DEVELOP_DIRECTORY)
include $(DEVEL_DIRECTORY)/etc/makefile-engine

# TESTS

TEST_DIR := test

$(OBJ_DIR)/$(TEST_DIR)-%.o : $(TEST_DIR)/%.cpp
	$(C++) -c $< $(INCLUDES) $(CFLAGS) -o "$@"

TEST_SRCS = \
	main.cpp \
	TestUtils.cpp \
	TestFindReplace.cpp

TEST_OBJECTS = $(addprefix $(OBJ_DIR)/test-, $(addsuffix .o, $(foreach file, \
	$(TEST_SRCS), $(basename $(notdir $(file))))))

TEST_TARGET = $(TARGET_DIR)/$(NAME)_tests

TEST_BASE_OBJS = $(filter-out $(OBJ_DIR)/main.o,$(OBJS))

$(TEST_TARGET): $(TEST_BASE_OBJS) $(TEST_OBJECTS)
	$(LD) -o "$@" $(TEST_BASE_OBJS) $(TEST_OBJECTS) $(LDFLAGS) -lgtest

check : $(TEST_TARGET)
	$(TEST_TARGET)

check-debug : $(TEST_TARGET)
	Debugger $(TEST_TARGET)
