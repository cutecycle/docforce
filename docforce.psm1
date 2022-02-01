try {
	Get-Command Get-MarkdownMetadata 
}
catch {
	install-module PlatyPS -Force
}
# hello m8
function Get-ChangedFiles { 
	param ( 
		$file
	) 
	$changedFiles = git diff --name-only | ForEach-Object { 
		Get-ChildItem $_
	}	
	
	

}

function Test-StaleDocument { 
	param ( 
		$file 
	)
	try { 
		$directory = $file.metadata.relevantDirectory 
		$files = (git diff  --name-only ) | foreach-object { 
		(Get-childitem $_).Directory
		}
		$stale = ($files | Where-Object { 
		(Get-ChildItem $file.path).Directory.Name -eq $_.Name
			}).length -gt 0
	}
	catch {
		$stale = $true
	}
	return $stale

}
function Get-MarkdownFiles { 
	$markdowns = Get-ChildItem -Recurse -Filter "*.md"

	$list = $markdowns | ForEach-Object -Parallel { 
		@{ 
			"path"   = $_.FullName; 
			"name"   = $_.Name; 
			"title"  = $_.Name.Replace(".md", ""); 
			metadata = Get-MarkdownMetadata -Path $_.FullName;
		}
	}
	$unmanagedFiles = $list | Where-Object { 
		$null -eq $_.metadata.relevantDirectory 
	}
	if($unmanagedFiles.length -gt 0) { 
		throw "The following files do not have the relevantDirectory Metadata: $($unmanagedFiles | ForEach-Object { $_.path })";
	}
	$list 
}
function Get-StaleDocuments {
	$files = Get-MarkdownFiles
	$stales = $files | ForEach-Object {
		
		if (Test-StaleDocument $_) {
			$_
		}
		
	}
	if ($stales.length -gt 0) {
		$stales
		throw("Stale documents found")

	}
}

function Get-StaleDocuments-WithoutGit { 
	$markdowns = Get-ChildItem -Recurse -Filter "*.md"
	$withMetadata = $markdowns | ForEach-Object -Parallel { 
		@{ 
			"path"   = $_.FullName; 
			"name"   = $_.Name; 
			"title"  = $_.Name.Replace(".md", ""); 
			metadata = Get-MarkdownMetadata -Path $_.FullName;
		}
	}
	# if the date of the markdown file is older than the date of the relevant directory, then it is stale
	$stales = $withMetadata | Where-Object { 
		(Get-Item $relevantDirectory).LastWriteTime -gt $_.metadata.lastModified
	}

}
function Get-StaleDocuments-AcrossBranch { 
	$markdowns = Get-ChildItem -Recurse -Filter "*.md"
	$withMetadata = $markdowns | ForEach-Object -Parallel { 
		@{ 
			"path"   = $_.FullName; 
			"name"   = $_.Name; 
			"title"  = $_.Name.Replace(".md", ""); 
			metadata = Get-MarkdownMetadata -Path $_.FullName;
		}
	}
	# if the date of the markdown file is older than the date of the relevant directory, then it is stale
	$stales = $withMetadata | Where-Object { 
		(Get-Item $relevantDirectory).LastWriteTime -gt $_.metadata.lastModified
	}

}
function Get-StaleDocuments-SuperSimple { 
	$markdowns = Get-ChildItem -Recurse -Filter "*.md"	
	#if last modified date is more than two weeks old, then it might be stale
	$stales = $markdowns | Where-Object { 
		(Get-Item $_).LastWriteTime -lt (Get-Date).AddDays(-14)
	}
	$stales
}
Export-ModuleMember -function Get-StaleDocuments
Export-ModuleMember -function Get-StaleDocuments-SuperSimple