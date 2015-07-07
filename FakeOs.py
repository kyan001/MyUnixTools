# -*- coding: utf-8 -*-
class FakeOs:
    '''用于重定向 os.system'''
    def __init__(self):
        self.call_list = [] #(list)

    def system(self, cmd):
        self.call_list.append(cmd);
        return 0;

    def read(self):
        return self.call_list

    def readline(self):
        return self.call_list.pop();

    def clean(self):
        self.call_list = []
