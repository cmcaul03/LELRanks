$StartGG_URI = "https://api.start.gg/gql/alpha"
$current_path = split-path -parent $MyInvocation.MyCommand.Definition


Function Get-CurrentTournamentList () {
    $tourneys = Invoke-WebRequest -Headers @{"Cache-Control"="no-cache"} "https://raw.githubusercontent.com/cmcaul03/LELRanks/main/current-tourney?raw=true"
    $tourneys = $tourneys.content
    Return $tourneys
}

Function Get-AllTournamentList () {
    Return (gc "$current_path\all-tourneys.txt")
}

Function Get-StartGGCredential () {
    Return (gc "C:\StartGG_cred.txt")
}

Function Get-TournamentDetails ($cred, $tourneys) {

    $headers = @{Authorization="Bearer $cred"}

    $query = '
    query tournament($slug: String) {
    tournament(slug: $slug) {
    id
    name
    events {
        name
        id
        checkInEnabled
        checkInDuration
        startAt
        entrants {
        nodes {
            name
            initialSeedNum
            id
            isDisqualified
            standing {
                id
                placement
            }
            participants {
            id
            gamerTag
            } 
        }
        }
        sets {
        nodes {
            setGamesType
		    totalGames
            round
        }
	    }
    }
    }
    }'

    $variables = @"
    {
        "slug": "$tourney"
    }
"@

    $tourney_details = Invoke-GraphQLQuery -Query $query -Variables $variables -Headers $headers -Uri $StartGG_URI

    Return $tourney_details
}



$current_tourneys = Get-CurrentTournamentList
$all_tourneys = Get-AllTournamentList
$cred = Get-StartGGCredential
$tourneys_details = @()
$winners = @()

Foreach($tourney in $current_tourneys) {
    if($all_tourneys -notcontains $tourney) {
        $all_tourneys += $tourney
        $all_tourneys | Out-File "$current_path\all-tourneys.txt"
    }
}

Foreach($tourney in $all_tourneys) {
    $tourneys_details += Get-TournamentDetails $cred $tourney
}

Foreach($tourney in $tourneys_details) {
    Foreach($event in $tourney.data.tournament.events) {
        Foreach ($entrant in $event.entrants.nodes) {
            if($entrant.standing.placement -eq 1) {
                $winner_object = New-Object PSObject
                $winner_object | Add-Member -MemberType NoteProperty -Name "Name" -Value $entrant.name -Force
                $winner_object | Add-Member -MemberType NoteProperty -Name "Tournament" -Value $tourney.data.tournament.name -Force
                $winner_object | Add-Member -MemberType NoteProperty -Name "Sort Object" -Value ([int]$tourney.data.tournament.name.Substring(25,($tourney.data.tournament.name.Length - 25))) -Force
                $winner_object | Add-Member -MemberType NoteProperty -Name "Event" -Value $event.name -Force
                $winner_object | Add-Member -MemberType NoteProperty -Name "Placement" -Value $entrant.standing.placement -Force
                $winners += $winner_object
            }
        }
    }
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


$winner_html = $winners | Sort-Object -Descending -Property "Sort Object", "Event" | ConvertTo-Html "Name","Tournament","Event","Placement" -Head $head
[System.Web.HttpUtility]::HtmlDecode($winner_html) |  Out-File "$current_path\web\previous_winners.html"