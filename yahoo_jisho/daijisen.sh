#!/bin/bash
# Copyright: Christoph Dittmann <github@christoph-d.de>
# License: GNU GPL, version 3 or later; http://www.gnu.org/copyleft/gpl.html
#
# This script performs a Yahoo dictionary lookup for Japanese words
# using the daijisen.
#

export IRC_COMMAND='!daijisen'
export URL="http://dic.yahoo.co.jp/dsearch?enc=UTF-8&stype=1&dtype=0&p="

exec "$(dirname "$0")"/yj.sh "$@"
