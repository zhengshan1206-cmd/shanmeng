#!/bin/bash
# 设置 Python 解释器路径，若 Python 已添加到系统环境变量，可直接使用 python3
PYTHON_EXE=python3
# 设置要执行的 Python 文件路径
SCRIPT_PATH=script/main.py
# 执行 Python 文件
$PYTHON_EXE $SCRIPT_PATH "$@"