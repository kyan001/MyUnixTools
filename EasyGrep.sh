#!/usr/bin／env bash
#
#=================================================================
# EasyGrep.sh
#   Easily to grep things.
#
# HISTORY
#-----------------------------------------------------------------
#     DATE    |     AUTHOR     |  VERSION | COMMENT
#-------------+----------------+----------+-----------------------
#  2013-03-14 |     YAN Kai    |   V1.0   | Script Creation
#             |                |          |
#-----------------------------------------------------------------
#=================================================================
#

PARAMS="";
until [ $# = 0 ]
do
	if echo "\\$1" | grep "-" > /dev/null;
	then
		PARAMS="$PARAMS $1";
		shift;
	else
		echo "       [ grep $PARAMS \"$1\" * ]";
		grep $PARAMS "$1" *;
		if [ $? -ne 0 ]
		then
			echo "       [ Found NOTHING ]";
			echo "";
		else
			echo "";
		fi
		shift;
	fi
done
