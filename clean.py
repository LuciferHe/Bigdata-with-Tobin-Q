import os
from subprocess import call
import threading
def removeori(path):
    if not path.endswith('pdfReMining.txt') and os.path.isfile(path):
        print("remove txt file:", path)
        os.remove(path)

def mk(origindir):
    dir_list_1 = os.listdir(origindir)
    for dir in dir_list_1:
        dir_1 = origindir + dir + '/'
        if os.path.isdir(dir_1):
            dir_list_2 = os.listdir(dir_1)
            for code_dir in dir_list_2:
                codepath = dir_1 + code_dir
                if os.path.isfile(codepath):
                    removeori(codepath)

mk('D:/test/')
#清除非remining数据