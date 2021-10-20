import sys

# help touchdesigner find package
mypath = "/usr/local/lib/python3.9/site-packages/"
if mypath not in sys.path:
    sys.path.append(mypath)

try:
    from freenect import sync_get_depth as get_depth
except:
    printf('error')