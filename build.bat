REM this script assumes that the Microsoft.VisualStudio.Component.WinXP
REM component is available in the local Visual Studio installation.

powershell -Command^
 "Invoke-WebRequest https://github.com/xavery/openssl10-static-xp/releases/download/1.0/OpenSSL-1.0.2u-Static-XP.7z -O openssl.7z"
7z x -oC:\ openssl.7z

call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise\VC\Auxiliary\Build\vcvars32.bat"

REM https://devblogs.microsoft.com/cppblog/windows-xp-targeting-with-c-in-visual-studio-2012/
set INCLUDE=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Include;C:\OpenSSL\include;%INCLUDE%
set PATH=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Bin;%PATH%
set LIB=%ProgramFiles(x86)%\Microsoft SDKs\Windows\7.1A\Lib;C:\OpenSSL\lib;%LIB%

REM the additional linker parameters are taken care of by qmake, since the
REM -target xp switch causes the configure script to set the QMAKE_TARGET_OS
REM variable to "xp", which is then used to define QMAKE_SUBSYSTEM_SUFFIX to
REM ",5.01", which is then passed as the extra suffix to the linker's subsystem
REM parameter.

REM harfbuzz is disabled because of QTBUG-38913
call configure.bat -prefix C:\Qt\5.6.3-Static-XP\ -opensource -confirm-license^
 -release -static -static-runtime -nomake examples -nomake tests -target xp^
 -no-harfbuzz -no-sse2 -no-sse3 -no-ssse3 -no-sse4.1 -no-sse4.2 -no-avx -no-avx2^
 -platform win32-msvc2017 -no-angle -no-opengl -openssl-linked

powershell -Command^
 "Invoke-WebRequest http://download.qt.io/official_releases/jom/jom.zip -O jom.zip"
7z x jom.zip

mkdir C:\Qt
jom
nmake
nmake install
copy C:\OpenSSL\lib\* C:\Qt\5.6.3-Static-XP\lib

cd /d C:\Qt
7z a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on -sse Qt-5.6.3-Static-XP.7z 5.6.3-Static-XP
