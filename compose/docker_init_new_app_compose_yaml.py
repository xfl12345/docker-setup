#!/usr/bin/env python3
import os
import sys
import copy
import shutil
from collections import OrderedDict
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap

root_path = os.path.abspath(os.path.curdir)
# print(root_path)
# exit(0)
# root_path = "/media/justsave/docker/compose/standalone/ttt"
print(f"当前目录：[{root_path}]")

curr_app_dir = root_path
curr_app_dir_name = os.path.basename(os.path.normpath(curr_app_dir))
curr_app_file = os.path.join(curr_app_dir, "docker-compose.yml")
curr_app_example_file = os.path.join(curr_app_dir, "docker-compose.example.yml")
curr_app_morefree_example_file = os.path.join(curr_app_dir, "docker-compose.morefree.example.yml")
curr_app_network_file = os.path.join(curr_app_dir, "docker-compose.network.yml")
curr_app_env_file = os.path.join(curr_app_dir, "default.env")

# print(curr_app_file)
# print(curr_app_example_file)
# print(curr_app_morefree_example_file)
# print(curr_app_env_file)

# def create_file_if_not_exist(file_path):
#     # 检查文件是否存在
#     if not os.path.exists(file_path):
#         # 如果文件不存在，创建一个新文件
#         with open(file_path, 'w') as file:
#             pass  # 不写入任何内容，只是创建文件
#         print(f"File [{file_path}] create successfully.")
#     else:
#         print(f"File [{file_path}] found.")

app_example_content = OrderedDict({
    "services": {
        curr_app_dir_name: {
            "extends": {
                "file": "./docker-compose.morefree.example.yml"
            }
        }
    }
})
app_example_content["services"][curr_app_dir_name]["extends"]["service"] = curr_app_dir_name

app_morefree_example_content_header = "# official repo URL=\n# official docs URL=\n"
app_morefree_example_content = OrderedDict({
    "services": {
        curr_app_dir_name: {
            "env_file": [
                {
                    "path": "/media/justsave/docker/compose/global_default.env",
                    "required": True
                }, {
                    "path": "./default.env",
                    "required": True
                },{
                    "path": f"/media/justsave/docker/env/{curr_app_dir_name}/docker.env",
                    "required": False
                }
            ]
        }
    }
})
tmp_var = app_morefree_example_content["services"][curr_app_dir_name]["env_file"];
tmp_var[1] = CommentedMap(tmp_var[1])
tmp_var[1].yaml_add_eol_comment("default", key="required", column=1)

app_env_content = ""
app_network_content = None

if os.path.exists(curr_app_file):
    with open(curr_app_file, "r") as f:
        if f.readline().startswith("#"):
            f.seek(0)
            app_morefree_example_content_header = ""
            for i in range(5):
                offset_backup = f.tell()
                tmp_var = f.readline()
                if tmp_var.startswith("#") or tmp_var.startswith("\n"):
                    app_morefree_example_content_header += tmp_var
                else:
                    f.seek(offset_backup)
                    break
        yaml = YAML()
        data_root = yaml.load(f)
        # print(ttt._yaml_comment.comment[1])
        # yaml.dump(data_root, stream=sys.stdout)
        if "services" in data_root:
            if len(data_root["services"].items()) > 0 and curr_app_dir_name not in data_root["services"]:
                del app_example_content["services"][curr_app_dir_name]
                del app_morefree_example_content["services"][curr_app_dir_name]

            # 处理 services 字段
            for curr_service_name in data_root["services"]:
                service_setting = data_root["services"][curr_service_name]
                # 处理环境变量
                if "environment" in service_setting:
                    if isinstance(service_setting["environment"], list):
                        for item in service_setting["environment"]:
                            app_env_content += item + '\n'
                    elif isinstance(service_setting["environment"], dict):
                        for k, v in service_setting["environment"].items():
                            app_env_content += k + '=' + v + '\n'

                # 处理 service 子字段
                def just_copy_item(key: str, src, dest):
                    if key in src:
                        dest[key] = src[key]
                if curr_service_name not in app_morefree_example_content["services"]:
                    app_morefree_example_content["services"][curr_service_name] = OrderedDict()
                app_service_setting = app_morefree_example_content["services"][curr_service_name]
                just_copy_item("labels", service_setting, app_service_setting)
                just_copy_item("container_name", service_setting, app_service_setting)
                just_copy_item("image", service_setting, app_service_setting)
                just_copy_item("pull_policy", service_setting, app_service_setting)
                just_copy_item("build", service_setting, app_service_setting)
                just_copy_item("depends_on", service_setting, app_service_setting)
                just_copy_item("volumes", service_setting, app_service_setting)
                just_copy_item("extra_hosts", service_setting, app_service_setting)
                just_copy_item("restart", service_setting, app_service_setting)

                if curr_service_name not in app_example_content["services"]:
                    app_example_content["services"][curr_service_name] = OrderedDict()
                app_service_setting = app_example_content["services"][curr_service_name]
                app_service_setting["extends"] = OrderedDict({
                    "file": "./docker-compose.morefree.example.yml"
                })
                app_service_setting["extends"]["service"] = curr_service_name
                just_copy_item("network_mode", service_setting, app_service_setting)
                just_copy_item("networks", service_setting, app_service_setting)
                just_copy_item("ports", service_setting, app_service_setting)

            # 处理 networks 字段
            if "networks" in data_root:
                app_network_content = {
                    "networks": data_root["networks"]
                }
                app_example_content["include"] = ["./docker-compose.network.yml"]

yaml = YAML()
yaml.indent(mapping=2, sequence=4, offset=2)
# yaml.representer.add_representer(OrderedDict, lambda dumper, data: dumper.represent_dict(data.items()))
# yaml.representer.add_representer(OrderedDict, lambda dumper, data: dumper.represent_mapping('tag:yaml.org,2002:map', data))
yaml.representer.add_representer(OrderedDict, lambda dumper, data: dumper.represent_dict(data))
# yaml.dump(app_example_content, sys.stdout)
# yaml.dump(app_morefree_example_content, sys.stdout)
# app_network_content is not None and yaml.dump(app_morefree_example_content, sys.stdout)
# yaml.dump(app_env_content, sys.stdout)
# exit(0)

# debug_flag=True
debug_flag=False

if debug_flag or not os.path.exists(curr_app_example_file):
    with open(curr_app_example_file, "w") as f:
        yaml.dump(app_example_content, f)

if debug_flag or not os.path.exists(curr_app_morefree_example_file):
    with open(curr_app_morefree_example_file, "w") as f:
        f.writelines(app_morefree_example_content_header)
        yaml.dump(app_morefree_example_content, f)

if app_network_content is not None and (debug_flag or not os.path.exists(curr_app_network_file)):
    with open(curr_app_network_file, "w") as f:
        yaml.dump(app_network_content, f)

if debug_flag or not os.path.exists(curr_app_env_file):
    with open(curr_app_env_file, "w") as f:
        f.writelines(app_env_content)
