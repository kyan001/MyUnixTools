#!/usr/bin/env python3
import os
import shutil
import getpass
import consoleiotools as cit
import consolecmdtools as cct


@cit.as_session
def generate_filepath(filename):
    home_dir = os.path.expanduser('~')
    cit.info("  Home Dir: {}".format(home_dir))
    if not os.path.isdir(home_dir):
        cit.warn('Home Dir does not exist, creating it')
        os.makedirs(home_dir)
    new_path = os.path.join(home_dir, filename)
    cit.info("Target File: {}".format(new_path))
    return new_path


@cit.as_session
def copy(from_path: str, to_path: str) -> bool:
    # check source file
    if not os.path.isabs(from_path):
        current_dir = cct.get_dir(__file__)
        from_path = os.path.join(current_dir, from_path)
    cit.info('From: {}'.format(from_path))
    if not os.path.isfile(from_path):
        cit.err("config file does not exists, copy cancelled")
        return False
    # check destination file
    cit.info('  To: {}'.format(to_path))
    if os.path.isfile(to_path):
        cit.err('target file exists, copy cancelled')
        return False
    cit.info('Copying file ...')
    shutil.copyfile(from_path, to_path)
    cit.info('Changing file owner ...')
    current_user = getpass.getuser()
    shutil.chown(to_path, user=current_user)
    return True


def get_conf_names(dir: str = None) -> list:
    all_files = os.listdir(dir or cct.get_dir(__file__))
    return [filename for filename in all_files if filename.startswith('config.')]


@cit.as_session
def show_menu(filenames):
    confs = [filename.replace("config", "") for filename in filenames]
    cit.ask('Which config file to update:')
    return cit.get_choices(sorted(confs), exitable=True, allable=True)


@cit.as_session
def apply_config(config_name):
    current_dir = os.path.dirname(os.path.realpath(__file__))
    new_conf = os.path.join(current_dir, "config" + config_name)
    target_conf = generate_filepath(config_name)
    if os.path.exists(target_conf):
        cit.warn("Target file is already exist.")
        diffs = cct.diff(target_conf, new_conf)
        if not diffs:
            cit.warn("Files are same, stop configing.")
            return True
        cit.warn("Diffs found:\n" + "\n".join(diffs))
        backup = '{}.old'.format(target_conf)
        os.rename(target_conf, backup)
        cit.warn("Old config file renamed as {}".format(backup))
    return copy(new_conf, target_conf)


def main():
    conf_names = get_conf_names()
    for conf in show_menu(conf_names):
        apply_config(conf)


if __name__ == '__main__':
    main()
