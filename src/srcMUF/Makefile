OUT_DIR=output
CC=gnatmake -g
EXEC=example_muf

all: compile move

compile:
	@echo "\033[1;33m==> COMPILING $(EXEC)\033[0m"
	for e in `ls | grep ^$(EXEC).*.adb`; do $(CC) $$e; done
	@echo "\033[1;32m==> $(EXEC) COMPILATION SUCCESFUL\033[0m"

move:
	for e in `ls | grep $(EXEC)`;\
		do if [ -x $$e ]; then mv $$e ../../$(OUT_DIR); fi;\
	done

clean:
	for e in `ls | grep $(EXEC)`; do gnatclean -c $$e ; done
	rm b~*
