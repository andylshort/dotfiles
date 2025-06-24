[[ -r "$HOME/.profile" ]] && source "$HOME/.profile"
[[ -r "$HOME/.bashrc" ]]  && source "$HOME/.bashrc"

export PATH="/usr/local/sbin:$PATH"
export PATH=$PATH:"/Library/TeX/texbin/"

# Setting PATH for Python 3.9
# The original version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.9/bin:${PATH}"
export PATH
