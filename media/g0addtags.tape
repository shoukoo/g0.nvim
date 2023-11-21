Output g0addtags.gif
Set Shell "zsh"
Require nvim

Set WindowBar Colorful

Hide
Type@100ms "nvim ../tests/testData/test/test.go"
Enter
Show

Type@100ms ":36"
Enter
Sleep 1s

Type@100ms ":G0AddTags"
Enter
Sleep 3s
