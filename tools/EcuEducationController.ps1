using namespace System.Windows.Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[Application]::EnableVisualStyles()

#文字コードをUTF-8
chcp 65001

# 管理者権限取得
if (
    -Not
    (
        [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
)
{
        if (
                [int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000
            )
        {
            Start-Process PowerShell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath';`"";
            Exit;
        }
}

#実行中のパス取得
$path = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $path

$global:current_path = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $global:current_path

$SelectInstance = "modelcar"

# フォームを先に作成する
$ControlFrame = New-Object Form
$ControlFrame.Text = "Controller for ECU Education"
# $ControlFrame.Text = $Args[2]

#テキストボックスの数を決定する変数（2未満にはならず、最大5）
$Formcnt = 4
# $Formcnt = [int]$Args[1]

#ラベルの名称配列 文字は「,」区切りで受ける
$Tlab = @('One','Two','Three','Four')
# $Tlab = $Args[3].Split(",")

#ラベルの初期高さを変数へ格納
$Hlab = 120

#テキストボックスの初期高さを変数へ格納
$Htxt = 140

#ボタンの高さを計算して変数へ格納
$Hbtn = 20

#フォームのサイズを決定する
$ControlFrame.Size = "400, 280"

# ボタン
$DswBtn = New-Object System.Windows.Forms.CheckBox
$DswBtn.Text = "DipSW OFF"
$DswBtn.Checked = $False
$DswBtn.Font = New-Object Drawing.Font("Meiryo UI",8)
$DswBtn.Size = "80, 37"
$DswBtn.Location = "220, " + [string]$Hbtn
$DswBtn.TextAlign = "MiddleCenter"
$DswBtn.Appearance = "Button"
$DswBtn.FlatStyle = "System"

$global:toggle = 0

# ボタンイベント
$DswBtn_Click = {
    if ( $DswBtn.Checked -eq $False )
    {
        $DswBtn.Text = "DipSW OFF"
        $Bin = 128
    }
    else
    {
        $DswBtn.Text = "DipSW ON"
        $Bin = 0
    }
    $CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap1.bin bs=1 seek=512 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
}
$DswBtn.Add_Click($DswBtn_Click)

$Bin = 128
$CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap1.bin bs=1 seek=512 count=1 conv=notrunc 2>/dev/null"
#Write-Host $CMD
wsl docker exec $SelectInstance bash -c $CMD

$Bin = 7
$CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap1.bin bs=1 seek=513 count=1 conv=notrunc 2>/dev/null"
#Write-Host $CMD
wsl docker exec $SelectInstance bash -c $CMD

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($DswBtn)

# ボタン
$PswBtn = New-Object System.Windows.Forms.CheckBox
$PswBtn.Text = "PushSW OFF"
$PswBtn.Checked = $False
$PswBtn.Font = New-Object Drawing.Font("Meiryo UI",8)
$PswBtn.Size = "80, 37"
$PswBtn.Location = "120, " + [string]$Hbtn
$PswBtn.TextAlign = "MiddleCenter"
$PswBtn.Appearance = "Button"
$PswBtn.FlatStyle = "System"

# ボタンイベント
$PswBtn_Click = {
    if ( $PswBtn.Checked -eq $False )
    {
        $PswBtn.Text = "PushSW OFF"
        $Bin = 3
    }
    else
    {
        $PswBtn.Text = "PushSW ON"  
        $Bin = 0
    }
    $CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap1.bin bs=1 seek=544 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
}
$PswBtn.Add_Click($PswBtn_Click)

$Bin = 3
$CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap1.bin bs=1 seek=544 count=1 conv=notrunc 2>/dev/null"
#Write-Host $CMD
wsl docker exec $SelectInstance bash -c $CMD

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($PswBtn)

# ネットワーク選択
$NetworkSelectBtn = New-Object System.Windows.Forms.CheckBox
$NetworkSelectBtn.Text = "1 ECU"
$NetworkSelectBtn.Font = New-Object Drawing.Font("Meiryo UI",8)
$NetworkSelectBtn.Size = "80, 37"
$NetworkSelectBtn.Location = "20, " + [string]$Hbtn
$NetworkSelectBtn.TextAlign = "MiddleCenter"
$NetworkSelectBtn.Appearance = "Button"
$NetworkSelectBtn.FlatStyle = "System"
$NetworkSelectBtn.Checked = $False
$NetworkSelectBtn.Enabled = $True

# ボタンイベント
$NetworkSelectBtn_Click = {
    if ( $NetworkSelectBtn.Checked -eq $False )
    {
        $NetworkSelectBtn.Text = "1 ECU"
#        $global:ControlTimer.Stop()
    }
    else
    {
        $NetworkSelectBtn.Text = "2 ECUs"
#        $global:ControlTimer.Start()
    }
}
$NetworkSelectBtn.Add_Click($NetworkSelectBtn_Click)

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($NetworkSelectBtn)

# 接続ボタン
$StartBtn = New-Object System.Windows.Forms.CheckBox
$StartBtn.Text = "Stopped"
$StartBtn.Font = New-Object Drawing.Font("Meiryo UI",8)
$StartBtn.TextAlign = "MiddleCenter"
$StartBtn.Appearance = "Button"
$StartBtn.FlatStyle = "System"
$StartBtn.Size = "80, 37"
$StartBtn.Location = "20, 180"
$StartBtn.Checked = $False
$StartBtn.Enabled = $True

# ボタンイベント
$StartBtn_CheckedChanged = {
    if ( $StartBtn.Checked -eq $False )
    {
        $StartBtn.Text = "Stopping"
#        $global:ControlTimer.Stop()
    }
    else
    {
        $StartBtn.Text = "Executing"
#        $global:ControlTimer.Start()
    }
}
$StartBtn.Add_CheckedChanged($StartBtn_CheckedChanged)

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($StartBtn)

# LedStatusグループの中のラジオボタンを作る
$LedStatus_1 = New-Object System.Windows.Forms.RadioButton
$LedStatus_1.Location = New-Object System.Drawing.Point(20,20)
$LedStatus_1.size = New-Object System.Drawing.Size(40,30)

$LedStatus_2 = New-Object System.Windows.Forms.RadioButton
$LedStatus_2.Location = New-Object System.Drawing.Point(60,20)
$LedStatus_2.size = New-Object System.Drawing.Size(40,30)

$LedStatus_3 = New-Object System.Windows.Forms.RadioButton
$LedStatus_3.Location = New-Object System.Drawing.Point(100,20)
$LedStatus_3.size = New-Object System.Drawing.Size(40,30)
$LedStatus_3.Checked = $True

$LedStatus_4 = New-Object System.Windows.Forms.RadioButton
$LedStatus_4.Location = New-Object System.Drawing.Point(140,20)
$LedStatus_4.size = New-Object System.Drawing.Size(40,30)

# LedStatusグループ
$LedStatusBox = New-Object System.Windows.Forms.GroupBox
$LedStatusBox.Location = New-Object System.Drawing.Point(20,90)
$LedStatusBox.size = New-Object System.Drawing.Size(220,60)
$LedStatusBox.text = "LedStatus"

# グループにラジオボタンを入れる
$LedStatusBox.Controls.AddRange(@($LedStatus_1,$LedStatus_2,$LedStatus_3,$LedStatus_4))

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($LedStatusBox)

# タイマーを作成する
$global:ControlTimer = New-Object System.Windows.Forms.Timer
$global:ControlTimer.Interval = 2000
$global:ControlTimer.Stop()

# タイマーイベント
$ControlTimer_Tick = {
}
$global:ControlTimer.Add_Tick($ControlTimer_Tick)

#フォーム表示
$ControlFrame.ShowDialog()
