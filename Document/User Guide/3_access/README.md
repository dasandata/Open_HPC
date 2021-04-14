[userguide]: https://github.com/dasandata/Open_HPC/tree/master/Document/User%20Guide#-%EB%AA%A9%EC%B0%A8
[ohpc]: http://openhpc.community/
[slurm]: https://slurm.schedmd.com/

# [3.   접속 방법][userguide]

안녕하세요 다산데이타 입니다.  
HPC 클러스터에 접속하는 방법을 알아 보겠습니다.  

## [3.1  윈도우즈용 Mobaxterm][userguide]

윈도우즈의 경우 SSH 접속과 SCP를 통한 파일전송,  
그리고 X11Forwading 기능을 한번에 사용할 수 있는 **mobaxterm** 을 사용 하는 것을 권장 하고 있습니다.  
<br>
아래 링크에서 다운로드 받아 사용할 수 있습니다.  
### https://mobaxterm.mobatek.net/download.html
설치가 끝나면 "Start local terminal" 버튼을 클릭하여 터미널 창을 열 수 있습니다.  
터미널 창이 열리면 아래와 같은 형식으로 사용자 ID 와 IP를 입력하고 클러스터에 접속합니다.  
패스워드는 자릿수 유출방지를 위해 입력중 표시되지 않습니다.  

```bash
ssh  -XCY  <USER ID>@<IP ADDRESS>

# Exmple
ssh -XCY  honggildong@192.168.0.55
```

## [3.2  Mac OS Terminal][userguide]


## [3.3  Linux 의 Terminal][userguide]


***
## [끝][userguide]
