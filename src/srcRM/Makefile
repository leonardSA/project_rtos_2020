OUT_DIR=output
CC=gnatmake -g
EXEC=exampleRM

all: compile move

compile:
	$(CC) $(EXEC)

move:
	mv $(EXEC) ../../$(OUT_DIR)

clean:
	rm b~*
	gnatclean -c $(EXEC)
	
