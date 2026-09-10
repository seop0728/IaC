# 디렉터리 구조

```
├── ansible.cfg
├── inventory.ini
├── site.yml                         ← 진입점: 역할을 불러 실행하기만 한다
└── roles/
    └── wordpress/
        ├── defaults/main.yml        ← 조정 가능한 변수(기본값)
        ├── handlers/main.yml        ← 핸들러(apache 리로드)
        ├── tasks/main.yml           ← 실제 작업
        └── templates/
            └── wordpress.conf.j2    ← 가상호스트만 템플릿으로 만든다
```
