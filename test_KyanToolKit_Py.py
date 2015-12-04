# -*- coding: utf-8 -*-
##################################################################
# For KTK Version 3.2
##################################################################
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

    def test_md5_string(self):
        md5 = self.ktk.md5("Test Text")
        self.assertEqual(md5, 'f1feeaa3d698685b6a6179520449e206')

    def test_md5_int(self):
        md5 = self.ktk.md5(123)
        self.assertEqual(md5, '202cb962ac59075b964b07152d234b70')

    def test_md5_bytes(self):
        md5 = self.ktk.md5(b'Test Text')
        self.assertEqual(md5, 'f1feeaa3d698685b6a6179520449e206')

    def test_imageToColor(self):
        test_url = "http://portal.superfarmer.net/static/img/index/div3_products.png"
        color = self.ktk.imageToColor(test_url)
        self.assertEqual(color, (5, 147, 208))

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

    def test_checkResult_1(self):
        self.ktk.checkResult(0)
        self.assertEqual(self.fakeout.readline(), "[INFO] Done\n")

    def test_checkResult_2(self):
        self.ktk.checkResult(1)
        self.assertEqual(self.fakeout.readline(), "[WARNING] Failed\n")

    def test_runCmd(self):
        self.ktk.runCmd("echo x")
        expect_word = '[INFO] CMD: echo x\n'
        expect_word += '[INFO] Done\n'
        expect_word = "\n" + self.ktk.banner("Run Command") + "\n" + expect_word
        expect_word += "============ Run Command : end   ============\n\n"
        self.assertEqual(self.fakeout.readline(), expect_word)
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
        ''' by enter a index number '''
        self.fakein.write("1");
        self.assertEqual(self.ktk.getChoice(["Txt 1", "Txt 2"]), "Txt 1")
        self.assertEqual(self.fakeout.readline(), "\n1 - Txt 1\n2 - Txt 2\n> ")

    def test_getChoice_2(self):
        ''' by enter the text '''
        self.fakein.write("Txt 2");
        self.assertEqual(self.ktk.getChoice(["Txt 1", "Txt 2"]), "Txt 2")
        self.assertEqual(self.fakeout.readline(), "\n1 - Txt 1\n2 - Txt 2\n> ")

    def test_ajax_get(self):
        url = 'https://api.douban.com/v2/movie/search'
        param = {'q':'胜者即是正义', 'count':1}
        result = self.ktk.ajax(url, param, 'get')
        cast = result.get('subjects')[0].get('casts')[1].get('name')
        self.assertEqual(cast, '新垣结衣')

    def test_needPlatform(self):
        self.ktk.needPlatform(sys.platform)
        expect_word = "[INFO] Platform Require: {0}\n".format(sys.platform)
        expect_word += "[INFO] Current: {0}\n".format(sys.platform)
        expect_word += "[INFO] Done\n"
        expect_word = "\n" + self.ktk.banner("Checking Platform") + "\n" + expect_word
        expect_word += "============ Checking Platform : end   ============\n\n"
        self.assertEqual(self.fakeout.readline(), expect_word);

    def test_needUser(self):
        current_user = self.ktk.getUser()
        self.ktk.needUser(current_user)
        expect_word = "[INFO] Required User: {0}\n".format(current_user)
        expect_word += "[INFO] Current User: {0}\n".format(current_user)
        expect_word += "[INFO] Done\n"
        expect_word = "\n" + self.ktk.banner("Checking User") + "\n" + expect_word
        expect_word += "============ Checking User : end   ============\n\n"
        self.assertEqual(self.fakeout.readline(), expect_word);


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
        time.sleep(0.3) # wait lock
        self.ktk.asyncPrint("Test Text")
        time.sleep(0.3) # wait enough time to be printed
        asyncPrint_called.set()
        t.join() # wait mutex released
        time.sleep(0.3) # wait enough time to be printed
        self.assertEqual(self.fakeout.readline(), "Test Text\n")
        self.assertFalse(self.ktk.mutex.get('stdout').locked())

    def test_TRACE(self):
        f = self.ktk.trace_file
        old_trace_exist = os.path.exists(f)
        self.ktk.TRACE("Test Text")
        self.assertTrue(os.path.exists(f))
        if not old_trace_exist:
            os.remove(f)

    def test_inTrace(self):
        f = self.ktk.trace_file
        old_trace_exist = os.path.exists(f)
        @self.ktk.inTrace
        def inTrace():
            print("Test Text")
        inTrace()
        self.assertEqual(self.fakeout.readline(), "Test Text\n")
        self.assertTrue(os.path.exists(f))
        if not old_trace_exist:
            os.remove(f)

if __name__ == '__main__':
    KyanToolKit_Py.KyanToolKit_Py().clearScreen()
    unittest.main(verbosity=2, exit=False) #更多屏显信息，最后不调用sys.exit()
    KyanToolKit_Py.KyanToolKit_Py().pressToContinue()
