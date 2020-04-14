enum CameraCode {
	XP60
	D3000
	WP
	iOS
};

function Get-CodeText([CameraCode]$CodeEnum) {
	if ($CodeEnum -eq [CameraCode]::XP60) {
		return 'xp60';
	}
	if ($CodeEnum -eq [CameraCode]::D3000) {
		return 'd3000';
	}
	if ($CodeEnum -eq [CameraCode]::WP) {
		return 'WP';
	}
	if ($CodeEnum -eq [CameraCode]::iOS) {
		return 'iOS';
	}
	return 'unknown';
}

function Get-PhotoCreateTime([string]$FileInit, [string]$FileExt = 'jpg') {
	Get-Item ".\${FileInit}*.$FileExt" | select LastWriteTime
}

function Rename-Photos([string]$FileInit, [CameraCode]$Camera) {
	Rename-CameraArtefact($FileInit, 'jpg', $Camera);
}

function Rename-Videos([string]$FileInit, [CameraCode]$Camera) {
	Rename-CameraArtefact($FileInit, 'mov', $Camera);
}

function Get-NewFilename([string]$FileInit, [string]$FileExt, [CameraCode]$Camera, [Boolean]$IncludeSerialNumber = $true) {
	$cameraCodeText = Get-CodeText $Camera

	Get-Item ".\${FileInit}*.$FileExt" | % {
		[System.IO.FileInfo]$file = $_;
		[string]$snum = $file.BaseName;
		[datetime]$created = $file.LastWriteTime;
		$newName = $created.ToString('yyyyMMdd_HHmmssfff');
		if ($FileInit.Length -gt 0) {
			$snum = $file.BaseName.Replace($FileInit,'');
		}
		if ($IncludeSerialNumber) {
			$newName = "${newName}_${snum}_$cameraCodeText.$FileExt";
		} else {
			$newName = "${newName}_$cameraCodeText.$FileExt";
		}
		Write-Output (New-Object -TypeName PSObject -Property @{old=$file.Name; new=$newName});
	}
}

function Rename-CameraArtefact([string]$FileInit,
							   [string]$FileExt,
							   [CameraCode]$Camera,
							   [Boolean]$IncludeSerialNumber = $true)
{
	Get-NewFilename -FileInit $FileInit `
			-FileExt $FileExt `
			-Camera $Camera `
			-IncludeSerialNumber $IncludeSerialNumber | ? {
		$new = $_.new;
		$new -like '20*'
	} | % {
		Move-Item -LiteralPath $_.old -Destination $_.new
	}
}
