variable "resource_group_name" {
    type = string
    description = "名前"
}

variable "location" {
    type = string
    default = "japaneast"
}

variable "vm_name" {
    type = string
    description = "仮想マシンの名前"
}

variable "storage_account_name" {
    type = string
    default = "mytfstateacctpoent"
}