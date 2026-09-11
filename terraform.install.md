
```
sudo apt-get update
sudo apt-get install -y unzip
```

```
curl -fsSL https://awscli.amazonaws.com/v2/install.sh | bash
```

```
echo 'export PATH="$HOME/.local/bin:$PATH"' >> .bashrc
source ~/.bashrc
```

```
aws --version
```

---

```
aws configure
-> key... 확인 후 리전 정보 3번째 프롬프트에 넣어주기 Default region name [None]: `ap-northeast-2`
```

```
aws sts get-caller-identity
```

---

```
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
```
terraform -install-autocomplete
```

```
exec bash
```

```
terraform -v
```
