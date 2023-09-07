.DELETE_ON_ERROR:

AS = rgbasm
ASFLAGS = -E
LD = rgblink
FIX = rgbfix
FIXFLAGS = -f gh

SOURCE_FILE = hack.asm
ROM_US = trax.gb
ROM_JP = totsugeki.gb
NAME_US = hack-us
NAME_JP = hack-jp
OBJECT_FILE_US = $(NAME_US).o
OBJECT_FILE_JP = $(NAME_JP).o
OUTPUT_ROM_US = $(NAME_US).gb
OUTPUT_ROM_JP = $(NAME_JP).gb
OBJS = $(OBJECT_FILE_US) $(OUTPUT_ROM_US) $(OBJECT_FILE_JP) $(OUTPUT_ROM_JP)

all: $(OUTPUT_ROM_US) $(OUTPUT_ROM_JP)

$(OUTPUT_ROM_US): $(OBJECT_FILE_US)
	$(LD) -O $(ROM_US) -o $@ $<
	$(FIX) $(FIXFLAGS) $@

$(OBJECT_FILE_US): $(SOURCE_FILE)
	$(AS) $(ASFLAGS) $< -o $@

$(OUTPUT_ROM_JP): $(OBJECT_FILE_JP)
	$(LD) -O $(ROM_JP) -o $@ $<
	$(FIX) $(FIXFLAGS) $@

$(OBJECT_FILE_JP): $(SOURCE_FILE)
	$(AS) $(ASFLAGS) $< -o $@

.PHONY:
clean:
	rm -rf $(OBJS)
