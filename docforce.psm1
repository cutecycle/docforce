try {
	Get-Command Get-MarkdownMetadata 
}
catch {
	install-module PlatyPS -Force
}

function Get-ChangedFiles { 
	param ( 
		$file
	) 
	$changedFiles = git diff origin/HEAD --name-only | ForEach-Object { 
		Get-ChildItem $_
	}	
	
	

}

Test-StaleDocument { 
	param ( 
		$file 
	)

	$directory = $file.metadata.relevantDirectory 
	$stale = (git diff origin/HEAD --name-only ) -contains $file
	
	
	return $inDiff

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
	$list 
}
function Get-StaleDocuments {
	$files = Get-MarkdownFiles
	$files | ForEach-Object -Parallel {
		Test-StaleDocument $_
	}
	
}

Export-ModuleMember -function Get-StaleDocuments