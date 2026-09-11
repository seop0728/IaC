
## 1. 목표

- 대상: `nodes` 그룹의 각 호스트
- 노드 **한 대 안에** 웹서버 + 워드프레스 + DB 를 독립적으로 구성한다(노드끼리 의존하지 않는다).
- 워드프레스는 같은 노드의 MySQL 에 `localhost` 로만 접속한다.
- 작업 위치: 컨트롤 노드(`ansible-ctrl`)의 `~/lab/wordpress`

---

## 2. 디렉터리 구조

```
~/lab/wordpress/
├── ansible.cfg
├── inventory.ini
├── site.yml
└── roles/
    └── wordpress/
        ├── defaults/main.yml
        ├── handlers/main.yml
        ├── tasks/main.yml
        └── templates/
            └── wordpress.conf.j2
```

`wp-config.php` 는 템플릿으로 두지 않는다. 워드프레스 tarball 안의 `wp-config-sample.php` 를 복사한 뒤 DB 관련 줄만 수정한다.

역할 뼈대는 `ansible-galaxy role init` 으로 만든다. `mkdir` 로 직접 만들지 않는다.

```bash
# ansible-ctrl 에서 실행
mkdir -p ~/lab/wordpress
cd ~/lab/wordpress
ansible-galaxy role init roles/wordpress
```

`role init` 을 하면 `defaults/ files/ handlers/ meta/ tasks/ templates/ tests/ vars/` 8개 표준 디렉터리가 생성된다. 이 실습에서는 `defaults/`, `handlers/`, `tasks/`, `templates/` 만 사용하고 나머지는 비워둔다.

인벤토리는 기존 랩의 것을 복사해 온다.

```bash
# ansible-ctrl 에서 실행
cp ~/lab/inventory.ini ~/lab/wordpress/inventory.ini
```

---

## 3. 파일

### `~/lab/wordpress/inventory.ini`

```ini
[control]
ansible-ctrl

[nodes]
ansible-node1
```

노드를 늘리려면 `[nodes]` 아래에 `ansible-node2` 처럼 한 줄씩 추가한다.

### `~/lab/wordpress/ansible.cfg`

```ini
[defaults]
inventory = inventory.ini
host_key_checking = False
```

### `~/lab/wordpress/site.yml`

```yaml
---
- name: 워드프레스 구성 (Ubuntu 24.04)
  hosts: nodes
  become: true
  roles:
    - wordpress
```

### `~/lab/wordpress/roles/wordpress/defaults/main.yml`

```yaml
---
wp_version: "6.8"
wp_download_url: "https://wordpress.org/wordpress-{{ wp_version }}.tar.gz"
wp_root: /var/www/html/wordpress

server_name: example.com

db_name: wp
db_user: wp_user
db_password: "P@ssw0rd"
db_root_password: "P@ssw0rd"

web_user: www-data
web_group: www-data
```

### `~/lab/wordpress/roles/wordpress/templates/wordpress.conf.j2`

```apache
<VirtualHost *:80>
    ServerName {{ server_name }}
    DocumentRoot {{ wp_root }}
    <Directory "{{ wp_root }}">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### `~/lab/wordpress/roles/wordpress/handlers/main.yml`

```yaml
---
- name: apache 리로드
  ansible.builtin.systemd:
    name: apache2
    state: reloaded
```

### `~/lab/wordpress/roles/wordpress/tasks/main.yml`

```yaml
---
- name: apt 캐시 갱신
  ansible.builtin.apt:
    update_cache: true
    cache_valid_time: 3600

- name: 필요한 패키지 설치
  ansible.builtin.apt:
    name:
      - apache2
      - php
      - libapache2-mod-php
      - php-mysql
      - mysql-server
      - python3-pymysql
    state: present

- name: apache2 실행 보장
  ansible.builtin.systemd:
    name: apache2
    enabled: true
    state: started

- name: mysql 실행 보장
  ansible.builtin.systemd:
    name: mysql
    enabled: true
    state: started

- name: 워드프레스 tarball 다운로드
  ansible.builtin.get_url:
    url: "{{ wp_download_url }}"
    dest: /tmp/wordpress.tar.gz
    mode: "0644"

