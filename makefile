all: main
main: main.o
        ld -g -o main main.o
main.o: main.s
        as -g -o main.o main.s
helloword: helloword.c libmain.a
        gcc -g -o hellword helloword.c libmain.a
libmain.a: main.o
        ar -cvq libmain.a main.o
limpo:
        rm *.o *.a helloword