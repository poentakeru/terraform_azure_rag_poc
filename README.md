# terraform_azure_rag_poc
perform IaC CI/CD using Terraform and Github Actions

# folder structure

```bash
.
├── README.md                    # プロジェクトの説明
└── terraform/
    ├── main.tf                 # メインのTerraformリソース定義（VMやRGなど）
    ├── outputs.tf              # 出力値定義（例: public IPなど）
    ├── variables.tf            # 入力変数の定義
    ├── versions.tf             # プロバイダー・Terraform本体のバージョン指定
    └── scripts/
        └── install_docker_fastapi.sh  # VM上で実行する初期スクリプト

```

# visual representation of the infrastructure
![Azure infrastracture diagram](img/diagram.svg)
