param(
	[Parameter(Position=0)]
	$ProjectFilePath,
	[Parameter(Position=1)]
	$Version,
	[Parameter(Position=2)]
	$IsBeta,
	[Parameter(Position=3)]
	$PackageSource,
	[Parameter(Position=4)]
	$ApiKey,
	[Parameter(Position=5)]
	$OutputPath
)

Set-Location $OutputPath

$libraryName = "WindsorWebApiDependency"

$packageVerions = $Version
if($IsBeta){
	$latestPackage =  nuget list -prerelease -source  $PackageSource $libraryName
	$betaNumber = "1"
	if($latestPackage -eq 'No packages found.'){
		Write-Host "No packages found for the assembly - This will be first."
	}
	else{
		if($latestPackage -like "*-beta*"){
			$packageSplitByVersion = $latestPackage -split "-beta"
			$currentBetaVersion = [convert]::ToInt32($packageSplitByVersion[1],10)
			Write-Host "Current Beta version $currentBetaVersion"
			$betaNumber = [convert]::ToString($currentBetaVersion + 1);
			Write-Host "Updating beta version to: $betaNumber"
		}
		else{
			Write-Host "No beta versions found.  Beta=1"
		}
	}
	$packageVerions = $Version + "-beta" + $betaNumber
	nuget pack $ProjectFilePath -IncludeReferencedProjects -Version $packageVerions -Suffix "beta$betaNumber"
	
}
else{
	nuget pack $ProjectFilePath -IncludeReferencedProjects -Version $packageVerions
}

$fullPackageName = "$libraryName.$packageVerions.nupkg"
Write-Host "Pushing $fullPackageName to $PackageSource"
nuget push $fullPackageName -Source $PackageSource -ApiKey $ApiKey
