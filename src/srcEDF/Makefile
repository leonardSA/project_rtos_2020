OUT_DIR=output
CC=gnatmake -g
EXEC=example_edf

all: compile move

compile:
	@echo "\033[1;33m==> COMPILING $(EXEC)\033[0m"
	$(CC) $(EXEC)
	@echo "\033[1;32m==> $(EXEC) COMPILATION SUCCESFUL\033[0m"

move:
	mv $(EXEC) ../../$(OUT_DIR)

clean:
	rm b~*
	gnatclean -c $(EXEC)
	