- name: 워드프레스 압축 해제
  ansible.builtin.unarchive:
    src: /tmp/wordpress.tar.gz
    dest: /var/www/html
    remote_src: true
    creates: "{{ wp_root }}/wp-settings.php"
  register: wp_extracted

- name: 워드프레스 파일 소유권 설정
  ansible.builtin.file:
    path: "{{ wp_root }}"
    state: directory
    recurse: true
    owner: "{{ web_user }}"
    group: "{{ web_group }}"
  when: wp_extracted.changed

- name: wp-config.php 만들기 (wp-config-sample.php 복사)
  ansible.builtin.copy:
    src: "{{ wp_root }}/wp-config-sample.php"
    dest: "{{ wp_root }}/wp-config.php"
    remote_src: true
    force: false
    owner: "{{ web_user }}"
    group: "{{ web_group }}"
    mode: "0640"

- name: wp-config.php 에 DB 접속정보 채우기
  ansible.builtin.replace:
    path: "{{ wp_root }}/wp-config.php"
    regexp: "{{ item.regexp }}"
    replace: "{{ item.line }}"
  loop:
    - { regexp: "define\\( 'DB_NAME', '[^']*' \\);",     line: "define( 'DB_NAME', '{{ db_name }}' );" }
    - { regexp: "define\\( 'DB_USER', '[^']*' \\);",     line: "define( 'DB_USER', '{{ db_user }}' );" }
    - { regexp: "define\\( 'DB_PASSWORD', '[^']*' \\);", line: "define( 'DB_PASSWORD', '{{ db_password }}' );" }
  loop_control:
    label: "{{ item.line }}"

- name: 워드프레스 가상호스트 배치
  ansible.builtin.template:
    src: wordpress.conf.j2
    dest: /etc/apache2/sites-available/wordpress.conf
    mode: "0644"
  notify: apache 리로드

- name: 워드프레스 사이트 활성화
  ansible.builtin.command:
    cmd: a2ensite wordpress.conf
    creates: /etc/apache2/sites-enabled/wordpress.conf
  notify: apache 리로드

- name: 기본 사이트(000-default) 비활성화
  ansible.builtin.command:
    cmd: a2dissite 000-default.conf
    removes: /etc/apache2/sites-enabled/000-default.conf
  notify: apache 리로드

- name: MySQL root 를 비밀번호 인증으로 (최초 auth_socket -> 비번)
  ansible.mysql.mysql_user:
    name: root
    host: localhost
    password: "{{ db_root_password }}"
    check_implicit_admin: true
    login_unix_socket: /var/run/mysqld/mysqld.sock
    login_user: root
    login_password: "{{ db_root_password }}"

- name: "{{ db_name }} 데이터베이스 생성"
  ansible.mysql.mysql_db:
    name: "{{ db_name }}"
    state: present
    login_user: root
    login_password: "{{ db_root_password }}"

- name: "{{ db_user }} 사용자 + 권한"
  ansible.mysql.mysql_user:
    name: "{{ db_user }}"
    host: localhost
    password: "{{ db_password }}"
    priv: "{{ db_name }}.*:ALL"
    login_user: root
    login_password: "{{ db_root_password }}"
```

---

## 4. 사전 준비

`ansible.mysql` 모듈은 컬렉션과 파이썬 라이브러리가 둘 다 필요하다.

```bash
# ansible-ctrl 에서 실행
ansible-galaxy collection list | grep -i mysql
```

없다면 설치한다.

```bash
ansible-galaxy collection install ansible.mysql
```

파이썬 라이브러리(`python3-pymysql`)는 역할의 "필요한 패키지 설치" 태스크가 대상 노드에 함께 설치한다.

---

## 5. 실행

```bash
# ansible-ctrl 에서 실행
cd ~/lab/wordpress
ansible-playbook site.yml
```

---

## 6. 검증

### 6.1 node1 에서 확인할 명령

```bash
curl -sI http://localhost/
```

브라우저 접속 주소.

| VM | 접속 URL |
| --- | --- |
| ansible-node1 | http://192.168.56.51 |

