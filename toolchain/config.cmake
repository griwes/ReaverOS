set(REAVEROS_CMAKE_REPO https://github.com/Kitware/CMake)
set(REAVEROS_CMAKE_TAG v3.25.2)
set(REAVEROS_CMAKE_PATTERN v[0-9]+\.[0-9]+\.[0-9]+)
set(REAVEROS_CMAKE_EXCLUDE "")

set(REAVEROS_LLVM_REPO https://github.com/llvm/llvm-project)
set(REAVEROS_LLVM_TAG llvmorg-14.0.1)
set(REAVEROS_LLVM_PATTERN llvmorg-[0-9]+\.[0-9]+\.[0-9]+)
set(REAVEROS_LLVM_EXCLUDE llvmorg-.*-init)

set(REAVEROS_LLVM_BINUTILS_EXTRA_REPO git://sourceware.org/git/binutils-gdb.git)
set(REAVEROS_LLVM_BINUTILS_EXTRA_TAG binutils-2_36_1)
set(REAVEROS_LLVM_BINUTILS_EXTRA_PATTERN binutils-[0-9]+_[0-9]+_[0-9]+)
set(REAVEROS_LLVM_BINUTILS_EXTRA_EXCLUDE "")

set(REAVEROS_DOSFSTOOLS_REPO https://github.com/dosfstools/dosfstools)
set(REAVEROS_DOSFSTOOLS_TAG v4.2)
set(REAVEROS_DOSFSTOOLS_PATTERN v[0-9]+\.[0-9]+)
set(REAVEROS_DOSFSTOOLS_EXCLUDE "")

set(REAVEROS_MTOOLS_DIR ftp://ftp.gnu.org/gnu/mtools/)
set(REAVEROS_MTOOLS_VER mtools-4.0.42.tar.gz)
set(REAVEROS_MTOOLS_PATTERN mtools-[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz)
set(REAVEROS_MTOOLS_EXCLUDE "")
