DC = dmd

IMPORTS = ./Derelict3/import/
LIBPATH = ./Derelict3/lib/$(DC)

LIBS = dl DerelictGL3 DerelictSDL2 DerelictUtil

TEXTIMPORTS = ./

##############################################

all: sdl

sdl: sdl.d *.glsl
	$(DC) -g $< $(addprefix -J, $(TEXTIMPORTS)) $(addprefix -I, $(IMPORTS)) $(addprefix -L-L, $(LIBPATH)) $(addprefix -L-l, $(LIBS))

clean:
	rm -f *.o *~ sdl

.PHONY: run
run: all
	./sdl
