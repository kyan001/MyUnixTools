import unittest
import KyanToolKit_Py
import FakeOut, FakeIn
import sys, os

class testKyanToolKitPy(unittest.TestCase):
    def setUp(self):
        self.ktk = KyanToolKit_Py.KyanToolKit_Py()
        self.txt = "Test Text"
        # redirect stdout
        self.console_out = sys.stdout
        self.fakeout = FakeOut.FakeOut()
        sys.stdout = self.fakeout
        # redirect stdin
        self.console_in = sys.stdin
        self.fakein = FakeIn.FakeIn()
        sys.stdin = self.fakein
        # monkey patch

    def tearDown(self):
        # clean fakin/out buffer
        self.fakeout.clean()
        self.fakein.clean()
        # set back stdin/out to console
        sys.stdout = self.console_out
        sys.stdin = self.console_in

    def testBanner(self):
        expect_word = '###############\n#  Test Text  #\n###############'
        self.assertEqual(expect_word, self.ktk.banner(self.txt))

    def testInfo(self):
        self.ktk.info(self.txt)
        self.assertEqual(self.fakeout.readline(), "[INFO] Test Text\n")

    def testWarn(self):
        self.ktk.warn(self.txt)
        self.assertEqual(self.fakeout.readline(), "[WARNING] Test Text\n")

    def testErr(self):
        self.ktk.err(self.txt)
        self.assertEqual(self.fakeout.readline(), "[ERROR] Test Text\n")

    def testClearScreen(self):
        result = self.ktk.clearScreen()
        self.assertTrue(result)

    def testPressToContinue(self):
        self.fakein.write();
        self.ktk.pressToContinue()
        self.assertEqual(self.fakeout.readline(), "\nPress Enter to Continue...\n")

    def testPressToContinue2(self):
        self.fakein.write();
        self.ktk.pressToContinue("Test Custom Text:")
        self.assertEqual(self.fakeout.readline(), "Test Custom Text:")

if __name__ == '__main__':
    unittest.main(verbosity=2, exit=False)
    KyanToolKit_Py.KyanToolKit_Py().pressToContinue()
