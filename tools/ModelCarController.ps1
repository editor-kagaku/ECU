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

$SelectInstance = "busy_diffie"

# フォームを先に作成する
$ControlFrame = New-Object Form
$ControlFrame.Text = "test"
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

#フォーム自身の高さを計算して変数へ格納
$Hform = 450

#フォームのサイズを決定する
$ControlFrame.Size = "750, " + [string]$Hform

#テキストボックスのリストオブジェクトを生成(各テキストを参照する場合は配列内の要素のtextプロパティを参照する)
$txts = New-Object System.Collections.Generic.List[System.Windows.Forms.TextBox]

# ラベルを動的生成するループ
for($i=1; $i -le $Formcnt; $i++) {
    $label = New-Object Label
    $label.Text = $Tlab[$i - 1]
    $label.Name = "Label" + [string]$i
    $label.Font = New-Object Drawing.Font("Meiryo UI",8)
    $label.Location = "20, " + [string]$Hlab
    $label.AutoSize = $True
    $Hlab = $Hlab + 40
    $ControlFrame.Controls.Add($label)
}

# テキストを動的生成するループ
for($j=1; $j -le $Formcnt; $j++) {
    $txt = New-Object TextBox
    $txt.Name = "textbox" + [string]$j
    $txt.Location = "20, " + [string]$Htxt
    $txt.Size = "250, 40"
    $Htxt = $Htxt + 40
    $ControlFrame.Controls.Add($txt)
    $txts.Add($txt)
}

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

# コントローラファイル選択
$ControllerFileSelectBtn = New-Object System.Windows.Forms.Button
$ControllerFileSelectBtn.Text = "Select(Control)"
$ControllerFileSelectBtn.Font = New-Object Drawing.Font("Meiryo UI",8)
$ControllerFileSelectBtn.Size = "80, 37"
$ControllerFileSelectBtn.Location = "20, " + [string]$Hbtn

# ボタンイベント
$ControllerFileSelectBtn_Click = {
    # ファイル選択
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Filter = "mmap(*.bin)|*.*"
    $dialog.InitialDirectory = $global:current_path
    $dialog.Title = "Select mmap file"
    # ダイアログを表示
    if ( $dialog.ShowDialog() -eq "OK" )
    {
        # ［OK］ボタンがクリックされたら、選択されたファイル名（パス）を表示
        $global:ControlFile = $dialog.FileName
    }

    # if ( ( -not [string]::IsNullOrEmpty( $global:ControlFile ) ) -and
    #      ( -not [string]::IsNullOrEmpty( $global:LampFile ) ) -and
    #      ( -not [string]::IsNullOrEmpty( $global:DriveFile ) )
    # )
    # {
    #     $StartBtn.Enabled = $True
    # }
    # else
    # {
    #     $StartBtn.Enabled = $False
    # }
}
$ControllerFileSelectBtn.Add_Click($ControllerFileSelectBtn_Click)

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($ControllerFileSelectBtn)

# スタート
$StartBtn = New-Object System.Windows.Forms.CheckBox
$StartBtn.Text = "Start"
$StartBtn.Font = New-Object Drawing.Font("Meiryo UI",11)
$StartBtn.TextAlign = "MiddleCenter"
$StartBtn.Appearance = "Button"
$StartBtn.FlatStyle = "System"
$StartBtn.Size = "80, 37"
$StartBtn.Location = "20, 350"
$StartBtn.Checked = $False
$StartBtn.Enabled = $True

# ボタンイベント
$StartBtn_CheckedChanged = {
    if ( $StartBtn.Checked -eq $False )
    {
        $global:ControlTimer.Stop()
    }
    else
    {
        $global:ControlTimer.Start()
    }
}
$StartBtn.Add_CheckedChanged($StartBtn_CheckedChanged)

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($StartBtn)

# Accelグループの中のラジオボタンを作る
$global:AccelValue = 64
$AccelBtn_127 = New-Object System.Windows.Forms.RadioButton
$AccelBtn_127.Location = New-Object System.Drawing.Point(20,20)
$AccelBtn_127.size = New-Object System.Drawing.Size(40,30)
$AccelBtn_127_CheckedChanged = {
    $global:AccelValue = 127
}
$AccelBtn_127.Add_CheckedChanged($AccelBtn_127_CheckedChanged)

