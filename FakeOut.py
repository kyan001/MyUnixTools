# -*- coding: utf-8 -*-
class FakeOut:
    '''
    用于重定向 sys.stdout
    系统默认调用 sys.stdout.write()
    '''
    def __init__(self):
        self.list = [] #(list)
        self.buffer = ""

    def write(self, words):
        self.buffer += words
        if words == '\n': #print会自动单独write一个"\n"在末尾，此时讲打印内容放入list内。
            self.flush();

    def readline(self):
        return self.list.pop()

    def flush(self):
        self.list.append(self.buffer)

    def clean(self):
        self.list = [] #(list)
        self.buffer = ""
