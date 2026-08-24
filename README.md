# .NET Framework 3.5 Offline Installer

> DISM-based offline installer for Windows 10 / 11 — sxs CAB files included, no internet required.

[![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D6?logo=windows&logoColor=white)](https://github.com/pttocean-afk/NET35-Offline-Installer)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Stars](https://img.shields.io/github/stars/pttocean-afk/NET35-Offline-Installer?style=flat)

---

## 快速開始

1. **下載** 本專案（Code → Download ZIP 或直接 git clone）
2. 對 `install.bat` 按右鍵 → **以系統管理員身分執行**
3. 完成！sxs 已內建在專案中，不需額外準備

## 檔案結構

```
NET35-Offline-Installer/
├── install.bat                     ← 點兩下以系統管理員執行
├── build_offline_package.ps1       ← (選用) 從 Windows ISO 自訂抽取 sxs
├── README.md
├── Win10_22H2/sxs/                 ← CAB 檔已內建
└── Win11_25H2/sxs/                 ← CAB 檔已內建
```

## 運作原理

Windows 安裝光碟的 `sources\sxs` 資料夾中已有 .NET 3.5 的 CAB 檔！
透過 DISM 指定本機 sxs 路徑即可離線啟用，完全不用連 Windows Update。

`install.bat` 會自動：
- 檢查 .NET 3.5 是否已安裝（已裝則跳過）
- 偵測目前 Windows 10 或 11
- 從對應版本的 sxs 資料夾離線啟用
- 若離線安裝失敗 → 自動 fallback 走 Windows Update

## 內建 sxs 版本

| 資料夾 | 來源 |
|--------|------|
| `Win10_22H2/sxs/` | Windows 10 22H2 (build 19045) |
| `Win11_25H2/sxs/` | Windows 11 25H2 |

> 遇到版本不合時，`install.bat` 會自動轉 Windows Update，不影響安裝。

## Windows 11 26H1 (build 28000) 以上

自 26H1 起，微軟已將 .NET 3.5 從 Windows 選用元件（FoD）移除，**DISM /sxs 與
Windows Update 都無法再安裝**，只能用微軟的獨立安裝器。

`install.bat` 偵測到 build ≥ 28000 時會自動改跑同資料夾內的 `DotNet35Setup.exe`
（靜默 `/passive /norestart`）：

```
NET35-Offline-Installer/
├── install.bat
├── DotNet35Setup.exe   ← 自行從微軟下載放入（約 100MB，repo 不收）
└── ...
```

下載點：<https://go.microsoft.com/fwlink/?LinkID=2337635>
（官方說明與 FAQ：[Install .NET Framework 3.5 on Windows 11](https://learn.microsoft.com/en-us/dotnet/framework/install/dotnet-35-windows-11)）

注意事項：
- 安裝成功後可能要求重新開機（exit code 3010）。
- 26H1 移除了 ASP.NET 3.5 等 IIS 相關元件，IIS 情境需另跑微軟的
  [Enable-ASPNet35.ps1](https://go.microsoft.com/fwlink/?linkid=2348600)。
- Windows 大版本升級後 .NET 3.5 不會保留，需重裝。

## 自訂 sxs（選用）

若想自己準備特定版本的 sxs：

### 從 ISO 手動抽取
1. 下載 Windows ISO（[Win10](https://www.microsoft.com/software-download/windows10) / [Win11](https://www.microsoft.com/software-download/windows11)）
2. 掛載 ISO → 複製 `sources\sxs` 整個資料夾
3. 蓋掉對應的 `Win10_22H2/sxs/` 或 `Win11_25H2/sxs/`

### 用腳本自動抽取
以系統管理員執行 PowerShell：
```powershell
.\build_offline_package.ps1
```
- 自動掃描 `Downloads` 中的 `Win*.iso`
- 自動掛載 → 偵測版本 → 複製 sxs
- 支援 Win10 / Win11 多版本

## 常見問題

**Q: DISM 報錯「找不到來源」？**
A: sxs 版本與 Windows 版本不合，腳本會自動轉 Windows Update 安裝。

**Q: 可以放隨身碟嗎？**
A: 可以。`install.bat` 使用相對路徑，放哪都能跑。

**Q: 為什麼不用微軟的離線安裝包？**
A: 微軟官方 `NDP35.exe` 僅支援舊版 Windows；Windows 10/11 需透過 DISM 啟用功能。

## License

MIT
