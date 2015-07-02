import unittest
import KyanToolKit_Py
import FakeOut
import sys

class testKyanToolKitPy(unittest.TestCase):
    def setUp(self):
        self.ktk = KyanToolKit_Py.KyanToolKit_Py();
        self.txt = "Test Text"
        self.console = sys.stdout;
        self.fakeout = FakeOut.FakeOut();
        sys.stdout = self.fakeout

    def tearDown(self):
        self.fakeout.clean();
        sys.stdout = self.console

    def testBanner(self):
        expect_word = '###############\n#  Test Text  #\n###############';
        self.assertEqual(expect_word, self.ktk.banner(self.txt));

    def testInfo(self):
        self.ktk.info(self.txt)
        self.assertEqual(self.fakeout.read(), "[INFO] Test Text\n");

    def testWarn(self):
        self.ktk.warn(self.txt)
        self.assertEqual(self.fakeout.read(), "[WARNING] Test Text\n");

    def testErr(self):
        self.ktk.err(self.txt)
        self.assertEqual(self.fakeout.read(), "[ERROR] Test Text\n");


if __name__ == '__main__':
    unittest.main(verbosity=2, exit=False)
    KyanToolKit_Py.KyanToolKit_Py().pressToContinue();
