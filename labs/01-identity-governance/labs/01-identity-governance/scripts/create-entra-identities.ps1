# Lab 1 - Microsoft Entra ID: create test user for RBAC labs (Lab 2)
# Tenant domain: marciomarquesbhgmail.onmicrosoft.com

az ad user create `
  --display-name "Test RBAC AZ104" `
  --user-principal-name "teste.rbac@marciomarquesbhgmail.onmicrosoft.com" `
  --password "SenhaForte#2026!"
  