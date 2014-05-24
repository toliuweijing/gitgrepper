" A wrapper to execute git-grep in a given repo and surface matched results in
" quickfix window.
" Here is an example to find a class definition in java,
"   let word=expand("<cword>")
"   command! -nargs=* FindDefinitionClass call GitGreg('/Users/toliuweijing/MyAckLibrary/android-19', 'class ', <f-args>, ' ')
"
" @param gitDir, an absolute path of git repo.
" @param ..., a number of components, which is aggregated into a single pattern 
"   and used to search in gitDir.
function! GitGreg(gitDir, ...)

python << EOF

import vim
import os

# extract qflist-type dictionaries from git-grep output
def dictionariesFromGitGrep(output, cwd):
  dictionaries = []

  for line in output.splitlines():
    
    filename = line.split(':')[0]
    lnum = line.split(':')[1]
    text = line.split(':')[2]

    dictionary = {
      'filename':cwd+'/'+filename, 
      'lnum':int(lnum),
      'text':text
    }

    dictionaries.append(dictionary)

  return dictionaries

# find class definition with pattern and git directory
def gg_findDef(pattern, gitDir):
  cwd = os.getcwd()
  os.chdir(gitDir)  
  command = "git grep -in '" + pattern + "'"
  output = os.popen(command).read()
  return dictionariesFromGitGrep(output, gitDir)

# Main
# 1. aggregate function arguments into a single pattern. 
# 2. search in gitDir with the pattern.
# 3. deploy into quickfix window.
pattern = ""
for e in vim.eval("a:000"):
  pattern = pattern + e
print pattern

if (len(pattern) > 0):
  gitDir = vim.eval("a:gitDir")
  qflist = gg_findDef(pattern, gitDir)
  vim.command("let qflist=%s"%qflist)

EOF

" surface results in quickfix window.
call setqflist(qflist)
:copen

endfunction

