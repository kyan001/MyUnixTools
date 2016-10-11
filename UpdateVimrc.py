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
def copy_my_file(template, to_):
    # deal from
    if not os.path.isabs(template):
        current_dir = os.path.dirname(os.path.realpath(__file__))
        from_ = os.path.join(current_dir, template)
    else:
        from_ = template
    cit.info('From\t: {}'.format(from_))
    if not os.path.isfile(from_):
        cit.err("my.file does not exists, copy cancelled", lvl=1)
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


def main():
    new_file = generate_filepath('.vimrc')
    copy_my_file('my.vimrc', new_file)

if __name__ == '__main__':
    main()
