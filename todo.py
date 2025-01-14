#!/usr/bin/env python3
import argparse
import os
import re
import random

TODO_FILE_PATH = os.path.expanduser("~/todo.txt")


def add_activity(args):
    entry_id = random.randint(1000, 9999)
    priority = args.priority
    description = args.description
    time_limit = args.time_limit
    categories = args.categories or []

    if not description:
        raise ValueError("Description (-d) is required")

    entry = f"{entry_id} ({priority}) {description} [{time_limit}]"
    if categories:
        entry += " " + " ".join(f"@{cat}" for cat in categories)

    with open(TODO_FILE_PATH, "a") as file:
        file.write(entry + "\n")

    print(entry)


def get_activity(args):
    categories = args.categories or []
    cat_pattern = "|".join(f"@{cat}" for cat in categories)

    with open(TODO_FILE_PATH, "r") as file:
        lines = file.readlines()

    if cat_pattern:
        filtered = [line for line in lines if re.search(cat_pattern, line)]
    else:
        filtered = lines

    if not filtered:
        print("No matching activities found.")
        return

    print(random.choice(filtered).strip())


def list_activities(args):
    categories = args.categories or []
    cat_pattern = "|".join(f"@{cat}" for cat in categories)

    with open(TODO_FILE_PATH, "r") as file:
        lines = file.readlines()

    if args.list_categories:
        all_cats = set()
        for line in lines:
            for cat in re.findall(r"@([a-zA-Z0-9]+)", line):
                all_cats.add(cat)
        for cat in all_cats:
            print(cat)
    else:
        if cat_pattern:
            filtered = [line for line in lines if re.search(cat_pattern, line)]
        else:
            filtered = lines
    
        for line in filtered:
            print(line.strip())


def main():
    parser = argparse.ArgumentParser(description="A simple tool to manage and pick activities or chores.")
    subparsers = parser.add_subparsers(dest="command", required=True)

    # Add activity command
    add_parser = subparsers.add_parser("add", help="Add a new activity.")
    add_parser.add_argument("-d", "--description", required=True, help="Description of the activity.")
    add_parser.add_argument("-p", "--priority", help="Priority (e.g., 'A', 'B'). Default is 'B'.", default="B")
    add_parser.add_argument("-t", "--time_limit", help="Time limit (e.g., '30min'). Default is '1h'.", default="1h")
    add_parser.add_argument("-c", "--categories", action="append", help="Category (can be specified multiple times).")

    # Get activity command
    get_parser = subparsers.add_parser("get", help="Pick a random activity.")
    get_parser.add_argument("-c", "--categories", action="append", help="Filter by category (can be specified multiple times).")

    # List activities command
    list_parser = subparsers.add_parser("list", help="List all activities.")
    list_parser.add_argument("-c", "--categories", action="append", help="Filter by category (can be specified multiple times).")
    list_parser.add_argument("-l", "--list_categories", action="store_true", help="Ignore other args and list all categories currently used in todo.txt file")

    args = parser.parse_args()

    # touch file to make sure it exists
    if not os.path.exists(TODO_FILE_PATH):
        open(TODO_FILE_PATH, "w").close()

    if args.command == "add":
        add_activity(args)
    elif args.command == "get":
        get_activity(args)
    elif args.command == "list":
        list_activities(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()

