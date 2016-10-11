#!/usr/bin/python3
import os
import shutil
import getpass
import consoleiotools as cit


@cit.as_session('Generate Filepath')
def generate_filepath(filename):
    home_dir = os.path.expanduser('~')
    cit.info("Home Dir\t: {}".format(home_dir))
    if not os.path.isdir(home_dir):
        cit.warn('Home Dir does not exist, creating it', lvl=1)
        os.makedirs(home_dir)
    new_file = os.path.join(home_dir, filename)
    cit.info("Target File\t: {}".format(new_file))
    if os.path.exists(new_file):
        backup = '{}.old'.format(new_file)
        os.rename(new_file, backup)
        cit.warn("Target file is already exist.", lvl=1)
        cit.warn('Old target file renamed as {}'.format(backup), lvl=1)
    return new_file


@cit.as_session('Copying my file')
def copy_my_file(config_name, to_):
    # deal from
    if not os.path.isabs(config_name):
        current_dir = os.path.dirname(os.path.realpath(__file__))
        from_ = os.path.join(current_dir, config_name)
    else:
        from_ = config_name
    cit.info('From\t: {}'.format(from_))
    if not os.path.isfile(from_):
        cit.err("config file does not exists, copy cancelled", lvl=1)
        cit.bye()
    # deal to
    cit.info('To\t: {}'.format(to_))
    if os.path.isfile(to_):
        cit.err('target file exists, copy cancelled', lvl=1)
        cit.bye()
    cit.info('Copying file ...')
    shutil.copyfile(from_, to_)
    cit.info('Changing file owner ...')
    current_user = getpass.getuser()
    shutil.chown(to_, user=current_user)


@cit.as_session('Menu')
def menu():
    confs = ['.vimrc', '.tcshrc', '.aliases', '.promptrc']
    cit.ask('Which config file to update:')
    choice = cit.get_choice(['ALL'] + confs + ['exit'])
    if choice == 'ALL':
        for conf in confs:
            config(conf)
        cit.info('Done')
        cit.pause('Press Enter to exit ...')
        cit.bye()
    elif choice == 'exit':
        cit.bye()
    else:
        return choice


@cit.as_session('Configing')
def config(name):
    new_file = generate_filepath(name)
    copy_my_file('config' + name, new_file)


def main():
    while True:
        conf = menu()
        config(conf)

if __name__ == '__main__':
    main()
