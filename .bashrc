#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

BASEPS1='\[\033[01;32m\][\u@\h\[\033[00m\] \[\033[01;34m\]\W]\[\033[00m\] \$ '
#PS1=$'\\033[01;42m\]\u@\h\[\033[00m\]\[\033[01;32m\]\ue0b0\[\033[00m\]'
HISTFILESIZE=5000000
HISTSIZE=5000000

unalias -a

if [[ -f $HOME/.bash_aliases ]]; then
	. $HOME/.bash_aliases
fi

if [[ -f $HOME/.git_aliases ]]; then
	. $HOME/.git_aliases
fi

export HISTCONTROL=ignoreboth:erasedups 
export PATH=$PATH:/home/devansh/Win/Devansh/ShellScripts/
export XDG_CONFIG_HOME=$HOME/.config

desel

# PS1 customization
# get current branch in git repo
function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		#echo -n "\[\033[1;31m[${BRANCH}\[\033[1;32m${STAT}]"
		export PS1="\[\033[1;31m[${BRANCH}\[\033[1;32m${STAT}]${BASEPS1}"
	else
		#echo ""
		export PS1="${BASEPS1}"
	fi
}

# get current status of git repo
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits=">${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " ${bits}"
	else
		echo ""
	fi
}

export LC_ALL=en_US.UTF-8
#export PS1="\`parse_git_branch\`$PS1"
export PROMPT_COMMAND="parse_git_branch"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

export MIGRATIONS=/opt/mybatis-migrations
export PATH=$PATH:$MIGRATIONS/bin

export JAVA_HOME=/usr/lib/jvm/jdk1.8.0_221
export PATH=$PATH:$JAVA_HOME/bin

cp $HOME/.bashrc $HOME/.bashrc.bak
