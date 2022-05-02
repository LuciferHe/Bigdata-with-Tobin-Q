import re
import os
import shutil
# 整理年份，编号
def setDir(file_path):
    if not os.path.exists(file_path):
        os.mkdir(file_path)

def mk(origindir,newdir):
    dir_list_1 = os.listdir(origindir)
    i=0
    j=0
    for dir in dir_list_1:
        dir_1 = origindir + dir + '/'
        ndir = newdir + dir + '/'
        if os.path.isdir(dir_1):
            setDir(ndir)
            dir_list_2 = os.listdir(dir_1)
            for code_dir in dir_list_2:
                codepath = dir_1 + code_dir
                if "H股" in code_dir or   "公司债券" in code_dir or "更正版" in code_dir or "修订版" in code_dir or "持续督导" in code_dir or "英文版" in code_dir:
                    print("存在错误：{}\n".format(codepath))
                    j=j+1
                    continue
                temp = re.sub("\D", "", code_dir)
                npath = ndir + temp+'.txt'
                if len(temp) != 4:
                    print("异常文本{}文件夹下{}文件，异常值为{}\n".format(dir,code_dir,temp))
                    i=i+1
                    continue
                else:
                    if os.path.isfile(codepath):
                        shutil.copyfile(codepath, npath)
    print("共有{}个数值错误".format(i))
    print("共有{}个非年报数据".format(j))
mk('D:/test/','D:/final/')  #输入文件夹所在位置即可，参数一为股票代码文件夹所在文件夹，参数二而生成的txt所在文件夹



