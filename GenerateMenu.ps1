cd "D:\GIT\LELRanks"
$tourneys = gci .\web\*.html
$archive_tourneys = gci .\web\Archive\*.html
$tourney_data = @()
$archive_tourney_data = @()

"here2" | Out-File D:\GIT\LELRanks\test.txt -Append 

ForEach($tourney in $tourneys) {
    $name = $tourney.Name
    $tourney_object = New-Object PSObject
    $tourney_object | Add-Member -MemberType NoteProperty -Name "Name" -Value "<a href=`"https://cmcaul03.github.io/LELRanks/web/$name`">$name</a>"  -Force
    $tourney_data += $tourney_object
}

ForEach($tourney in $archive_tourneys) {
    $name = $tourney.Name
    $archive_tourney_object = New-Object PSObject
    $archive_tourney_object| Add-Member -MemberType NoteProperty -Name "Name" -Value "<a href=`"https://cmcaul03.github.io/LELRanks/web/archive/$name`">$name</a>"  -Force
    $archive_tourney_data += $archive_tourney_object
}

$Time = Get-Date
$Time = $Time.ToUniversalTime()

 $head = @"
    <style>
    table {
        border-collapse: collapse;
        margin: 25px 0;
        font-size: 0.9em;
        font-family: sans-serif;
        min-width: 400px;
        box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
        width: 80%;
        padding-left: 10%;
        margin-left: 10%;
    }

    p {
        border-collapse: collapse;
        margin: 25px 0;
        font-size: 0.9em;
        font-family: sans-serif;
        padding-left: 10%;
    }


    tbody tr th {
        background-color: #009879;
        color: #ffffff;
        text-align: left;
    }

    th,
    td {
        padding: 12px 15px;
    }

    tbody tr {
        border-bottom: 1px solid #dddddd;
    }

    tbody tr:nth-of-type(even) {
        background-color: #f3f3f3;
    }

    tbody tr:last-of-type {
        border-bottom: 2px solid #009879;
    }
    </style>
    <p>Last updated at: $time UTC. <a href="http://risingempires.cammcauliffe.com">Shit Menu</a>
"@

Add-Type -AssemblyName System.Web

$tourneys_html = $tourney_data | ConvertTo-Html "Name" -Head ($head + "</p>")
[System.Web.HttpUtility]::HtmlDecode($tourneys_html) |  Out-File ".\index.html"

$archive_tourneys_html = $archive_tourney_data | ConvertTo-Html "Name" -Head ($head + "</p>")
[System.Web.HttpUtility]::HtmlDecode($archive_tourneys_html) |  Out-File ".\web\archive.html"

git add * | Out-File D:\GIT\LELRanks\test.txt -Append 
git commit --message "Autoupdate" | Out-File D:\GIT\LELRanks\test.txt -Append 
git push | Out-File D:\GIT\LELRanks\test.txt -Append 