# terraform_azure_rag_poc
perform IaC CI/CD using Terraform and Github Actions

# folder structure

```bash
.
├── README.md                        # プロジェクトの説明
├── .github/
│   └── workflows/
│       └── azure-deploy.yml         # GitHub Actions ワークフロー（テンプレート）
├── img/
│   ├── diagram.drawio.svg
│   └── diagram.svg
└── terraform/
    ├── main.tf                     # メインのTerraformリソース定義（VMやRGなど）
    ├── outputs.tf                  # 出力値定義（例: public IPなど）
    ├── variables.tf                # 入力変数の定義
    ├── versions.tf                 # プロバイダー・Terraform本体のバージョン指定
    ├── terraform.tfvars.example    # 変数値のサンプル
    └── scripts/
        └── install_docker_fastapi.sh  # VM上で実行する初期スクリプト

```
`.github/workflows/azure-deploy.yml` は空のテンプレートです。CI/CD の設定を行う際はこのファイルを編集してください。

# visual representation of the infrastructure
![Azure infrastracture diagram](img/diagram.svg)

# Setup
## 手順
- Azure CLIでAzureにログインします。
```bash
az login
```
- Terraformの状態ファイルを保管するためのリソースグループ及び関連するリソースを作成します。ストレージアカウントの名前はAzure内部で一意である必要があるので`<YOUR_STORAGE_ACCOUNT_NAME>`の部分は適切な文字列に変更してください。

```bash
# 1. リソースグループを作成
az group create --name tfstate-rg --location japaneast

# 2. ストレージアカウントを作成
az storage account create \
  --name <YOUR_STORAGE_ACCOUNT_NAME>
  --sku Standard_LRS \
  --encryption-services blob

# 3. ストレージアカウントのキーを取得
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group tfstate-rg \
  --account-name <YOUR_STORAGE_ACCOUNT_NAME> \
  --query '[0].value' -o tsv)

# 4. BLOBコンテナを作成
az storage container create \
  --name tfstate \
  --account-name <YOUR_STORAGE_ACCOUNT_NAME> \
  --account-key $ACCOUNT_KEY

```

- `terraform`階層に移動しterraformを初期化します。
```bash
cd terraform  # ← *.tf ファイルがあるディレクトリへ移動
terraform init
```
`versions.tf` 内の `backend \"azurerm\"` ブロックにある `storage_account_name` は、作成したストレージアカウント名に合わせて変更してください。

- 仮想マシンのadminユーザーとしてログインする際のssh鍵を以下のように作成します。
```bash
ssh-keygen -t rsa -f ~/.ssh/id_rsa_azure
```

- 実行前に以下のコマンドでエラーが無いかチェックします。`terraform.tfvars`は`.tf`ファイル内で記述されている変数の値を格納するファイルです。リポジトリには`.gitignore`が含まれていないため、`terraform/terraform.tfvars`をコミットしないよう必要に応じて`.gitignore`を作成してください。参考として`terraform.tfvars.example`を代わりに配置しました。
```bash
terraform plan -var-file="terraform.tfvars"
```
- 筆者の環境ではエラーとなったので以下のコマンドでIPv6を無効化しました。
```bash
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
```

- 問題なければ以下のコマンドでAzureリソースをビルドします。
```bash
terraform apply -var-file="terraform.tfvars"
```
- 無事ビルドされたら、ssh接続でで仮想マシンにログインできるかどうかをbashなどで確認してください。
- 作成したAzureリソースを削除する場合は次のコマンドを使用します。
```bash
terraform destroy -var-file="terraform.tfvars"
```
