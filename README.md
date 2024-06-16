# TerraformでAWSリソースを自動構築する<!-- omit in toc -->

## 今回の目的<!-- omit in toc -->

初めてterraformを用いてAWSリソースを構築することに挑戦してみます。

---

## 環境<!-- omit in toc -->

Windows 11 Home<br>
Gitは導入済み

---

## Terraformとは<!-- omit in toc -->

HashiCorp社が提供するマルチクラウド対応のインフラ構成ツールです。<br>`.tf`という拡張子のファイルにHCL（HashiCorpConfigurationLanguage）という独自の言語で処理を記述することでインフラ環境を構築できます。<br>インフラの構成を宣言的に定義（コードで最終的な状態を指定する）することができます。<br>また、インフラの設定をコード管理できるので、デプロイと変更の履歴を確認することができます。<br>作成作業を自動化できるので時間短縮が望めるだけでなく、開発環境、テスト環境、本番環境間の不一致をなくすことができます。


---

## 今回行うこと<!-- omit in toc -->

今回作成するリソースの構成図です。<br>
- CRUD処理ができる簡易なプログラムのシステム構成図を想定
- S3は画像の保存先として利用を想定
- RDSはマルチAZ構成とし可用性や耐障害性を高める構成とした
<img width="450" src=img/構成図.png>

---

## 手順<!-- omit in toc -->

