class FakeOut:
    '''用于重定向 sys.stdout'''
    def __init__(self):
        self.buffer = ''
        self.line = 0

    def write(self, words):
        self.buffer += words
        self.line += 1

    def read(self):
        return self.buffer

    def lineCount(self):
        return self.line

    def clean(self):
        self.buffer = ''
        self.line = 0
