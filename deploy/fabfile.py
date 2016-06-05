from fabric.api import run
from fabric.api import local
from fabric.api import env
from fabric.api import roles
import os
from fabric.context_managers import cd
from fabric.context_managers import lcd
import cuisine


env.shell = "/bin/sh -c"

host_names = {}


def set_hosts():
    from ConfigParser import SafeConfigParser
    parser = SafeConfigParser()
    parser.read('hosts')
    env.roledefs["robots"] = []
    for section in parser.sections():
        env.roledefs[section] = []
        for host_name, ip in parser.items(section):
            env.roledefs[section].append(ip)
            env.roledefs["robots"].append(ip)
            host_names[ip] = host_name.upper()


set_hosts()


@roles("robots")
def host_type():
    run('uname -s')


@roles("robots")
def set_host_name():
    local(
        "echo " + host_names[env.host_string] +
        " | ssh {user}@{remote} 'cat - > /etc/hostname'".format(
            user=env.user, remote=env.host_string))


@roles("robots")
def check_host_name():
    run('cat /etc/hostname')


@roles("robots")
def push(force=False):
    folder = os.getcwd()
    os.chdir("remote")
    for sub in os.listdir(os.path.curdir):
        for root, dirs, files in os.walk(sub, topdown=False):
            for name in dirs:
                print "copy folder:", (os.path.join(root, name))
                cuisine.dir_ensure(os.path.join(os.path.sep, root, name))
            for name in files:
                path = os.path.join(root, name)
                local_path = os.path.abspath(path)
                path = os.path.join(os.path.sep, path)
                if (force or (not cuisine.file_exists(path))):
                    print "copy file - local_path = {} ; path = {}".format(
                            local_path, path)
                    local("scp {local} {user}@{host}:{remote}".format(
                        remote=path,
                        local=local_path,
                        user=env.user,
                        host=env.host_string))
    os.chdir(folder)
