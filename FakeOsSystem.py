class FakeOs:
    '''用于重定向 os.system'''
    def __init__(self):
        self.call_list = list()

    def system(self, cmd):
        sys.stderr.write("[CALL] os.system(" + cmd + ")")
        self.call_list.append(cmd);

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
