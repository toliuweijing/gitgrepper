
function! GitLsFile(gitDir, ...)

python << EOF

import vim
import os

class Converter:
  # @pattern the pattern to feed to git grep.
  # @repository the absolute path of the git repositiory.
  # @return the output stream of git grep execution
  def execGitLsFiles(self, pattern, repository):
    cwd = os.getcwd()
    os.chdir(repository)
    output = os.popen("git ls-files '*/" + pattern + "'").read()
    os.chdir(cwd)
    return output

  # extract qflist-type dictionaries from git-grep output
  # @param output - output stream from git grep.
  # @param repository - the absolute path of the git repository.
  def qflistFromGitLsFiles(self, output, repository):
    dictionaries = []

    for line in output.splitlines():
      filename = line

      dictionary = {
        'filename':repository+'/'+filename,
      }

      dictionaries.append(dictionary)
      if (len(dictionaries) > 50):
        break

    return dictionaries
    
  def generateQflist(self, pattern, repository):
    output = self.execGitLsFiles(pattern, repository)
    return self.qflistFromGitLsFiles(output, repository)

    
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

#let ANDROID_SDK = '/Users/developer/Projects/android-sdk-macosx/sources/android-17'
#command! -nargs=* AGF call GitLsFile(ANDROID_SDK, <f-args>)
