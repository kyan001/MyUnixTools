# -*- coding: utf-8 -*-
import unittest
import KyanToolKit_Py
import FakeOut, FakeIn, FakeOs
import sys, os
import threading, time

class test_KyanToolKitPy(unittest.TestCase):
    '''
    用于测试 KyanToolKit_Py
    '''
    def setUp(self):
        self.ktk = KyanToolKit_Py.KyanToolKit_Py()
        # redirect stdout
        self.console_out = sys.stdout
        self.fakeout = FakeOut.FakeOut()
        sys.stdout = self.fakeout
        # redirect stdin
        self.console_in = sys.stdin
        self.fakein = FakeIn.FakeIn()
        sys.stdin = self.fakein
        # monkey patch
        self.os_system = os.system
        self.fakeos = FakeOs.FakeOs()
        os.system = self.fakeos.system

    def tearDown(self):
        # clean fakin/out buffer
        self.fakeout.clean()
        self.fakein.clean()
        self.fakeos.clean()
        # set back stdin/out to console
        sys.stdout = self.console_out
        sys.stdin = self.console_in
        os.system = self.os_system

    def test_init(self):
        'testing __init__()'
        self.assertTrue(self.ktk.trace_file)
        self.assertIsNotNone(self.ktk.q.get('stdout'))
        self.assertIsNotNone(self.ktk.mutex.get('stdout'))

    def test_banner(self):
        expect_word = '###############\n#  Test Text  #\n###############'
        self.assertEqual(expect_word, self.ktk.banner("Test Text"))

    def test_info(self):
        self.ktk.info("Test Text")
        self.assertEqual(self.fakeout.readline(), "[INFO] Test Text\n")

    def test_warn(self):
        self.ktk.warn("Test Text")
        self.assertEqual(self.fakeout.readline(), "[WARNING] Test Text\n")

    def test_err(self):
        self.ktk.err("Test Text")
        self.assertEqual(self.fakeout.readline(), "[ERROR] Test Text\n")

    def test_clearScreen(self):
        self.ktk.clearScreen()
        self.assertEqual(self.fakeos.readline(), "cls");

    def test_pressToContinue_1(self):
        self.fakein.write();
        self.ktk.pressToContinue()
        self.assertEqual(self.fakeout.readline(), "\nPress Enter to Continue...\n")

    def test_pressToContinue_2(self):
        self.fakein.write();
        self.ktk.pressToContinue("Test Custom Text:")
        self.assertEqual(self.fakeout.readline(), "Test Custom Text:")

    def test_bye(self):
        self.assertRaises(SystemExit, self.ktk.bye, None)
        #self.assertEqual(self.fakeout.readline(), "See you later")

    def test_breakCommands(self):
        real_word = self.ktk.breakCommands("Test Text -param 1 -param2")
        expect_word = '##########################.\n# Test Text\n# \t-param 1\n# \t-param2\n##########################.'
        self.assertEqual(real_word, expect_word)

    def test_checkResult_1(self):
        self.ktk.checkResult(0)
        self.assertEqual(self.fakeout.readline(), "[INFO] Done\n\n")

    def test_checkResult_2(self):
        self.ktk.checkResult(1)
        self.assertEqual(self.fakeout.readline(), "[WARNING] Failed\n\n")

    def test_runCmd(self):
        self.ktk.runCmd("echo x")
        self.assertEqual(self.fakeout.readline(), "##########\n# echo x #\n##########\n[INFO] Done\n\n")
        self.assertEqual(self.fakeos.readline(), "echo x")

    def test_getUser(self):
        self.assertEqual(self.ktk.getUser(), os.getlogin())

    def test_readCmd(self):
        self.assertEqual(self.ktk.readCmd(r"echo Test Text"), "Test Text\n")

    def test_getInput(self):
        self.fakein.write("Test Input")
        self.assertEqual(self.ktk.getInput(), "Test Input")
        self.assertEqual(self.fakeout.readline(), "> ")

    def test_getChoice_1(self):
        self.fakein.write("1");
        self.assertEqual(self.ktk.getChoice(["Test", "Text"]), "Test")
        self.assertEqual(self.fakeout.readline(), "\n1 - Test\n2 - Text\n> ")

    def test_getChoice_2(self):
        self.fakein.write("Text");
        self.assertEqual(self.ktk.getChoice(["Test", "Text"]), "Text")
        self.assertEqual(self.fakeout.readline(), "\n1 - Test\n2 - Text\n> ")

    def test_needPlatform(self):
        self.ktk.needPlatform(sys.platform)
        self.assertEqual(self.fakeout.readline(), "[INFO] Platform Require: " + sys.platform + ", Current: " + sys.platform + "\n[INFO] Done\n\n");

    def test_asyncPrint_simple(self):
        self.ktk.asyncPrint("Test Text");
        self.assertEqual(self.fakeout.readline(), "Test Text\n")
        self.assertFalse(self.ktk.mutex.get('stdout').locked())

    def test_asyncPrint_full(self):
        mutex = self.ktk.mutex.get('stdout');
        asyncPrint_called = threading.Event()
        def lockMutex():
            if mutex.acquire(): #上锁
                asyncPrint_called.wait() # wait until asyncPrint called
                self.assertIsNone(self.fakeout.readline())
                mutex.release() #放锁
        t = threading.Thread(target=lockMutex)
        t.start() # mutex locked
        self.ktk.asyncPrint("Test Text")
        asyncPrint_called.set()
        t.join() # wait mutex released
        self.assertEqual(self.fakeout.readline(), "Test Text\n")
        self.assertFalse(self.ktk.mutex.get('stdout').locked())

    def test_TRACE(self):
        f = self.ktk.trace_file
        self.assertFalse(os.path.exists(f))
        self.ktk.TRACE("Test Text")
        self.assertTrue(os.path.exists(f))
        os.remove(f)

if __name__ == '__main__':
    KyanToolKit_Py.KyanToolKit_Py().clearScreen()
    unittest.main(verbosity=2, exit=False) #更多屏显信息，最后不调用sys.exit()
    KyanToolKit_Py.KyanToolKit_Py().pressToContinue()
