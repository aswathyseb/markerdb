import plac, sys

from mdbrun import taxids

SUB_COMMANDS = {'taxids': taxids.run}

USAGE = f"""
   markerdb: create a taxa-specific DNA marker database \n

   markerdb taxids    : extract taxids for the taxalist
   
   Run each command for more help.
   """


def run():
    """Create a taxa-specific DNA marker database"""

    # Print usage when no parameters are passed.
    if len(sys.argv) == 1:
        print(USAGE)
        sys.exit(1)

    if len(sys.argv) < 2:
        print("Enter a subcommand")
        sys.exit(1)

    cmd = sys.argv[1]

    sys.argv.remove(cmd)

    # Raise an error is not a valid subcommand.
    if cmd not in SUB_COMMANDS:
        print(USAGE, file=sys.stderr)
        print(f"invalid command: {cmd}")
        sys.exit(-1)

    func = SUB_COMMANDS[cmd]
    plac.call(func)


if __name__ == '__main__':
    run()
