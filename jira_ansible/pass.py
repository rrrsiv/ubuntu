#password  JdLuiTKxHHUlJvc35yDfm51AKknNBeu2hfPXV8

import os

mypass = os.environ.get("password")

if mypass:
    print(f"Value of password: {mypass}")
else:
    print("Password is not set.")