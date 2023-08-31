import plac, sys, os

from mdbrun import taxids, table, db

SUB_COMMANDS = {'taxids': taxids.run, 'table': table.run, 'db': db.run}

USAGE = f"""
   markerdb: create a taxa-specific DNA marker database \n

   markerdb taxids    : extract taxids for the taxalist
   markerdb table     : convert blast databases to table
   markerdb db        : create an sqlite3 database
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