$AccelBtn_106 = New-Object System.Windows.Forms.RadioButton
$AccelBtn_106.Location = New-Object System.Drawing.Point(20,60)
$AccelBtn_106.size = New-Object System.Drawing.Size(40,30)
$AccelBtn_106_CheckedChanged = {
    $global:AccelValue = 106
}
$AccelBtn_106.Add_CheckedChanged($AccelBtn_106_CheckedChanged)

$AccelBtn_085 = New-Object System.Windows.Forms.RadioButton
$AccelBtn_085.Location = New-Object System.Drawing.Point(20,100)
$AccelBtn_085.size = New-Object System.Drawing.Size(40,30)
$AccelBtn_085_CheckedChanged = {
    $global:AccelValue = 85
}
$AccelBtn_085.Add_CheckedChanged($AccelBtn_085_CheckedChanged)

$AccelBtn_064 = New-Object System.Windows.Forms.RadioButton
$AccelBtn_064.Location = New-Object System.Drawing.Point(20,140)
$AccelBtn_064.size = New-Object System.Drawing.Size(40,30)
$AccelBtn_064.Checked = $True
$AccelBtn_064_CheckedChanged = {
    $global:AccelValue = 64
}
$AccelBtn_064.Add_CheckedChanged($AccelBtn_064_CheckedChanged)

$AccelBtn_000 = New-Object System.Windows.Forms.RadioButton
$AccelBtn_000.Location = New-Object System.Drawing.Point(20,180)
$AccelBtn_000.size = New-Object System.Drawing.Size(40,30)
$AccelBtn_000_CheckedChanged = {
    $global:AccelValue = 0
}
$AccelBtn_000.Add_CheckedChanged($AccelBtn_000_CheckedChanged)

# Accelグループ
$AccelBox = New-Object System.Windows.Forms.GroupBox
$AccelBox.Location = New-Object System.Drawing.Point(530,180)
$AccelBox.size = New-Object System.Drawing.Size(60,220)
$AccelBox.text = "Accel"

# グループにラジオボタンを入れる
$AccelBox.Controls.AddRange(@($AccelBtn_127,$AccelBtn_106,$AccelBtn_085,$AccelBtn_064,$AccelBtn_000))

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($AccelBox)

# Steeringグループの中のラジオボタンを作る
$global:SteeringValue = 63
$SteeringBtn_127 = New-Object System.Windows.Forms.RadioButton
$SteeringBtn_127.Location = New-Object System.Drawing.Point(20,20)
$SteeringBtn_127.size = New-Object System.Drawing.Size(40,30)
$SteeringBtn_127_CheckedChanged = {
    $global:SteeringValue = 127
}
$SteeringBtn_127.Add_CheckedChanged($SteeringBtn_127_CheckedChanged)

$SteeringBtn_095 = New-Object System.Windows.Forms.RadioButton
$SteeringBtn_095.Location = New-Object System.Drawing.Point(60,20)
$SteeringBtn_095.size = New-Object System.Drawing.Size(40,30)
$SteeringBtn_095_CheckedChanged = {
    $global:SteeringValue = 95
}
$SteeringBtn_095.Add_Click($SteeringBtn_095_CheckedChanged)

$SteeringBtn_063 = New-Object System.Windows.Forms.RadioButton
$SteeringBtn_063.Location = New-Object System.Drawing.Point(100,20)
$SteeringBtn_063.size = New-Object System.Drawing.Size(40,30)
$SteeringBtn_063.Checked = $True
$SteeringBtn_063_CheckedChanged = {
    $global:SteeringValue = 63
}
$SteeringBtn_063.Add_CheckedChanged($SteeringBtn_063_CheckedChanged)

$SteeringBtn_031 = New-Object System.Windows.Forms.RadioButton
$SteeringBtn_031.Location = New-Object System.Drawing.Point(140,20)
$SteeringBtn_031.size = New-Object System.Drawing.Size(40,30)
$SteeringBtn_031_CheckedChanged = {
    $global:SteeringValue = 31
}
$SteeringBtn_031.Add_CheckedChanged($SteeringBtn_031_CheckedChanged)

