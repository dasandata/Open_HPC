[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/

[6]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide/6_etc
[6.1]: http://google.com

# [6.   기타][userguide]

안녕하세요 다산데이타 입니다.

앞에서 다루지 못했던 내용들을 추가 했습니다.

## [## 6.1  파일전송(scp, rsync)][6]  


### ### Windows Mobaxterm

mobaxterm 에 자체 내장된 scp 기능을 이용 할 수 있습니다.

### ### Windows용 winscp, 또는 FileZilla (FileZilla는 mac os용도 있습니다.)

#### https://winscp.net/

#### https://filezilla-project.org/

### ### scp - Linux 와 Mac OS Terminal
작은 크기의 간단한 파일 및 폴더를 전송하는데 사용 합니다.  
중간에 연결이 끊어지면, 처음부터 다시 전송 됩니다. (FileZilla 같은 프로그램을 사용하면 이어서 전송 됩니다.)

```bash
# File Copy    local source to Remote target
scp    ~/aaa.txt    user@192.168.0.89:~/  

# File Copy   Remote source to Local Target
scp      user@192.168.0.89:~/aaa.txt      ~/

# Forder Copy (-r 옵션)  Remote source to Remote target
scp  -r  user@192.168.0.89:~/forderA   korea@192.168.0.90:~/
```

### ### rsync - Linux Terminal
파일과 폴더가 크거나 여러개 인 경우 사용 합니다.  
중간에 연결이 끊어져도 이어서 전송 됩니다.  
```bash
# File and Forder Copy    local source to Remote target
rsync  -avzh  ~/aaa.txt    user@192.168.0.89:~/  

# File Copy   Remote source to Local Target
rsync  -avzh  user@192.168.0.89:~/aaa.txt      ~/
```

## [## 6.3 추가 예정.)][6]  

***
## [끝][6]
