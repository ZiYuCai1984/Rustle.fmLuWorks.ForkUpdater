Set-Location -Path $PSScriptRoot
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'



function update-fork {
    param ($repo, $folderName, $remoteRepo, $branch)
git clone $repo -b $branch
cd $folderName
git remote add upstream $remoteRepo
git pull --all
git checkout $branch
git rebase upstream/$branch
git push
cd ..
}


function get-repo-url{
    param($clone_url)
    return "https://" + $env:TOKEN_AUTO_PUSH + "@" + $clone_url.remove(0,8)
}



git config --global user.email yucaizi1984@gmail.com
git config --global user.name $env:GITHUB_ACTOR


$repos_raw = Invoke-WebRequest -Uri "https://api.github.com/users/$env:GITHUB_ACTOR/repos"



$repos = $repos_raw | ConvertFrom-Json


for($i=0;$i -le $repos.Length;++$i)
{
    if($repos[$i].fork)
    {
       $repo_detail_raw = Invoke-WebRequest -Uri $repos[$i].url
       $repo_detail = $repo_detail_raw | ConvertFrom-Json

       $clone_url = get-repo-url $repo_detail.clone_url
       $folderName = $repo_detail.name

       update-fork $clone_url $folderName $repo_detail.parent.clone_url $repos[$i].default_branch

    }
}



