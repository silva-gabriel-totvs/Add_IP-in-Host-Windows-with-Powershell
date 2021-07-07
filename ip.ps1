$Global:Current_Folder = split-path $MyInvocation.MyCommand.Path

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadFrom("MahApps.Metro.dll")       				| out-null
[System.Reflection.Assembly]::LoadFrom("MahApps.Metro.IconPacks.dll")      | out-null

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml("$Current_Folder\ip.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

[System.Windows.Forms.Application]::EnableVisualStyles()

$dialgResultIP = $form.FindName("dialgResultIP")
$dialgResultDNS = $form.FindName("dialgResultDNS")
$btnOpenDialg = $form.FindName("btnOpenDialg")
$btnCloseDialg = $form.FindName("btnCloseDialg")
$showResult = $form.FindName("showResult")
$Automatico = $form.FindName("Automatico")
$Manual = $form.FindName("Manual")
$btnOpenHostWin = $form.FindName("btnOpenHostWin")
$btnOpenBrowerPlataforma = $form.FindName("btnOpenBrowerPlataforma")
$btnOpenBrowerTradicional = $form.FindName("btnOpenBrowerTradicional")
$openPorta = $form.FindName("openPorta")
$openDnsWeb = $form.FindName("openDnsWeb")

$btnOpenDialg.Add_Click({
    $BoxIP = Get-CimInstance -Class Win32_PingStatus -Filter "Address='127.0.0.1'" | Select-Object -Property Destination,IPV4Address,IPV6Address
    $dialgResultIP.Text = $BoxIP.IPV4Address.IPAddressToString
    $ipshow = $BoxIP.IPV4Address.IPAddressToString
})

$Automatico.Add_Checked({

            $btnOpenDialg.IsEnabled = $true
            $Manual.IsChecked = $false
            $dialgResultIP.IsEnabled = $false
            $dialgResultIP.Text = $null

})

$Manual.Add_Checked({
  
            $btnOpenDialg.IsEnabled = $false
            $Automatico.IsChecked = $false
            $dialgResultIP.IsEnabled = $true
            $dialgResultIP.Text = $null
            $dialgResultIP.Text

})

$btnCloseDialg.Add_Click({

   if(!([string]::IsNullOrEmpty(($dialgResultDNS.Text.ToString())))) {
            $BoxIP = Get-CimInstance -Class Win32_PingStatus -Filter "Address='127.0.0.1'" | Select-Object -Property Destination,IPV4Address,IPV6Address
            Add-Content -Path "C:\Windows\System32\drivers\etc\hosts" -Value ("$($dialgResultIP.Text)       $($dialgResultDNS.Text)")

            $showResult.Content = "Dados salvos com sucesso!"
            $showResult.Foreground = "Green"
        } else {
         $showResult.Content = "Erro ao salvar!"
         $showResult.Foreground = "Red"
        }
})

$btnOpenHostWin.Add_Click({
    $FileLocation = 'C:\Windows\System32\drivers\etc\hosts'
    Start-Process notepad $FileLocation
})

$btnOpenBrowerPlataforma.Add_Click({
            Start-Process ("https://" + $openDnsWeb.Text + ":" + $openPorta.Text + "/api/swagger/ui/index")
    
})

$btnOpenBrowerTradicional.Add_Click({
            Start-Process ("http://" + $openDnsWeb.Text + ":" + $openPorta.Text + "/api/swagger/ui/index")
    
})

$Form.ShowDialog() | Out-Null