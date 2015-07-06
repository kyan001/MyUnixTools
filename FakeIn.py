class FakeIn:
    '''用于重定向 sys.stdin'''
    def __init__(self):
        self.buffer = ""

    def readline(self):
        return self.buffer

    def write(self, words='\n'):
        self.buffer = words;
        # buffer[-1] must be '\n'
        if not self.buffer:
            self.buffer = "\n"
        else:
            if self.buffer[-1]!="\n":
                self.buffer = self.buffer + "\n"

    def clean(self):
        self.buffer = '\n'
