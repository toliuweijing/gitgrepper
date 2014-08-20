gitgrepper
==========

A vim plugin that helps grepping source code in a large codebase. 

A demo on how to grep source code in Android sdk and quickly open it.
https://www.youtube.com/watch?v=8MD2eCVRnfE&feature=youtube_gdata_player

How does it work:
1. Gitgrepper takes user input and execute git-grep against the corresponding  codebase.
2. It opens the result in vim's quick-fix window so user can open it with one click.

Give a try: 
0. go to the codebase android-sdk-macosx directory and make it a git repo by 
  git init && git add .
1. Download and put gitgrepper.vim in ~/.vim/bundle/gitgreper/plugin/
2. In .vimrc, paste these two lines
  let ANDROID_SDK = '/Users/developer/Projects/android-sdk-macosx/sources/android-17'
  command! -nargs=* FindDefinition call GitGreg(ANDROID_SDK, <f-args>)
  nmap <Leader>fgg :FBFindDefinition
3. In vim, trigger <Leader>fgg, type class view and press enter. 
