"""
Author: Keith Robertson
Summary:
 Download a bunch of random packages from any registry and their associated
 versions into a temporary directory as specified by cachedir.
"""

import subprocess
import json
import argparse
import textwrap
import os


def get_versions(pkg):
    """
        Kwargs:
            package: The npm package to publish.
            registry: The registry to publish to.
    """
    cmd = "npm --json info %s" % (pkg)
    print "Start: %s" % (cmd)
    with open("stderr.txt", "wb") as err:
        proc = subprocess.Popen(
            cmd, stdout=subprocess.PIPE, stderr=err, shell=True)
    output = str(proc.communicate()[0]).strip()
    if proc.returncode != 0:
        print "ERROR: %s" % (cmd)
    else:
        metadata = json.loads(output)
        if metadata['versions']:
            return metadata['versions']
    return []


def get_package(pkg, versions, cachedir):
    """
        Kwargs:
            package: The npm package to fetch.
            registry: The registry to publish to.
    """
    for version in versions:
        cmd = "npm pack %s@%s" % \
            (pkg, version)
        print "Start: %s" % (cmd)
        try:
            with open("stdout.txt", "wb") as out, open("stderr.txt", "wb") as err:
                proc = subprocess.Popen(cmd, cwd=cachedir, stdout=out, stderr=err, shell=True)
            streamdata = proc.communicate()[0]
            if proc.returncode != 0:
                print "ERROR: Failed to %s" % (cmd)
            else:
                print "END: %s" % (cmd)
        except Exception as ex:
            print "ERROR: %s" % ex.message


if __name__ == '__main__':
    PARSER = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent('''\
        Given a newline separated file of NPM packages and a directory.  This program
        will download every version of the package and store it in the provided directory.
        '''))
    PARSER.add_argument('cachedir',
                        help='Directory containing all of the node modules in .tgz format \
                        you wish to publish.')
    PARSER.add_argument('packages',
                        help='A newline separated file of packages to download.')

    ARGS = PARSER.parse_args()
    try:
        if not os.path.exists(ARGS.cachedir):
            os.makedirs(ARGS.cachedir)
        if not os.path.exists(ARGS.packages):
            raise Exception("ERROR: %s does not exist" % (ARGS.packages))

        with open(ARGS.packages, 'r') as packages:
            for package in packages:
                package = str(package).strip()
                get_package(package, get_versions(package), os.path.abspath(ARGS.cachedir))
    except Exception as ex:
        print ex.message
        exit(1)
