Output g0testcurrent.gif
Set Shell "zsh"
Require nvim

Set WindowBar Colorful

Hide
Type@100ms "nvim ../tests/testData/test/test_test.go"
Enter
Show

Type@100ms ":6"
Enter
Sleep 1s

Type@100ms ":G0TestCurrent"
Enter
Sleep 5s
