OUT_DIR=output
CC=gnatmake -g
EXEC=example_edf

all: compile move

compile:
	$(CC) $(EXEC)

move:
	mv $(EXEC) ../../$(OUT_DIR)

clean:
	rm b~*
	gnatclean -c $(EXEC)
	
