# Task 2 - Create management group and add subscription
az account management-group create --name mg-corp --display-name "Corp"
az account management-group subscription add --name mg-corp --subscription 9c1310f1-b1f5-46bc-ba21-62ce547631aa
