## Synopsis

Test harness for function elision.

## Discussion

There is an issue where calls to bzero (memset(), etc) can be eliminated due to an optimizing compiler eliminating the call to bzero() (or memset(), etc) because the arguments to the call are not subsequently used by the function. The compiler can interpret this as "no side effects", and eliminate the call.

The origin source of issue to being brought to light with a 'security focus' is here: http://cwe.mitre.org/data/definitions/14.html

OpenBSD implemented explicit_bzero() as a response (over a decade after the report) in OpenBSD 5.5 (released May 1, 2014).
http://www.openbsd.org/cgi-bin/man.cgi/OpenBSD-current/man3/bzero.3?query=explicit%5fbzero&arch=i386

The implementation in OpenBSD is here:
http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/sys/lib/libkern/explicit_bzero.c?rev=1.3&content-type=text/x-cvsweb-markup
http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/sys/lib/libkern/bzero.c?rev=1.9&content-type=text/x-cvsweb-markup
http://cvsweb.openbsd.org/cgi-bin/cvsweb/src/sys/lib/libkern/memset.c?rev=1.7&content-type=text/x-cvsweb-markup

FreeBSD subsequently copied this implementation.
https://github.com/freebsd/freebsd/blob/e79c62ff68fc74d88cb6f479859f6fae9baa5101/crypto/openssh/openbsd-compat/explicit_bzero.c
https://github.com/freebsd/freebsd/blob/e79c62ff68fc74d88cb6f479859f6fae9baa5101/sys/libkern/explicit_bzero.c

In the presence of a sufficiently optimized compiler, I believe both implementations are flawed.

Link Time Optimization (LTO) is a problem for several implementations of explicit_bzero(). 

LTO is enabled today in clang. It also works with several versions of GCC.

On FreeBSD 12 with clang/lld:
```
CFLAGS = -O <any level) -flto
LDFLAGS += -fuse-ld=lld
```

and WITH_LLD_IS_LLD=yes in /etc/src.conf to enable lld.

See also:
http://llvm.org/docs/LinkTimeOptimization.html
http://llvm.org/docs/GoldPlugin.html
https://wiki.freebsd.org/LinkTimeOptimisations <--- page is out of date

This exact scenario happened, on FreeBSD, (and OpenBSD): https://github.com/libressl-portable/openbsd/issues/5 
(note that someone tested on OpenBSD 5.5 with GCC 4.8.2 from ports, and developed a "patch" that depends on mfence (compiler side-effects):
https://github.com/libressl-portable/openbsd/issues/5#issuecomment-50775260)

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
~/explict_bzero_tests %
```

There are three cases that fail to clear the 'secret' because the call to explicit_bzero() has been elided by the compiler.

- elf_hook_impl exactly matches the implementation in OpenBSD and FreeBSD (links above).

- simple_impl exactly matches the implementation in the implementation in crypto/openssh/openbsd-compat/explicit_bzero.c, this is used if HAVE_EXPLICIT_BZERO is not defined.

- optnone_impl fails because the gcc attribute "__attribute__ ((optimize(0)))" isn't supported with Clang.

All the other tests currently pass (on FreeBSD 12).

## License

License is in the top of explicit_bzero_test.c

