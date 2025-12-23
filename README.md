# Inventario_Backup

## **Como usar:**

### **ANTES de formatar:**

1. **Salve o script** como `inventario-apps.ps1`
2. **Execute como Administrador** (botão direito → "Executar como administrador")
3. O script vai criar uma pasta `C:\Backup-Apps-[data]` com todos os arquivos
4. **Copie essa pasta inteira** para um HD externo, pen drive ou nuvem

### **DEPOIS de formatar:**

1. Copie a pasta de backup de volta para o computador
2. Execute o arquivo `REINSTALAR.ps1` como Administrador
3. Ele vai reinstalar automaticamente tudo que o Winget conseguir
4. Use os arquivos CSV para conferir o que precisa ser instalado manualmente

## **O que o script faz:**

✅ Exporta lista do Winget (reinstalação automática)
✅ Lista todos os programas Win32 (64 e 32 bits)
✅ Lista apps da Microsoft Store
✅ Lista programas do usuário atual
✅ Cria uma lista em texto simples (fácil de ler)
✅ Gera script de reinstalação automática

## **Dicas extras:**

- O Winget vai reinstalar a maioria dos programas automaticamente
- Para apps da Store, você precisará entrar na sua conta Microsoft
- Alguns programas (Adobe, Autodesk, etc.) precisam instalação manual
- Salve também a pasta `%AppData%` se quiser manter configurações
