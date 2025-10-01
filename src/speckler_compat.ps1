<#
  .SYNOPSIS
  Fun with colors in Powershell.
  .DESCRIPTION
  Color tv static style fun in the Powershell command line. Similar to my old ColorStatic C++ program.
  Speckler in C++ coming soon.
  .PARAMETER MinWidth
  Minimum width of each color square.
  .PARAMETER MaxWidth
  Maximum width of each color square.
  .PARAMETER Sleep
  Delay between each iteration, Defaults to 0.
  .EXAMPLE
  speckler -MinWidth 1 -MaxWidth 1
  .EXAMPLE
  speckler # of course
  .EXAMPLE
  $width = ($Host.UI.RawUI.WindowSize.Width / 4)
  speckler -MaxWidth $width
#>
param(
  [ValidateScript({ ($_ -ge 1) -and ($_ -le $Host.UI.RawUI.WindowSize.Width) })]
  [Int]$MaxWidth = $Host.UI.RawUI.WindowSize.Width,
  [ValidateScript({ ($_ -ge 1) -and ($_ -le $Host.UI.RawUI.WindowSize.Width) })]
  [Int]$MinWidth = 1,
  [ValidateScript({ $_ -gt 0 })]
  [Int]$Sleep = 0
)
# ╔═══════════╗
# ║ Functions ║
# ╚═══════════╝
function Validate8Bit { param([Int]$Value); return $Value -ge 0x0 -and $Value -le 0xff; }
function Validate24Bit { param([Int]$Value); return $Value -ge 0x0 -and $Value -le 0xffffff; }
function ColorSquare {
  param(
    [ValidateScript({ Validate24Bit -Value $_ })][Int]$Value = 0xffffff,
    [ValidateScript({ Validate8Bit -Value $_ })][Int]$Red = -1,
    [ValidateScript({ Validate8Bit -Value $_ })][Int]$Green = -1,
    [ValidateScript({ Validate8Bit -Value $_ })][Int]$Blue = -1,
    [ValidateScript({ $_ -gt 0 -and $_ -le $Host.UI.RawUI.WindowSize.Width })]
    [Int]$Width = 2,
    [Switch]$Output
  )
  $spaces = ' ' * $Width
  $rgb = @{}
  switch (($Red -gt -1) -or ($Green -gt -1) -or ($Blue -gt -1)) {
    $true {
      $rgb.red = if ($Red -gt -1) { $Red.ToString() } else { '0' }
      $rgb.green = if ($Green -gt -1) { $Green.ToString() } else { '0' }
      $rgb.blue = if ($Blue -gt -1) { $Blue.ToString() } else { '0' }
    }
    default {
      $rgb.red = (($Value -shr 0x10) -band 0xff).ToString()
      $rgb.green = (($Value -shr 0x8) -band 0xff).ToString()
      $rgb.blue = (($Value -shr 0x0) -band 0xff).ToString()     
    }
  }
  $out = "$escape[48;2;" + $rgb.red + ";" + $rgb.green + ";" + $rgb.blue + "m" + $spaces + "$escape[m"
  switch ($Output) {
    $true { Write-Output($out) }
    default { Write-Host($out) }
  }
}
$escape = [char]27
if ($MinWidth -gt $MaxWidth) {
  Write-Error "MinWidth [$MinWidth] can not be greater the MaxWidth [$MaxWidth]."
  return
}
while ($true){
  $Width = switch ($MinWidth -ne $MaxWidth) {
    $true { Get-Random -Minimum $MinWidth -Maximum $MaxWidth }
    default { $MinWidth }
  }
  [console]::SetCursorPosition(
    $(Get-Random -Minimum 0 -Maximum $($Host.UI.RawUI.WindowSize.Width - $Width)),
    $(Get-Random -Minimum 0 -Maximum $($Host.UI.RawUI.WindowSize.Height - 1))
  )
  ColorSquare -Value $(Get-Random -Minimum 0x000000 -Maximum 0xffffff) -Width $Width
  if ($Sleep -gt 0){
    Start-Sleep -Milliseconds $Sleep
  }
}