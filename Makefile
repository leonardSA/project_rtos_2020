SRC_DIR=src
OUT_DIR=output

.PHONY: output

make: output
	make -C $(SRC_DIR)

output:
	if [ ! -d $(OUT_DIR) ]; then mkdir $(OUT_DIR) ; fi

clean:
	make clean -C $(SRC_DIR)
	rm -rf output
