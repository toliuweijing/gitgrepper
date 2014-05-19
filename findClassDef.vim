function! FindDefinition(gitDir, ...)

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
def findClassDef(pattern, gitDir):
  os.chdir(gitDir)  
  command = "git grep -in '" + pattern + "'"
  output = os.popen(command).read()
  return dictionariesFromGitGrep(output, gitDir)

# Main
pattern = ""
for e in vim.eval("a:000"):
  pattern = pattern + e
print pattern

if (len(pattern) > 0):
  gitDir = vim.eval("a:gitDir")
  qflist = findClassDef(pattern, gitDir)
  vim.command("let qflist=%s"%qflist)

EOF

call setqflist(qflist)
:copen

endfunction

