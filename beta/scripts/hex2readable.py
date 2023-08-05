import sys
from textwrap import wrap


def convert2(i):
    i = i[::-1]
    return i


def convert(s):
    s = s[::-1]
    s = wrap(s, 2)
    s = map(convert2, s)
    s = ''.join(s)
    return s


data = sys.stdin.read()
data = ''.join(data.split())
data = wrap(data, 8)
data = map(convert, data)
data = '\n'.join(data)
print(data)
