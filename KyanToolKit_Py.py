##################################################################
# Version 1.4
##################################################################
import os
import sys
import time
import getpass;
class KyanToolKit_Py(object):
	def __init__(self,trace_file_="trace.xml"):
		self.trace_file = trace_file_
		pass
	def __del__(self):
		pass
	def banner(self,content_="Well Come"):
		# char def
		self.special_char = "#"
		self.space_char = " "
		self.GOLDENSECTION = 0.618
		# length calc
		itsays = content_.strip()
		effective_length = int(len(itsays))
		# gen contents
		content_line = self.special_char \
						+ str(self.space_char * int(effective_length/self.GOLDENSECTION*(1-self.GOLDENSECTION)/2)) \
						+ itsays \
						+ str(self.space_char * int(effective_length/self.GOLDENSECTION*(1-self.GOLDENSECTION)/2)) \
						+ self.special_char
		content_line_lenght = len(content_line)
		banner_border = self.special_char * content_line_lenght
		return banner_border + '\n' + content_line + '\n' + banner_border

	def clearScreen(self):
		if "win32" == sys.platform:
			os.system('cls')
		elif "linux" in sys.platform:
			os.system('clear')
		else:
			os.system('clear')
			self.err("No clearScreen for " + sys.platform)

	def pressToContinue(self,input_="..."):
		#PY2# raw_input(input_)
		input(input_)

	def getInput(self,question_,prompt_='> '):
		print(question_)
		#PY2# return raw_input(prompt_).strip()
		return input(prompt_).strip()

	def getChoice(self,choices_):
		out_print = ""
		index = 1
		for item in choices_:
			out_print += "\n" + str(index) + " - " + str(item)
			index += 1
		user_choice = self.getInput(out_print);
		if user_choice in choices_:
			return user_choice;
		elif user_choice.isdigit():
			numerical_choice = int(user_choice);
			if numerical_choice > len(choices_):
				self.byeBye("[ERR] Invalid Choice")
			return choices_[numerical_choice-1]
		else:
			self.err("Please enter a valid choice");
			return self.getChoice(choices_);

	def getUser(self):
		return getpass.getuser();

	def needPlatform(self, expect_platform):
		print("============ Checking Platform ============");
		self.info("Required Platform: " + expect_platform);
		self.info("Current Platform: " + sys.platform);
		if not expect_platform in sys.platform:
			self.err("Wrong Platform.");
			self.byeBye("Bye");
		else:
			self.info("Done\n");
	def needUser(self, expect_user):
		print("============ Checking User ============");
		self.info("Required User: " + expect_user);
		self.info("Current User: " + self.getUser());
		if self.getUser() != expect_user:
			self.byeBye("Bye");
		else:
			self.info("Done\n");

	def byeBye(self,input_="See you later."):
		exit(input_)

	def TRACE(self,input_,trace_type='INFO'):
		trace_content = ''.join(input_)
		current_time = time.strftime('%Y-%m-%d %H:%M:%S',time.localtime(time.time()))
		current_function = sys._getframe().f_back
		current_function_name = current_function.f_code.co_name
		current_line = current_function.f_code.co_firstlineno
		current_filename = current_function.f_code.co_filename
		trace_header = "\n<" + trace_type \
				+ ' FILE="' + current_filename + '"' \
				+ ' LINE="' + str(current_line) + '"' \
				+ ' TIME="' + current_time + '"' \
				+ ' FUNC="' + current_function_name + '()">\n'
		trace = open(self.trace_file,'a')
		trace.write(trace_header + trace_content + "\n</" + trace_type + ">\n")

	def runCmd(self, words):
		if len(words) > 80:
			def breakCommands(cmd):
				formatted_cmd = cmd.replace(' -','\n# \t-');
				formatted_cmd = "##########################.\n# " + formatted_cmd + "\n##########################.";
				return formatted_cmd;
			print(breakCommands(words));
		else:
			print(self.banner(words));
		result = os.system(words);
		self.checkResult(result);

	def checkResult(self, result):
		if 0 == result:
			self.info("Done\n")
		else:
			self.warn("Failed\n")

	def info(self, words):
		print("[INFO] " + words)

	def warn(self, words):
		print("[WARNING] " + words)

	def err(self, words):
		print("[ERROR] " + words)
