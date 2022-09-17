helloword: helloword.c libmain.a
        gcc -g -o helloword helloword.c libmain.a
libmain.a: main.o
        ar -cvq libmain.a main.o
main.o: main.s
        as -g -o main.o main.s
limpo:
        rm *.o *.a helloword