$SteeringBtn_000 = New-Object System.Windows.Forms.RadioButton
$SteeringBtn_000.Location = New-Object System.Drawing.Point(180,20)
$SteeringBtn_000.size = New-Object System.Drawing.Size(40,30)
$SteeringBtn_000_CheckedChanged = {
    $global:SteeringValue = 0
}
$SteeringBtn_000.Add_CheckedChanged($SteeringBtn_000_CheckedChanged)

# Steeringグループ
$SteeringBox = New-Object System.Windows.Forms.GroupBox
$SteeringBox.Location = New-Object System.Drawing.Point(400,110)
$SteeringBox.size = New-Object System.Drawing.Size(220,60)
$SteeringBox.text = "Steering"

# グループにラジオボタンを入れる
$SteeringBox.Controls.AddRange(@($SteeringBtn_127,$SteeringBtn_095,$SteeringBtn_063,$SteeringBtn_031,$SteeringBtn_000))

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($SteeringBox)

# ブレーキ
$BrakeBtn = New-Object System.Windows.Forms.CheckBox
$BrakeBtn.Text = "B"
$BrakeBtn.Font = New-Object Drawing.Font("Meiryo UI",11)
$BrakeBtn.TextAlign = "MiddleCenter"
$BrakeBtn.Appearance = "Button"
$BrakeBtn.FlatStyle = "System"
$BrakeBtn.Size = "40, 120"
$BrakeBtn.Location = "450, 210"

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($BrakeBtn)

# ハザード
$HazardBtn = New-Object System.Windows.Forms.CheckBox
$HazardBtn.Text = "H"
$HazardBtn.Font = New-Object Drawing.Font("Meiryo UI",11)
$HazardBtn.TextAlign = "MiddleCenter"
$HazardBtn.Appearance = "Button"
$HazardBtn.FlatStyle = "System"
$HazardBtn.Size = "40, 40"
$HazardBtn.Location = "490, 10"

#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($HazardBtn)

# フロントランプ
$MainLampBtn = New-Object System.Windows.Forms.CheckBox
$MainLampBtn.Text = "M"
$MainLampBtn.Font = New-Object Drawing.Font("Meiryo UI",11)
$MainLampBtn.TextAlign = "MiddleCenter"
$MainLampBtn.Appearance = "Button"
$MainLampBtn.FlatStyle = "System"
$MainLampBtn.Size = "40, 40"
$MainLampBtn.Location = "560, 10"
#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($MainLampBtn)

# フォグランプ
$SubLampBtn = New-Object System.Windows.Forms.CheckBox
$SubLampBtn.Text = "S"
$SubLampBtn.Font = New-Object Drawing.Font("Meiryo UI",11)
$SubLampBtn.TextAlign = "MiddleCenter"
$SubLampBtn.Appearance = "Button"
$SubLampBtn.FlatStyle = "System"
$SubLampBtn.Size = "40, 40"
$SubLampBtn.Location = "420, 10"
#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($SubLampBtn)

# ウィンカー(右)
$WinkerRightBtn = New-Object System.Windows.Forms.CheckBox
$WinkerRightBtn.Text = "->"
$WinkerRightBtn.Font = New-Object Drawing.Font("Meiryo UI",11)
$WinkerRightBtn.TextAlign = "MiddleCenter"
$WinkerRightBtn.Appearance = "Button"
$WinkerRightBtn.FlatStyle = "System"
$WinkerRightBtn.Size = "40, 40"
$WinkerRightBtn.Location = "560, 70"
#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($WinkerRightBtn)

# ウィンカー(左)
$WinkerLeftBtn = New-Object System.Windows.Forms.CheckBox
$WinkerLeftBtn.Text = "<-"
$WinkerLeftBtn.Font = New-Object Drawing.Font("Meiryo UI",11)
$WinkerLeftBtn.TextAlign = "MiddleCenter"
$WinkerLeftBtn.Appearance = "Button"
$WinkerLeftBtn.FlatStyle = "System"
$WinkerLeftBtn.Size = "40, 40"
$WinkerLeftBtn.Location = "420, 70"
#ボタンの要素をフォームへ加える
$ControlFrame.Controls.Add($WinkerLeftBtn)

# タイマーを作成する
$global:ControlTimer = New-Object System.Windows.Forms.Timer
$global:ControlTimer.Interval = 2000
$global:ControlTimer.Stop()

