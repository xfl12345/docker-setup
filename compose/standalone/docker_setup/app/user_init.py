#!/usr/bin/env python3
import os
import re
import time
import platform
from pathlib import Path 
from collections import OrderedDict
from dateutil import tz
from datetime import datetime
from loguru import logger
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap

boot_time = datetime.now(tz=tz.tzlocal())
boot_time_iso_str_cache = boot_time.isoformat()
class MyArchNameConst:
    X86_32BITS = "386"
    X86_64BITS = "amd64"
    ARM_32BITS = "arm"
    ARM_64BITS = "arm64"
    ARM_V6 = "armv6"
    ARM_V7 = "armv7"
    ARM_V8 = "arm64"
    MIPS_32BITS_BIG_ENDIAN = "mips"
    MIPS_32BITS_LITTLE_ENDIAN = "mipsle"
    MIPS_64BITS_BIG_ENDIAN = "mips64"
    MIPS_64BITS_LITTLE_ENDIAN = "mips64le"
    LOONG_64BITS = "loong64"
    POWERPC_64BITS_LITTLE_ENDIAN = "ppc64le"
    RISCV_32BITS = "riscv"
    RISCV_64BITS = "riscv64"

arch_name_map = {
    # x86 32-bit
    "i386": MyArchNameConst.X86_32BITS,
    "386": MyArchNameConst.X86_32BITS,
    "x86": MyArchNameConst.X86_32BITS,

    # x86 64-bit
    "amd64": MyArchNameConst.X86_64BITS,
    "x86_64": MyArchNameConst.X86_64BITS,

    # ARM
    "armv6": MyArchNameConst.ARM_V6,
    "armv6l": MyArchNameConst.ARM_V6,
    "armv7": MyArchNameConst.ARM_V7,
    "armv7l": MyArchNameConst.ARM_V7,
    "armv8": MyArchNameConst.ARM_V8,
    "arm": MyArchNameConst.ARM_32BITS,
    "arm64": MyArchNameConst.ARM_64BITS,
    "aarch64": MyArchNameConst.ARM_64BITS,

    # MIPS 32-bit Big Endian
    "mips": MyArchNameConst.MIPS_32BITS_BIG_ENDIAN,

    # MIPS 32-bit Little Endian
    "mipsel": MyArchNameConst.MIPS_32BITS_LITTLE_ENDIAN,
    "mipsle": MyArchNameConst.MIPS_32BITS_LITTLE_ENDIAN,

    # MIPS 64-bit Big Endian
    "mips64": MyArchNameConst.MIPS_64BITS_BIG_ENDIAN,

    # MIPS 64-bit Little Endian
    "mips64el": MyArchNameConst.MIPS_64BITS_LITTLE_ENDIAN,
    "mips64le": MyArchNameConst.MIPS_64BITS_LITTLE_ENDIAN,

    # LoongArch 64-bit
    "loongarch64": MyArchNameConst.LOONG_64BITS,
    "loong64": MyArchNameConst.LOONG_64BITS,

    # PowerPC
    "ppc": MyArchNameConst.POWERPC_64BITS_LITTLE_ENDIAN,
    "ppc64": MyArchNameConst.POWERPC_64BITS_LITTLE_ENDIAN,
    "ppc64le": MyArchNameConst.POWERPC_64BITS_LITTLE_ENDIAN,

    # RISC-V
    "riscv": MyArchNameConst.RISCV_32BITS,
    "riscv64": MyArchNameConst.RISCV_64BITS,
}

py_platform_machine = platform.machine()
current_env_arch_name = arch_name_map.get(py_platform_machine, "")

if current_env_arch_name == "":
    logger.error(f"CPU architect [{py_platform_machine}] is unsupported yet! Exit with failed...")
    exit(1)

origin_working_dir = os.getcwd()
root_path = "/mnt/justsave/docker/compose/standalone"

root_dir_items:list = os.listdir(root_path)
skipped_app_list = []
print(f"Found {len(root_dir_items)} item in path[{root_path}]")
print("Skip item:", skipped_app_list)

yaml4write = YAML()
yaml4write.indent(mapping=2, sequence=4, offset=2)
yaml4write.representer.add_representer(OrderedDict, lambda dumper, data: dumper.represent_dict(data))

user_yml_file_name = "docker-compose.override.yaml"


logger.info("All done.")
