function! FindDefinitionClass(gitDir, pattern)

python << EOF

import vim
import os


# extract qflist-type dictionaries from git-grep output
def dictionariesFromGitGrep(output, cwd):
  dictionaries = []

  for line in output.splitlines():
    
    [filename, lnum, text] = line.split(':') 

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
  command = "git grep -in 'class " + pattern + " '"
  output = os.popen(command).read()
  return dictionariesFromGitGrep(output, gitDir)

# Main
pattern = vim.eval("a:pattern")
gitDir = vim.eval("a:gitDir")
qflist = findClassDef(pattern, gitDir)
vim.command("let qflist=%s"%qflist)

EOF

echo qflist
call setqflist(qflist)
:copen

endfunction

