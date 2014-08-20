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

class Converter:
  # @pattern the pattern to feed to git grep.
  # @repository the absolute path of the git repositiory.
  # @return the output stream of git grep execution
  def execGitGrep(self, pattern, repository):
    cwd = os.getcwd()
    os.chdir(repository)
    output = os.popen("git grep -in '" + pattern + "'").read()
    os.chdir(cwd)
    return output

  # extract qflist-type dictionaries from git-grep output
  # @param output - output stream from git grep.
  # @param repository - the absolute path of the git repository.
  def qflistFromGitGrep(self, output, repository):
    dictionaries = []

    for line in output.splitlines():
      filename = line.split(':')[0]
      lnum = line.split(':')[1]
      text = line.split(':')[2]

      dictionary = {
        'filename':repository+'/'+filename,
        'lnum':int(lnum),
        'text':text
      }

      dictionaries.append(dictionary)
      if (len(dictionaries) > 50):
        break

    return dictionaries

  def generateQflist(self, pattern, repository):
    output = self.execGitGrep(pattern, repository)
    return self.qflistFromGitGrep(output, repository)

# Main
# 1. aggregate function arguments into a single pattern.
# 2. search in gitDir with the pattern.
# 3. deploy into quickfix window.
pattern = ""
for e in vim.eval("a:000"):
  if (pattern == ""):
    pattern = e
  else:
    pattern = pattern + " " + e
print pattern

if (len(pattern) > 0):
  gitDir = vim.eval("a:gitDir")
  qflist = Converter().generateQflist(pattern, gitDir)
  vim.command("let qflist=%s"%qflist)

EOF

" surface results in quickfix window.
call setqflist(qflist)
:copen

endfunction

" i.e. :GitGregDir $path class Log
command! -nargs=* GitGregDir call GitGreg(<f-args>)
