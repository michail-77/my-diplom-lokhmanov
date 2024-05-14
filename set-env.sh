echo "You are using yc-k8s-scale profile!"
yc config profiles activate yc-k8s-scale

export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)

# You can automate the process of obtaining a new token using crontab: 
# enter crontab -e, and then enter 0 * * * * export YC_TOKEN=$(yc iam create-token)
# echo "export YC_TOKEN=$(yc iam create-token)" >> ~/.bashrc # Command for bash shell
# echo "export YC_TOKEN=$(yc iam create-token)" >> ~/.zshrc # Command for zsh shell