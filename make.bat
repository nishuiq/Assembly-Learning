@echo off
rem make xxx 不要加.asm，另外汇编源代码要保存为.asm，不然masm和link会找不到文件
rem 鉴于DOSBox中的终端版本DOS v5.00
rem 版本太老了，很多命令、功能没有，凑合用吧
rem echo不能用中文，会乱码
cls
if "%1" == ""      goto empty
if "%1" == "help"  goto helper
if "%1" == "clean" goto clean

:make
rem 快速汇编、链接
    if not exist "exp\%1.asm" goto Not_found
    
    echo ======================== start to masm ========================
    masm exp\%1;
    echo ======================== start to link ========================
    link %1;
    echo ========================  completed  ========================
    goto end

:clean
rem 清除临时文件
    echo del [tmp.obj] [tmp.exe] if exist
    echo ========================  completed  ========================
    if exist *.obj  del *.obj
    if exist t*.exe del t*.exe
    goto end

:helper
rem 帮助
    echo Usage: make [command] [file ...]
    echo To compile file.asm to file.exe
    echo.
    echo Usage: make [clean]
    echo To del .ojb and .exe if exist in current path
    echo.
    goto end

:empty
    echo File Name empty!
    goto end

:Not_found
    echo Not Found in exp\%1.asm
    goto end

:end
