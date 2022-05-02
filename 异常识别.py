import re
import os

def mk(origindir):
    dir_list_1 = os.listdir(origindir)
    i = 0
    j = 0
    for dir in dir_list_1:
        dir_1 = origindir + dir + '/'
        if os.path.isdir(dir_1):
            dir_list_2 = os.listdir(dir_1)
            for code_dir in dir_list_2:
                codepath = dir_1 + code_dir
                if "H股" in codepath or   "公司债券" in codepath or "更正版" in codepath or "修订版" in codepath or "持续督导" in codepath:
                    print("存在错误：{}\n".format(codepath))
                    j=j+1
                    continue
                temp = re.sub("\D", "", code_dir)
                if len(temp) != 4:
                    print("异常文本{}文件夹下{}文件，异常值为{}\n".format(dir,code_dir,temp))
                    f = open("异常文本.txt", "a")
                    f.write("异常文本{}文件夹下{}文件，异常值为{}\n".format(dir,code_dir,temp))
                    f.close()
                    i=i+1
                    continue
    print("共有{}个数值错误".format(i))
    print("共有{}个非年报数据".format(j))
mk('D:/600058-600873/')  #输入文件夹所在位置即可，参数一为股票代码文件夹所在文件夹，参数二而生成的txt所在文件夹



