from pdfminer.pdfparser import PDFParser
from pdfminer.pdfdocument import PDFDocument
from pdfminer.pdfpage import PDFPage
from pdfminer.pdfpage import PDFTextExtractionNotAllowed
from pdfminer.pdfinterp import PDFResourceManager
from pdfminer.pdfinterp import PDFPageInterpreter
from pdfminer.pdfparser import PDFSyntaxError
from pdfminer.pdfdevice import PDFDevice
from pdfminer.layout import *
from pdfminer.converter import PDFPageAggregator
import os
from subprocess import call
import threading
import datetime
starttime = datetime.datetime.now()

def setDir(file_path):
    if not os.path.exists(file_path):
        os.mkdir(file_path)
def convert_to_txt(full_path,new_full_path):
    fp = open(full_path, 'rb')
    try:
        #来创建一个pdf文档分析器
        parser = PDFParser(fp)
        #创建一个PDF文档对象存储文档结构
        document = PDFDocument(parser)
        # 检查文件是否允许文本提取
        if not document.is_extractable:
            raise PDFTextExtractionNotAllowed
        else:
            # 创建一个PDF资源管理器对象来存储共赏资源
            rsrcmgr=PDFResourceManager()
            # 设定参数进行分析
            laparams=LAParams()
            # 创建一个PDF设备对象
            # device=PDFDevice(rsrcmgr)
            device=PDFPageAggregator(rsrcmgr,laparams=laparams)
            # 创建一个PDF解释器对象
            interpreter=PDFPageInterpreter(rsrcmgr,device)
            # 处理每一页
            new_txt_path = new_full_path + '.txt'
            if os.path.exists(new_txt_path) and os.path.isfile(new_txt_path):
                print("remove txt file:", new_txt_path)
                os.remove(new_txt_path)
            wf = open(new_txt_path, 'wb', buffering=4096)#改了w-wb
            print("正在转码"+full_path)
            for page in PDFPage.create_pages(document):
                interpreter.process_page(page)
                # 接受该页面的LTPage对象
                layout=device.get_result()
                for x in layout:
                    if(isinstance(x,LTTextBoxHorizontal)):
                        #print(x.get_text())
                        #with open(full_path + '.txt', 'a', buffering=64*1024) as f:
                        wf.write(x.get_text().encode('utf-8'))
            wf.close()
            fp.close()
    except :
        print("Error ================================================")
        f = open("error.txt", "a")
        f.write("存在错误{}\n".format(full_path))
        f.close()
        fp.close()
        pass

def process_txt(old_full_name, new_full_name):
    #global total_hit_line_cnt
    try:
        read_file = open(old_full_name, 'rb')
        wf = open(new_full_name, 'wb', buffering=4096)
        for line in read_file.readlines():
            #line = ori_line.strip()
            if  line == b" " or line == b" \n" or line == b""or line == b"\n" or line == b"  \n": #去除更多的空行
                continue
            elif line.endswith(b' \n'):    # 如果是空格+换行结尾，则原样保留
                wf.write(line)
            elif line.endswith(b'\n'):
                newline = line[:-1]     # 仅换行符结尾，需要去掉最后一个换行符
                wf.write(newline)
            else:
                print("unexpect line:" + line)
        read_file.close()
        wf.close()
    except :
        print("Error ================================================")
        f = open("error.txt", "a")
        f.write("refine存在错误{}\n".format(old_full_name))
        f.close()

def mk(origindir,newdir):
    dir_list_1 = os.listdir(origindir)
    total_num = len(dir_list_1)
    a_time = 0
    for dir in dir_list_1:
        dir_1 = origindir + dir + '/'
        ndir = newdir + dir + '/'
        if os.path.isdir(dir_1):
            setDir(ndir)
            dir_list_2 = os.listdir(dir_1)
            for code_dir in dir_list_2:
                codepath = dir_1 + code_dir
                npath = ndir + code_dir
                if os.path.isfile(codepath):
                    convert_to_txt(codepath,npath)
                    process_txt(npath+'.txt',npath+'ReMining'+'.txt')
        endtime = datetime.datetime.now()
        a_time = a_time + 1

        time_predict = (endtime - starttime) / a_time * total_num
        remaining_time = time_predict - (endtime - starttime)

        print('----------------------------------------------------------------------------------')
        print('公司总数: %s, 现在轮到: %s, 预计总需要时间: %s' % (total_num, a_time, time_predict))
        print('已用时: %s, 预计剩余时间: %s' % (endtime - starttime, remaining_time))
        print('program已经运行了:', endtime - starttime)
        print('----------------------------------------------------------------------------------')

#convert_to_txt('E:/财报/000001/000001-平安银行-2001年年度报告.pdf')
#process_txt('E:/财报/000001/000001-平安银行-2001年年度报告.pdf.txt','E:/财报/000001/000001.txt')
mk('G:/1/','G:/财报txt/')  #输入文件夹所在位置即可，参数一为股票代码文件夹所在文件夹，参数二而生成的txt所在文件夹