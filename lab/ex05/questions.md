# 종합 실습 — 변수와 템플릿으로 웹서버 구성하기

---

# 문제

## 문제 1 — Apache 설치

**1-1.** `~/lab/ex05-web` 디렉터리를 만들고 이동하세요.

**1-2.** `nodes` 그룹에 `apache2`를 설치하고, 서비스가 켜져 있는지(`started`) + 부팅 시 자동 실행(`enabled`)까지 보장하는 플레이북 `install_apache.yml`을 작성하세요.

**1-3.** `ansible-ctrl`에서 각 노드로 `curl`을 날려, apache2 기본 페이지가 응답하는지 확인하세요.

## 문제 2 — 변수 + 팩트 + Jinja2 템플릿으로 index.html 배포

**2-1.** `install_apache.yml`의 `vars`에 `site_title`(예: "사내 웹서버")과 `site_owner`(담당 부서) 변수를 정의하세요.

**2-2.** 아래 뼈대로 `templates/index.html.j2`를 작성하세요. 빈칸에 알맞은 변수·팩트 표현식을 채우세요.

```jinja2
<!DOCTYPE html>
<html>
<head>
  <title>{{ ① }}</title>
</head>
<body>
  <h1>{{ ② }}</h1>
  <p>담당: {{ ③ }}</p>
  <p>호스트: {{ ④ }} ({{ ⑤ }})</p>
</body>
</html>
```

- ① 페이지 제목으로 쓸 변수 
- ② ①과 같은 변수 
- ③ 담당 부서 변수 
- ④ 팩트에서 가져온 호스트명 
- ⑤ 팩트에서 가져온 IPv4 주소

**2-3.** `install_apache.yml`에 `ansible.builtin.template`으로 `/var/www/html/index.html`을 배포하는 태스크를 추가하세요.

## 문제 3 — `host_vars`로 노드마다 다른 문구 주기

**3-1.** `host_vars/ansible-node1.yml`, `host_vars/ansible-node2.yml`을 만들어 `site_title`을 노드마다 다르게 정의하세요. `ansible-node1`에는 `site_tagline`이라는 변수도 하나 더 추가하고, `ansible-node2`에는 추가하지 마세요(문제 5의 `default` 필터 확인용으로 일부러 비워둔다). 그리고 `install_apache.yml`의 `vars`에서 `site_title` 줄을 지우세요 — 플레이 `vars`는 `host_vars`보다 우선순위가 높아서, 지우지 않으면 `host_vars`에 뭘 적어도 무시된다.

**3-2.** 플레이북을 다시 실행하고, 두 노드의 페이지 제목이 서로 다르게 나오는지 확인하세요.

## 문제 4 — `vars_prompt`로 배포 시점에 값 입력받기

**4-1.** `install_apache.yml`에 `vars_prompt`를 추가해 실행할 때마다 배포 환경(`deploy_env`, 기본값 `dev`)을 입력받도록 하세요. 템플릿에는 아래 줄을 추가하고 빈칸을 채우세요.

```jinja2
  <p>배포 환경: {{ ① }}</p>
```

① `vars_prompt`로 입력받은 변수

**4-2.** 실행해서 `prod`를 입력하고, 두 노드 페이지에 모두 반영되는지 확인하세요.

## 문제 5 — 필터로 출력 다듬기

**5-1.** 템플릿에서 `deploy_env`는 `upper` 필터로 대문자로, `site_tagline`은 `default` 필터로 값이 없을 때 "태그라인 미설정"이 나오게 아래 두 줄의 빈칸을 채우세요.

```jinja2
  <p>{{ ① }}</p>
  <p>배포 환경: {{ ② }}</p>
```

- ① 값이 있으면 `site_tagline`, 없으면 `'태그라인 미설정'`
- ② `deploy_env`를 대문자로

**5-2.** 다시 실행해, `site_tagline`이 있는 `ansible-node1`과 없는 `ansible-node2`의 결과가 어떻게 다른지 확인하세요.

## 문제 6 — 멱등성 확인

**6-1.** 아무것도 바꾸지 않고 플레이북을 다시 실행해, `changed=0`으로 수렴하는지 확인하세요.

## 문제 7 — 환경 정리 (다음 apache2 실습을 위한 초기화)

**7-1.** 이번 실습에서 두 노드에 한 일 — `index.html` 배포, `apache2` 설치 — 를 되돌리는 플레이북 `cleanup_apache.yml`을 작성하세요. 패키지는 설정 파일까지 완전히 제거(`purge`)하고, 더 이상 필요 없는 의존 패키지도 함께 정리하세요.

**7-2.** 실행하고, `apache2`가 완전히 사라졌는지(패키지·서비스·페이지 응답 전부) 확인하세요.
