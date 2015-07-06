class FakeOut:
    '''用于重定向 sys.stdout'''
    def __init__(self):
        self.buffer = [] #list

    def write(self, words):
        import sys
        sys.stderr.write(words.replace("\n",r'\n'))
        self.buffer.append(words)

    def read(self):
        return self.buffer

    def readline(self):
        return self.buffer.pop()

    def clean(self):
        self.buffer = [] #list
