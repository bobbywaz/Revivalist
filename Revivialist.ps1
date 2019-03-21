# Set these variable
# Set $folder to recursively search
param ( 
	$Folder = "T:\TV", 
	# Leave $oldformat blank for all files
	$oldformat = ".avi",
	$newformat = ".mp4",
	# Do you want x264 or x265 video?
	$codec = "h264_nvenc",
	$RemoveOldFile = $true,
	$Resolution
)
# That's it! Just run it



Clear-Host
Write-Host "======================================================================="
Write-Host "====================  Welcome to Converter  ==========================="
Write-Host "======================================================================="
$allfiles = $Folder + "*" + $oldformat
get-childitem -r $allfiles | foreach-object {
	$oldname = $_.Name
	$newname = $_.basename + $newformat
     Write-Host "========================================================" (get-date).ToString('T') "==="
	 Write-Host "====================  Convert to $oldformat to $newformat  ========================"
	 Write-Host "=======================================================================" `n
	 if ($newname -eq $oldname) {
		Write-Host  'File: ' -NoNewline; Write-Host -BackgroundColor black -ForegroundColor red $newname -NoNewline; Write-Host -backgroundcolor black -ForegroundColor white ' already exists, skipping'; Add-Content $PSScriptRoot\Duplicates.txt "$oldname already exists"
		continue
		}
	 Write-Host -BackgroundColor black -ForegroundColor Yellow $_.Name `n `n "is now going to be converted to" `n `n $newname `n
	 Write-Host "======================================================================="
	 Set-Location $_.DirectoryName
	 #encode to easily streamable with dynamic range compression https://www.mrlovenstein.com/comic/87
	 $ffmpegparams = "-hide_banner -y -i $_ -vcodec $codec -preset slow -level 4.1 -af dynaudnorm -acodec aac -movflags faststart $newname"
	 if (Get-Command ffmpeg-bar) {
		 ffmpeg-bar $ffmpegparams
		}
	 else {
		 ffmpeg $ffmpegparams
		}
	 if ($RemoveOldFile -eq $true) {
		if ((Test-Path $newname) -and ((Get-Item $newname).length -gt 0kb) -and ($lastexitcode = "0") -and ($RemoveOldFile = $true))	{
			try {
				Remove-Item $_.FullName -Force -ErrorAction Stop
				Write-Host "======================================================================="
				Write-Host "============================ File Removed ============================="
			}
			catch {
			Write-Host "Can not remove item " $oldname " `n "Check file permissions"
			}
		}
	}
}
Write-Host "`n `nSEE YOU SPACE COWBOY... `n"