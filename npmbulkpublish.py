"""
Author: Keith Robertson
Summary:
 Given a directory, this program will upload all of the NPM .tgz files to the
 registry in your $HOME/.npmrc.
"""

import argparse
import textwrap
import os
import subprocess


def find_packages(path):
    """
        Kwargs:
            path: Path containing node packages in .tgz format
        Returns:
            An array with the full path to each discovered .tgz
    """
    retval = []
    if not os.path.exists(path):
        raise Exception("Error: %s does not exist.", path)
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".tgz"):
                retval.append(os.path.join(root, file))
    return retval


def publish_package(pkg):
    """
        Kwargs:
            package: The npm package to publish.
            registry: The registry to publish to.
    """
    cmd = "npm publish --always-auth=true --verbose %s" % (pkg)
    print "Start: %s" % (cmd)

    with open("stdout.txt", "wb") as out, open("stderr.txt", "wb") as err:
        child = subprocess.Popen(cmd, stdout=out, stderr=err, shell=True)
    streamdata = child.communicate()[0]
    if child.returncode != 0:
        print "ERROR: Failed to publish %s" % (cmd)
    else:
        print "END: %s" % (cmd)


if __name__ == '__main__':
    PACKAGES = []
    PARSER = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description=textwrap.dedent('''\
        Given a directory and a registry, this program will resursively search the directory and
        upload all of the NPM .tgz upload them to the supplied registry. You need to make sure
        your $HOME/.npmrc contains credentials for the given registry.

        Example:
            npmbulkpublish ~/.npm/
            npmbulkpublish $env:APPDATA\\npm-cache
         '''))
    PARSER.add_argument('cachedir',
                        help='Directory containing all of the node modules in .tgz format \
                        you wish to publish.')

    ARGS = PARSER.parse_args()

    try:
        PACKAGES = find_packages(ARGS.cachedir)
    except Exception as ex:
        print ex.message
        exit(1)

    for package in PACKAGES:
        publish_package(package)