# タイマーイベント
$ControlTimer_Tick = {
    #[Byte[]]$LampBin = Get-Content $global:LampFile -Encoding Byte
    #[Byte[]]$DriveBin = Get-Content $global:DriveFile -Encoding Byte
    #[Byte[]]$ControlBin = @()
    $ControlBin = @()
    #[Byte[]]$ControlBin = Get-Content $global:ControlFile -Encoding Byte

    # LED + BUZZER
    #$txts[0].Text = $LampBin[32].ToString("X2") + $LampBin[36].ToString("X2") + (Get-Date).ToString("HH:mm:ss.fff")
    #$txts[0].Text = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss.fff")
    $tmpText = (wsl docker exec $SelectInstance bash -c "dd if=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap1.bin bs=1 skip=32 count=1 2>/dev/null | od -x -N1 | head -1")
    #$txts[0].Text = (Get-Date).ToString("HH:mm:ss.fff") + $tmpText
    $txts[0].Text = $tmpText
    $txts[0].invalidate()

    # LAMP
    $tmpText = (wsl docker exec $SelectInstance bash -c "dd if=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap1.bin bs=1 skip=36 count=6 2>/dev/null | od -x -N6 | head -1")
    $txts[1].Text = $tmpText
    $txts[1].invalidate()

    # SERVO
    $tmpText = (wsl docker exec $SelectInstance bash -c "dd if=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap4.bin bs=4 skip=8 count=1 2>/dev/null | od -x -N4 | head -1")
    $txts[2].Text = $tmpText
    $txts[2].invalidate()

    # ESC
    $tmpText = (wsl docker exec $SelectInstance bash -c "dd if=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap4.bin bs=4 skip=10 count=1 2>/dev/null | od -x -N4 | head -1")
    $txts[3].Text = $tmpText
    $txts[3].invalidate()
    
    $Bin = 128
    $CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
    $ControlBin += 128

    if ( $SubLampBtn.Checked -eq $True )
    {
        $Bin = $Bin -bor 1
    }

    if ( $WinkerLeftBtn.Checked -eq $True )
    {
        $Bin = $Bin -bor 2
    }

    if ( $WinkerRightBtn.Checked -eq $True )
    {
        $Bin = $Bin -bor 8
    }

    $CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 seek=1 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
    $ControlBin += $Bin

    $Bin = 0
    if ( $HazardBtn.Checked -eq $True )
    {
        $Bin = $Bin -bor 16
    }

    if ( $BrakeBtn.Checked -eq $True )
    {
        $Bin = $Bin -bor 32
    }

    if ( $MainLampBtn.Checked -eq $True )
    {
        $Bin = $Bin -bor 64
    }

    $CMD = "echo -en '\x" + $Bin.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 seek=2 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
    $ControlBin += $Bin 

    $CMD = "echo -en '\x" + $global:SteeringValue.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 seek=3 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
    $ControlBin += $global:SteeringValue

    $CMD = "echo -en '\x0' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 seek=4 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
    $ControlBin += 0

    $CMD = "echo -en '\x0' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 seek=5 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
    $ControlBin += 0

    $CMD = "echo -en '\x" + $global:AccelValue.ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 seek=6 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD
    $ControlBin += $global:AccelValue

    $ControlBin += (($ControlBin[1] + $ControlBin[2] + $ControlBin[3] + $ControlBin[4] + $ControlBin[5] + $ControlBin[6]) -band 127)
    $CMD = "echo -en '\x" + $ControlBin[7].ToString("X2") + "' | dd of=/root/modelcar/swc-application/1ecu/ecu_cbo/mmap5.bin bs=1 seek=7 count=1 conv=notrunc 2>/dev/null"
    #Write-Host $CMD
    wsl docker exec $SelectInstance bash -c $CMD

    # Write-Host $global:ControlFile $ControlBin.Length
    # $PSDefaultParameterValues['out-file:width'] = 1024
    # Out-File -NoNewline $global:ControlFile -Encoding ascii -InputObject $ControlBin

    # Remove-item -Force $global:LampFile
    # [System.IO.File]::WriteAllBytes( $global:LampFile, $ControlBin )
    #Remove-item -Force $global:ControlFile
    #[System.IO.File]::WriteAllBytes( $global:ControlFile, $ControlBin )
}
$global:ControlTimer.Add_Tick($ControlTimer_Tick)

#フォーム表示
$ControlFrame.ShowDialog()
