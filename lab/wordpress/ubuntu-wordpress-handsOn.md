# 1 Ubuntu Wordpress HandsOn
## 1.1 목표

- 우분투 24.04 서버 한 대에 Apache + PHP + MySQL + 워드프레스를 직접 설치한다.
- 워드프레스는 같은 서버의 MySQL에 `localhost`로 접속한다.
- 브라우저로 접속했을 때 워드프레스 설치 화면(`wp-admin/install.php`)이 뜨는 것까지 확인한다.

---

## 1.2 사전 준비

- 우분투 24.04 서버 한 대, 인터넷 연결, `sudo` 가능한 계정.
- 이 문서의 예시는 `ansible-node2`(192.168.56.52)를 씁니다. 여러분 환경의 IP/호스트명으로 바꿔서 진행하세요.

```bash
ssh vagrant@192.168.56.52
```

---

## 1.3 Wordpress 구성

### 1.3.1 패키지 설치

```bash
sudo apt update
sudo apt install -y apache2 php libapache2-mod-php php-mysql mysql-server
```

### 1.3.2 서비스가 켜져 있는지 확인

```bash
systemctl is-active apache2
systemctl is-enabled apache2
systemctl is-active mysql
systemctl is-enabled mysql
```

### 1.3.3 워드프레스 다운로드 및 압축 해제

```bash
curl -o /tmp/wordpress.tar.gz https://wordpress.org/wordpress-6.8.tar.gz

sudo tar -xzf /tmp/wordpress.tar.gz -C /var/www/html

ls /var/www/html/wordpress
```

### 1.3.4 `wp-config.php` 만들기

```bash
cd /var/www/html/wordpress

sudo cp wp-config-sample.php wp-config.php

sudo vi wp-config.php
```

```php
define( 'DB_NAME', 'wp' );
/** Database username */
define( 'DB_USER', 'wp_user' );
/** Database password */
define( 'DB_PASSWORD', 'P@ssw0rd' );
```

### 1.3.5 Apache 가상호스트 설정

```bash
sudo vi /etc/apache2/sites-available/wordpress.conf
```

```apache
<VirtualHost *:80>
    ServerName example.com
    DocumentRoot /var/www/html/wordpress
    <Directory "/var/www/html/wordpress">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### 1.3.6 Apache 가상호스트 활성화

```bash
sudo a2ensite wordpress.conf

sudo a2dissite 000-default.conf

sudo systemctl reload apache2
```

### 1.3.7 데이터베이스 만들기

```bash
sudo mysql -e "CREATE DATABASE wp;"
sudo mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'P@ssw0rd';"
sudo mysql -e "GRANT ALL PRIVILEGES ON wp.* TO 'wp_user'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
sudo mysql -e "SHOW DATABASES;"
```
### 1.3.8 접속 확인

```bash
http://192.168.56.52
```

