import os

__version__ = 1


def extract_cmd_from_filename():
    stem, _ = os.path.splitext(os.path.basename(__file__))
    if stem.startswith("run_"):
        return stem.lstrip("run_")
    return ""


CMD = ""
os.chdir(os.path.abspath(os.path.dirname(__file__)))
cmd = CMD or extract_cmd_from_filename()
print(f"[Command] {cmd}")
os.system(cmd)
input("Press ENTER to continue ...")
