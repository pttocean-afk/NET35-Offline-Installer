========================================
  .NET Framework 3.5 離線安裝包
  使用說明
========================================

【 原理 】
  Windows 安裝光碟裡的 sources\sxs 資料夾就有 .NET 3.5 CAB 檔
  DISM 直接吃本機來源不用連 Windows Update（原本要等超久）

【 檔案結構 】
  D:\NET35_Offline\
  ├── install.bat          ← 點兩下執行
  ├── README.txt           ← 這份說明
  ├── Win10_22H2\
  │   └── sxs\             ← 從 Win10 22H2 ISO 抽取
  └── Win11_25H2\
      └── sxs\             ← 從 Win11 25H2 ISO 抽取

  目錄命名規則：Win10_{版本} 或 Win11_{版本} (如 Win10_22H2、Win11_23H2、Win11_25H2)
  只要 sxs 資料夾存在，install.bat 就會自動找到並使用。

【 如何取得 sxs 】

  方法一：從 Windows ISO 抽取（建議）
    1. 到微軟官網下載 Windows ISO：
       Win10: https://www.microsoft.com/software-download/windows10
       Win11: https://www.microsoft.com/software-download/windows11
       （用「下載光碟映像(ISO)」選項，不要用「建立安裝媒體」）
    2. 對 ISO 點右鍵 → 掛載（或直接點兩下）
    3. 複製 sources\sxs 整個資料夾
    4. 貼到對應的版本目錄下

  方法二：用 UUP dump（取得特定版本）
    1. 到 https://uupdump.net/
    2. 搜尋你要的 Windows 版本
    3. 下載腳本，執行後會自動產生 ISO
    4. 從 ISO 抽取 sxs

【 需要準備哪些版本 】

  只準備各一條就夠（向下相容）：
  ┌────────────┬──────────────────┐
  │ Windows 10 │ 22H2 (最終版)    │
  ├────────────┼──────────────────┤
  │ Windows 11 │ 最新版 (如 25H2) │
  └────────────┴──────────────────┘

  遇到版本不合時會自動走 Windows Update，不影響安裝。

【 離線包大小 】

  每個 sxs 約 200~300MB（只有 .NET 3.5 的部分）

【 執行方式 】

  對 install.bat 點兩下（需管理員權限）
  或右鍵 → 以系統管理員身分執行

【 常見問題 】

  Q: DISM 報錯「找不到來源」
  A: sxs 版本跟 Windows 不合，會自動轉 Windows Update

  Q: 可以放隨身碟嗎？
  A: 可以。install.bat 會用相對路徑，放在哪裡都能跑

  Q: 為什麼不用 NDP35.exe？
  A: 那個離線安裝包只支援 .NET 3.5 SP1 在舊 Windows 上
     在 Win10/11 上還是要透過 DISM 啟用功能才能裝

========================================
  最後更新: 2026-07-02
========================================
