## Synopsis

Code originally found here
https://gist.github.com/jiixyj/3e3389649c866f7ff7bd

I added a makefile and the memory_fence implementation.

## Motivation

I wanted to test explicit_bzero in the preseence of LTO

## Tests

% make test

On FreeBSD 12:

```
~/explict_bzero_tests % make test
cc -c -O3 -flto -DELF_HOOK_IMPL=1 -o elf_hook_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o elf_hook_impl elf_hook_impl.o
cc -c -O3 -flto -DELF_HOOK_FIXED_VIA_IF_IMPL=1 -o elf_hook_fixed_via_if_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o elf_hook_fixed_via_if_impl elf_hook_fixed_via_if_impl.o
cc -c -O3 -flto -DVOLATILE1_IMPL=1 -o volatile1_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o volatile1_impl volatile1_impl.o
cc -c -O3 -flto -DVOLATILE2_IMPL=1 -o volatile2_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o volatile2_impl volatile2_impl.o
cc -c -O3 -flto -DVOLATILE3_IMPL=1 -o volatile3_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o volatile3_impl volatile3_impl.o
cc -c -O3 -flto -DNOINLINE_IMPL=1 -o noinline_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o noinline_impl noinline_impl.o
cc -c -O3 -flto -DOPTNONE_IMPL=1 -o optnone_impl.o explicit_bzero_test.c
explicit_bzero_test.c:79:17: warning: unknown attribute 'optimize' ignored [-Wunknown-attributes]
__attribute__ ((optimize(0))) void explicit_bzero(void *b, size_t len) {
                ^
1 warning generated.
cc  -fuse-ld=lld -o optnone_impl optnone_impl.o
cc -c -O3 -flto -DSIMPLE_IMPL=1 -o simple_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o simple_impl simple_impl.o
cc -c -O3 -flto -DEXTERN_IMPL=1 -o extern_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o extern_impl extern_impl.o
cc -c -O3 -flto -DEXTERN_PLUS_HOOK_IMPL=1 -o extern_plus_hook_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o extern_plus_hook_impl extern_plus_hook_impl.o
cc -c -O3 -flto -DMEMORY_BARRIER_IMPL=1 -o memory_barrier_impl.o explicit_bzero_test.c
cc  -fuse-ld=lld -o memory_barrier_impl memory_barrier_impl.o
for i in elf_hook_impl  elf_hook_fixed_via_if_impl  volatile1_impl  volatile2_impl  volatile3_impl  noinline_impl  optnone_impl  simple_impl  extern_impl  extern_plus_hook_impl  memory_barrier_impl; do echo $i; ./$i; echo "_____"; done;
elf_hook_impl
Assertion failed: ((count_secrets(buf)) == (0)), function do_test_with_bzero, file explicit_bzero_test.c, line 241.
Abort trap
_____
elf_hook_fixed_via_if_impl
_____
volatile1_impl
_____
volatile2_impl
_____
volatile3_impl
_____
noinline_impl
_____
optnone_impl
Assertion failed: ((count_secrets(buf)) == (0)), function do_test_with_bzero, file explicit_bzero_test.c, line 241.
Abort trap
_____
simple_impl
Assertion failed: ((count_secrets(buf)) == (0)), function do_test_with_bzero, file explicit_bzero_test.c, line 241.
Abort trap
_____
extern_impl
_____
extern_plus_hook_impl
_____
memory_barrier_impl
_____
:~/explict_bzero_tests %
```

## License

License is in the top of explicit_bzero_test.c

