import os
import shutil
import subprocess
import sys


def replace_channel_type(file_path, channel_id):
    target_prefix = '    channelType: ChannelType.'
    replaced = False

    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    new_lines = []
    for line in lines:
        if target_prefix in line:
            new_lines.append(f'{target_prefix}{channel_id},\n')
            replaced = True
            continue
        new_lines.append(line)

    if not replaced:
        raise ValueError(f'未在 {file_path} 中找到渠道配置行')

    with open(file_path, 'w', encoding='utf-8') as file:
        file.writelines(new_lines)


def get_target_platforms(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        lines = file.readlines()

    target_platforms = []
    for line in lines:
        if not line.strip():
            continue
        parts = line.strip().split(',')
        if len(parts) < 4:
            raise ValueError(f'渠道配置格式错误: {line.strip()}')
        platform = {
            'name': parts[0],
            'id': parts[1],
            'channel': parts[2],
            'number': parts[3],
        }
        target_platforms.append(platform)
    return target_platforms


def run_build(command, workspace_path):
    result = subprocess.run(command, shell=True, cwd=workspace_path)
    if result.returncode != 0:
        raise RuntimeError(f'执行构建命令失败: {command}')


def move_build_output(build_path, build_output_file):
    if not os.path.exists(build_path):
        raise FileNotFoundError(f'未找到构建产物: {build_path}')
    os.makedirs(os.path.dirname(build_output_file), exist_ok=True)
    if os.path.exists(build_output_file):
        os.remove(build_output_file)
    shutil.move(build_path, build_output_file)


def change_platform(args=''):
    workspace_path = os.getcwd()
    print(f"当前工作目录: {workspace_path}")
    platform_path = f'{workspace_path}/script/source.txt'
    target_platforms = get_target_platforms(platform_path)

    package_output_path = f'{workspace_path}/script/output/one'
    if args == '--all':
        package_output_path = f'{workspace_path}/script/output/all'
    elif args == '--ios':
        package_output_path = f'{workspace_path}/script/output/ios'

    os.makedirs(package_output_path, exist_ok=True)

    file_path = f'{workspace_path}/lib/main.dart'
    with open(file_path, 'r', encoding='utf-8') as file:
        original_main_dart = file.read()

    try:
        for platform in target_platforms:
            channel_id = platform['id']
            platform_name = platform['number']
            build_path = f'{workspace_path}/build/app/outputs/flutter-apk/app-release.apk'
            build_script = 'flutter build apk --release --target-platform android-arm64'
            build_output_file = f'{package_output_path}/shanmengai-{platform_name}-15.0.5.apk'

            if channel_id == 'iosAppStore' or args == '--ios':
                channel_id = 'iosAppStore'
                platform_name = 'ios'
                build_script = 'flutter build ipa'
                build_path = f'{workspace_path}/build/ios/app-release.ipa'
                build_output_file = f'{package_output_path}/{platform_name}.ipa'

            replace_channel_type(file_path, channel_id)
            print(f"正在构建：{platform_name} 渠道包")
            run_build(build_script, workspace_path)
            move_build_output(build_path, build_output_file)
            print(f"构建：{platform_name} 渠道包成功")

            if args != '--all':
                break
    finally:
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(original_main_dart)


def main():
    args = sys.argv[1:]
    if not args:
        change_platform()
        return

    for arg in args:
        if arg == '--all':
            change_platform(arg)
        elif arg == '--ios':
            change_platform(arg)
        else:
            print("参数错误 支持 --all 或 --ios")


if __name__ == "__main__":
    main()