CFLAGS = -O3
CFLAGS += -flto
LDFLAGS += -fuse-ld=lld 

#CFLAGS += -DELF_HOOK_IMPL=1
#CFLAGS += -DELF_HOOK_FIXED_VIA_IF_IMPL=1
#CFLAGS += -DVOLATILE1_IMPL=1
#CFLAGS += -DVOLATILE2_IMPL=1
#CFLAGS += -DVOLATILE3_IMPL=1
#CFLAGS += -DNOINLINE_IMPL=1
#CFLAGS += -DOPTNONE_IMPL=1
#CFLAGS += -DSIMPLE_IMPL=1
#CFLAGS += -DEXTERN_IMPL=1
#CFLAGS += -DEXTERN_PLUS_HOOK_IMPL=1
#CFLAGS += -DMEMORY_BARRIER_IMPL=1

BIN = elf_hook_impl \
	elf_hook_fixed_via_if_impl \
	volatile1_impl \
	volatile2_impl \
	volatile3_impl \
	noinline_impl \
	optnone_impl \
	simple_impl \
	extern_impl \
	extern_plus_hook_impl \
	memory_barrier_impl

all : $(BIN)

#    $(CC) $(CFLAGS) -o $@ -c $<

elf_hook_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DELF_HOOK_IMPL=1 -o elf_hook_impl.o explicit_bzero_test.c

elf_hook_impl: elf_hook_impl.o
	$(CC) $(LDFLAGS) -o elf_hook_impl elf_hook_impl.o

elf_hook_fixed_via_if_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DELF_HOOK_FIXED_VIA_IF_IMPL=1 -o elf_hook_fixed_via_if_impl.o explicit_bzero_test.c

elf_hook_fixed_via_if_impl: elf_hook_fixed_via_if_impl.o
	$(CC) $(LDFLAGS) -o elf_hook_fixed_via_if_impl elf_hook_fixed_via_if_impl.o

volatile1_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DVOLATILE1_IMPL=1 -o volatile1_impl.o explicit_bzero_test.c

volatile1_impl: volatile1_impl.o
	$(CC) $(LDFLAGS) -o volatile1_impl volatile1_impl.o

volatile2_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DVOLATILE2_IMPL=1 -o volatile2_impl.o explicit_bzero_test.c

volatile2_impl: volatile2_impl.o
	$(CC) $(LDFLAGS) -o volatile2_impl volatile2_impl.o

volatile3_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DVOLATILE3_IMPL=1 -o volatile3_impl.o explicit_bzero_test.c

volatile3_impl: volatile3_impl.o
	$(CC) $(LDFLAGS) -o volatile3_impl volatile3_impl.o

noinline_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DNOINLINE_IMPL=1 -o noinline_impl.o explicit_bzero_test.c

noinline_impl: noinline_impl.o
	$(CC) $(LDFLAGS) -o noinline_impl noinline_impl.o

optnone_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DOPTNONE_IMPL=1 -o optnone_impl.o explicit_bzero_test.c

optnone_impl: optnone_impl.o
	$(CC) $(LDFLAGS) -o optnone_impl optnone_impl.o

simple_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DSIMPLE_IMPL=1 -o simple_impl.o explicit_bzero_test.c

simple_impl: simple_impl.o
	$(CC) $(LDFLAGS) -o simple_impl simple_impl.o

extern_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DEXTERN_IMPL=1 -o extern_impl.o explicit_bzero_test.c

extern_impl: extern_impl.o
	$(CC) $(LDFLAGS) -o extern_impl extern_impl.o

extern_plus_hook_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DEXTERN_PLUS_HOOK_IMPL=1 -o extern_plus_hook_impl.o explicit_bzero_test.c

extern_plus_hook_impl: extern_plus_hook_impl.o
	$(CC) $(LDFLAGS) -o extern_plus_hook_impl extern_plus_hook_impl.o

memory_barrier_impl.o: explicit_bzero_test.c
	$(CC) -c $(CFLAGS) -DMEMORY_BARRIER_IMPL=1 -o memory_barrier_impl.o explicit_bzero_test.c

memory_barrier_impl: memory_barrier_impl.o
	$(CC) $(LDFLAGS) -o memory_barrier_impl memory_barrier_impl.o

test: .IGNORE
	for i in $(BIN); do echo $$i; ./$$i; echo "_____"; done;

clean:
	rm -f *.o *.core $(BIN)
