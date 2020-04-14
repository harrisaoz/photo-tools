param (
    [string]$DefaultSourceDirName = 'o:\OneDrive\Favourites\Pictures\Camera Roll',
    [string]$DefaultTargetDirName = 'o:\OneDrive\Favourites\Pictures\Camera Roll'
);

[System.IO.DirectoryInfo]$DefaultSourceDir = Get-Item -LiteralPath $DefaultSourceDirName;
[System.IO.DirectoryInfo]$DefaultTargetDir = Get-Item -LiteralPath $DefaultTargetDirName;

function Format-NumberAsMonth([int32]$MonthNumber) {
    return ("{0:d2}" -f $MonthNumber);
}

function Test-MonthFolderMissing([string]$Year, [string]$Month) {
    return !(Test-Path "${Year}/${Month}");
}

function New-SubFolder([System.IO.DirectoryInfo]$ParentDir, [string]$SubDirName) {
    if ((Test-Path -PathType Container $ParentDir)) {
        [string]$ParentDirFullName = $ParentDir.FullName;
        [string]$SubDirFullName = Join-Path -Path $ParentDirFullName -ChildPath $SubDirName;
        Write-Host -ForegroundColor Cyan "Creating Folder: $SubDirFullName";
        if (!(Test-Path -PathType Container -LiteralPath $SubDirFullName)) {
            Write-Output (New-Item -ItemType Directory -Path $SubDirFullName -ErrorAction Inquire);
            Write-Host -ForegroundColor Green -Object "Created Folder: $SubDirFullName";
        } else {
            Write-Output (Get-Item -LiteralPath $SubDirFullName);
            Write-Host -ForegroundColor Green -Object "Folder exists: $SubDirFullName";
        }
    }
}

function New-MonthFolders([string]$Year, [System.IO.DirectoryInfo]$TargetDir = $DefaultTargetDir) {
    $YearFolder = New-SubFolder -ParentDir $TargetDir -SubDirName $Year
    Write-Host -ForegroundColor Blue -Object 'Creating month folders...'
    1..12 | % {
        $month = $_;
        return New-SubFolder -ParentDir $YearFolder -SubDirName (Format-NumberAsMonth($month));
    }
}

function Move-FilesFromYear([string]$Year,
                            [System.IO.DirectoryInfo]$SourceDir = $DefaultSourceDir,
                            [System.IO.DirectoryInfo]$TargetDir = $DefaultTargetDir,
                            [string]$FilenameMatchExpression = '{0}{1}*')
{
    $monthFolders = New-MonthFolders -Year $Year -TargetDir $TargetDir;
    $monthFolders | % {
        $monthDir = [System.IO.DirectoryInfo]$_;
        $monthLabel = $monthDir.Name;
        Write-Host "Preparing to move files to folder: $monthLabel";
        $searchPattern = $FilenameMatchExpression -f $Year,$monthLabel
        $sourcePathExpression = Join-Path -Path ($SourceDir.FullName) -ChildPath $searchPattern
        Write-Output (Move-Item -Path $sourcePathExpression -Destination $monthDir -ErrorAction Inquire);
    }
}
