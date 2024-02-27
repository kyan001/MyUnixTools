#=================================================================
#   Make the prompt more easy to read.
#   Only run this by source in Terminal OSX in Bash!
#
#--Variables Defination-------------------------------------------
# N=Normal B=Bold U=Underline G=Gray R=Red P=Purple
# VN="\e[0m";VB="\e[1m";VU="\e[4m";
# VG="\e[2m";VR="\e[31m";VP="\e[35m";
Normal_font_tmp='\[\033[0;0m\]'
Color_font_tmp='\[\033[0;33m\]'
Purple_font_tmp='\[\033[0;35m\]'
Underline_font_tmp='\[\033[4;0m\]'

#--Common Variables-----------------------------------------------
# %c for "~" and %C for no "~"
# %C2 keep 2 last directorys. also try %C0
# %/  The current working directory. %~ with ~

prompt_host='\h'
prompt_pwd='\w'
prompt_user="\u"

#--Main-----------------------------------------------------------
export PS1="\n${Purple_font_tmp}${prompt_user}${Normal_font_tmp} @ ${Color_font_tmp}${prompt_pwd}${Normal_font_tmp} (${Underline_font_tmp}${prompt_host}${Normalal_font_tmp})\n> "

#--Unset Env Variables--------------------------------------------
unset Normal_font_tmp
unset Color_font_tmp
unset Purple_font_tmp
unset Underline_font_tmp
unset prompt_pwd
unset prompt_user
unset prompt_host
