========================================
  .NET Framework 3.5 離線安裝包
========================================

【快速安裝】
  1. 下載本專案
  2. 對 install.bat 按右鍵 → 以系統管理員身分執行
  3. 完成！（sxs 已內建，不需額外準備）

【檔案結構】
  NET35-Offline-Installer/
  ├── install.bat               ← 點兩下執行
  ├── Win10_22H2/sxs/            ← CAB 已內建
  └── Win11_25H2/sxs/            ← CAB 已內建

【運作原理】
  直接吃 sources\sxs 的 CAB 檔給 DISM，不用連 Windows Update

【內建版本】
  Win10_22H2 → Windows 10 22H2 (build 19045)
  Win11_25H2 → Windows 11 25H2

【Windows 11 26H1 (build 28000) 以上】
  26H1 起微軟移除 .NET 3.5 選用元件，DISM/sxs 與 Windows Update 都裝不了，
  改用微軟獨立安裝器：
  1. 下載 https://go.microsoft.com/fwlink/?LinkID=2337635 (DotNet35Setup.exe)
  2. 放到 install.bat 同一個資料夾
  3. 執行 install.bat，會自動偵測並改跑獨立安裝器（/passive /norestart）
  安裝後可能需要重新開機。

【自訂 sxs（選用）】
  若想自己抽特定版本：
  1. 從 Windows ISO 複製 sources\sxs
  2. 蓋掉對應目錄即可

  或用 PowerShell 自動抽取：
  .\build_offline_package.ps1

【常見問題】
  Q: DISM 報錯找不到來源？
  A: 版本不合會自動轉 Windows Update

  Q: 可以放隨身碟？
  A: 可以，install.bat 用相對路徑

========================================