- [1. AWS CLIのインストール](#1-aws-cliのインストール)
- [2. AWSアクセスキーの作成](#2-awsアクセスキーの作成)
- [3. tfenvのインストール](#3-tfenvのインストール)
- [4. Terraformのインストール](#4-terraformのインストール)
- [5. S3の作成](#5-s3の作成)
- [6. Terraformの初期化](#6-terraformの初期化)
- [7. Terraformのコードの作成](#7-terraformのコードの作成)
- [8. Terraformの実行](#8-terraformの実行)
- [9. Terraformのクリーンアップ](#9-terraformのクリーンアップ)

### 1. AWS CLIのインストール

---

Terraformを使用するためにはAWS CLIがインストールされている必要があります。<br>下記サイトを参照し、インストールを実行します。<br>
[AWS公式サイト](https://aws.amazon.com/cli/)
<br>下記コマンドでインストールしたバージョンが表示されれば完了です。

```bash
$ aws --version
```

---

### 2. AWSアクセスキーの作成

---

TerraformからAWSのサービスに接続するためのIAMユーザーとアクセスキーを作成します。<br>
作成したらアクセスキーIDとシークレットアクセスキーを認証情報（credentials）に登録します。<br>
認証情報は~/.aws/credentialsで確認できます。

```bash
$ aws configure --profile [環境の名称] #今回の環境用に認証情報を設定
AWS Access Key ID: #アクセスキーID
AWS Secret Access Key: #シークレットアクセスキー
Default region name: ap-northeast-1 #リージョンを選択
Default output format: json
```

---

### 3. tfenvのインストール

---

次にTerraformのバージョン管理ツールであるtfenvをインストールします。<br>
tfenvを使用することで、複数プロジェクト間でバージョンの一貫性を保ちつつ最適なバージョンを使用できます。<br>下記サイトを参照し、インストールを実行します。<br>
[公式サイト](https://github.com/tfutils/tfenv)

まずソースをクローンします。

```bash
$ git clone https://github.com/tfutils/tfenv.git .tfenv
```

次はパスを通します。ホームディレクトリ（C:\Users\[ユーザ名]）に`.bashrc`ファイルを作成し、PATHの環境変数設定を行います。<br>Windowsの形式ではそのままパスをコピーしても使用できないので、下記のように書き直します。

```bash
export PATH=$PATH:/c/Users/[ユーザ名]/.tfenv/bin
```

ターミナルを再起動し、下記のコマンドでコマンド一覧が表示されればtfenvのインストールは完了です。

```bash
$ tfenv
```

---

### 4. Terraformのインストール

---

インストール可能なTerraformのバージョンを確認します。

```bash
$ tfenv list-remote
```

任意のバージョンを指定してインストールします。

```bash
$ tfenv install [指定するバージョン]
```
最後に現在の環境で使用するバージョンを指定して完了です。

```bash
$ tfenv use [指定するバージョン]
```

---

### 5. S3の作成

---

次に`tfstate`ファイルを保存するS3をマネジメントコンソールで事前に作成しました。<br>
`tfstate`ファイルとは、Terraformが管理しているリソースの現在の状態を表すファイルです。<br>
個人開発ではローカルに保存しても問題ないですが、今回は複数人での開発を想定して保管先を作成したS3に設定します。<br>[参考サイト](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)

今回は`provider.tf`という名称のファイルに以下のように記述します。

```bash
# ------------------------------------------------------------
#  Terraform configuraton
# ------------------------------------------------------------
terraform {
  required_version = ">=[バージョン指定]"
  backend "s3" {
    bucket = "作成したS3のバケット名"　#backendで作成したS3を指定します
    region = "ap-northeast-1"
    key    = "terraform.tfstate"
  }
}
# ------------------------------------------------------------
#  Provider　#ここでプロバイダーを指定します
# ------------------------------------------------------------
provider "aws" {
  region  = "ap-northeast-1"
}

```

---

### 6. Terraformの初期化

---

先ほど作成した`provider.tf`ファイルが格納されたディレクトリで、terraform initコマンドを実行します。<br>ワークスペースが初期化され、使用されるプラグイン（今回はAWSプロバイダー）などがカレントディレクトリの`.terraform`内にダウンロードされます。

```bash
$ terraform init
```

---

### 7. Terraformのコードの作成

---

いよいよTerraformで管理・作成するAWSリソースをコードで定義していきます。
[公式サイト](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)を見ながら順番にリソースを定義していきます。
以下、一部のコードを抜粋しました。すべてのコードは[こちら](terraform)を参照ください。

```bash
# ------------------------------------------------------------
#  VPC
# ------------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    Name = "${var.tag_name}-vpc"
  }
}
```

```bash
# ------------------------------------------------------------#
#  rds
# ------------------------------------------------------------#
resource "aws_db_instance" "rds" {
  identifier                  = "${var.tag_name}-rds"
  engine                      = "mysql"
  engine_version              = "8.0.35"
  multi_az                    = true
  username                    = "foo"
  #マスターパスワードを自動生成
  manage_master_user_password = true
  instance_class              = "db.t3.micro"
  storage_type                = "gp2"
  allocated_storage           = 20
  db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  port                       = 3306
  parameter_group_name       = aws_db_parameter_group.db_parameter_group.name
  option_group_name          = aws_db_option_group.db_option_group.name
  backup_retention_period    = 0
  skip_final_snapshot        = true
  auto_minor_version_upgrade = false
  tags = {
    Name = "${var.tag_name}-rds"
  }
}
```

コードを記述したら`terraform fmt`でフォーマットをかけましょう。`.tfファイル`全体にフォーマットをかけ、コードの一貫性を保つことができます。

```bash
$ terraform fmt
```

---

### 8. Terraformの実行

AWSリソースを作成していきます。まずは`terraform plan`を実行し、リソースの追加・更新・削除の実行計画を確認します。

```bash
$ terraform plan
```

エラーが表示されず、内容にも問題がなければ`terraform plan`を実行し、実際にリソースの追加・更新・削除を行います。

```bash
$ terraform apply
```

<img width="450" src=img/succes.png><br>
無事リソースが作成できました！

---

### 9. Terraformのクリーンアップ

最後に、今回作成したリソースを`terraform destroy`コマンドを実行して削除しておきます。

```bash
$ terraform destroy
```

<img width="450" src=img/destroy.png><br>
全てのリソースが削除できました。

---

## 工夫できた点と反省点<!-- omit in toc -->

- 複数人で開発する環境を想定し、`tfstateファイル`をS3に保存する構成としました。

- RDSのマスターパスワードを`manage_master_user_password`を利用して設定し、Secrets Managerにパスワードが自動生成されるようにしました。

- 今回はTerraformに挑戦する事が目的だったこともあり、複数リソースを作成する際に必要な数量分だけリソースを追記する方法を選択しました。次回は組込関数などを用いて、同じ内容を複数回記述せずに済むよう工夫したいです。
