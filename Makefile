SRC_DIR=src
OUT_DIR=output

.PHONY: output

all: compile

compile: output
	make -C $(SRC_DIR)

log: compile
	cd $(OUT_DIR); for e in `ls -I "*.log"`; do ./$$e > $$e.log ; done

output: compile
	if [ ! -d $(OUT_DIR) ]; then mkdir $(OUT_DIR) ; fi

clean:
	make clean -C $(SRC_DIR)
	rm -rf output
