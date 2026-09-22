-include ./paths
# From file 'paths': TOOLS

# Переменные doxygen
DOXYGEN       = doxygen
DOXYFILE      = Doxyfile
DOC_DIR       = doc

# Автоматическое определение количества ядер в Linux
ifeq ($(filter -j%,$(MAKEFLAGS)),)
    NUM_CORES := $(shell nproc)
    MAKEFLAGS += -j$(NUM_CORES)
endif

# TARGET := Name of current directory
TARGET := $(notdir $(CURDIR))

# Автоматически находим все поддиректории внутри src
SRC_DIR := $(shell find src -type d)

# Превращаем список папок в аргументы для компилятора: -Isrc -Isrc/Modules ...
INC_FLAGS := $(addprefix -I, $(SRC_DIR))

# Переключатель Debug / Release
ifeq ($(RELEASE), 1)
    BUILD_DIR := Release
    OPT_FLAG  := -O3
    DEBUG_FLAG := 
else
    BUILD_DIR := Debug
    OPT_FLAG  := -O0
    DEBUG_FLAG := -g3
endif

SRC_CPP	:= $(foreach DIR, $(SRC_DIR), $(wildcard $(DIR)/*.cpp))
SRC_C	:= $(foreach DIR, $(SRC_DIR), $(wildcard $(DIR)/*.c))
SRC_ASM	:= $(foreach DIR, $(SRC_DIR), $(wildcard $(DIR)/*.asm))
SRC_S	:= $(foreach DIR, $(SRC_DIR), $(wildcard $(DIR)/*.S))

OBJECTS :=	$(addprefix $(BUILD_DIR)/, $(SRC_C:.c=.o)) \
			$(addprefix $(BUILD_DIR)/, $(SRC_CPP:.cpp=.o)) \
            $(addprefix $(BUILD_DIR)/, $(SRC_ASM:.asm=.o)) \
            $(addprefix $(BUILD_DIR)/, $(SRC_S:.S=.o))

CXX := $(TOOLS)g++
CC := $(TOOLS)gcc

# Строгие нативные флаги + автоматические инклуды $(INC_FLAGS)
COMMON_FLAGS = $(OPT_FLAG) $(DEBUG_FLAG) -Wall -Wextra -Wpedantic \
               -fmessage-length=0 -fsigned-char \
               -ffunction-sections -fdata-sections \
               $(INC_FLAGS) \
               -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)"

CXXFLAGS = $(COMMON_FLAGS) -std=gnu++20 -pthread
CFLAGS   = $(COMMON_FLAGS)
ASFLAGS  = $(COMMON_FLAGS) -x assembler-with-cpp

LDFLAGS := $(OPT_FLAG) $(DEBUG_FLAG) -pthread -Xlinker --gc-sections \
           -Wl,-Map,"$(BUILD_DIR)/$(TARGET).map" 

LDLIBS := 

.PHONY: all clean link

default: all 
all: link

link: $(OBJECTS)
	@echo "Linking target ($(BUILD_DIR)): $(TARGET).elf"
	@mkdir -p $(BUILD_DIR)
	$(CXX) $(LDFLAGS) -o $(BUILD_DIR)/$(TARGET).elf $(OBJECTS) $(LDLIBS)
	@echo "Done"

# Правила компиляции
$(BUILD_DIR)/%.o: %.c
	@echo "Building file: $< -> $@"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c -o "$@" "$<"

$(BUILD_DIR)/%.o: %.cpp
	@echo "Building file: $< -> $@"
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c -o "$@" "$<"

$(BUILD_DIR)/%.o: %.S
	@echo "Building file: $< -> $@"
	@mkdir -p $(dir $@)
	$(CXX) $(ASFLAGS) -c -o "$@" "$<"

$(BUILD_DIR)/%.o: %.asm
	@echo "Building file: $< -> $@"
	@mkdir -p $(dir $@)
	$(CXX) $(ASFLAGS) -c -o "$@" "$<"

# Инклуд файлов зависимостей
-include $(OBJECTS:%.o=%.d)

.PHONY: doc
# Рецепт для генерации документации
doc:
	@which $(DOXYGEN) > /dev/null 2>&1 || (echo "Ошибка: $(DOXYGEN) не установлен. Установите его командой 'sudo apt install doxygen'" && exit 1)
	@echo "Генерация документации Doxygen..."
	@mkdir -p $(DOC_DIR)
	$(DOXYGEN) $(DOXYFILE)
	@echo "Документация успешно создана в директории $(DOC_DIR)/"

# Рецепт для скачивания и установки зависимостей через apt
.PHONY: install-deps
install-deps:
	@echo "Обновление списков пакетов и установка CLI11 и nlohmann-json..."
	sudo apt-get update && sudo apt-get install -y \
		libcli11-dev \
		nlohmann-json3-dev

clean:
	@echo "Clean build and doc directories..."
	@rm -rf Debug
	@rm -rf Release
	@rm -rf $(DOC_DIR)

