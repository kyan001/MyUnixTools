# -*- coding: utf-8 -*-
class FakeIn:
    '''
    用于重定向 sys.stdin
    系统默认调用 sys.stdin.readline()[:-1]
    '''
    def __init__(self):
        self.list = [] #(list)

    def readline(self):
        return self.list.pop()

    def write(self, words='\n'):
        # list[-1] must be '\n'
        if words and words[-1]=='\n':
            pass
        else: #调用write("")时，或参数最后一位不是\n时
            words += '\n'
        self.list.append(words)

    def clean(self):
        self.list = '\n'
