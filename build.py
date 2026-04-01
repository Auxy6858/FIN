import subprocess

output = subprocess.run("dub build", shell=True)

print(output)

# The day FIN itself can replace this file will be a happy day for me!