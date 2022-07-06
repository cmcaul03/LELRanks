$tourney = Invoke-WebRequest "https://raw.githubusercontent.com/cmcaul03/LELRanks/main/current-tourney?raw=true"

$tourney = $tourney.Content

$tourney = $tourney.ToString()

$tourney = $tourney -replace "`t|`n|`r",""
$tourney = $tourney -replace " ;|; ",";"

$players_response = Invoke-RestMethod "https://api.smash.gg/tournament/$tourney`?expand[]=entrants"

$players = $players_response.entities.entrants

$team_data = @()

$event_response = Invoke-RestMethod "https://api.smash.gg/tournament/$tourney`?expand[]=event"

$events = $event_response.entities.event

$total_players = $players_response.entities.entrants.Count


Foreach ($player_ob in $players) {

    $profileId = $null

    Foreach($event in $events) {
        if ($player_ob.eventId -match $event.id) {
            $event_name = $event.name
        }
    }

    $player = $player_ob.name

    if ($player -eq "Moketronics") {
        $player = "Moketronics7740"
    } elseif ($player -eq "OmnissiahMaster") {
        $player = "OmnissiaH"
        $profileId = "10481437"
    }elseif ($player -eq "Daywalker") {
        $player = "DayWalker7617"
    }elseif ($player -eq "[Wl]_freecapsack") {
        $player = "Rise of Patience"
    }elseif ($player -eq "Cynique") {
        $player = "El Cyniquo"
    }elseif ($player -eq "Rode") {
        $profileId = "7038867"
    }elseif ($player -eq "Free") {
        $player = "Free"
        $profileId = "3696245"
    }elseif ($player -eq "everlast") {
        $player = "everlast007"
    }

    $response = Invoke-RestMethod "https://aoeiv.net/leaderboard/aoe4/season-1?draw=6&columns[0][data]=&columns[0][name]=&columns[0][searchable]=false&columns[0][orderable]=true&columns[0][search][value]=&columns[0][search][regex]=false&columns[1][data]=&columns[1][name]=&columns[1][searchable]=false&columns[1][orderable]=true&columns[1][search][value]=&columns[1][search][regex]=false&columns[2][data]=&columns[2][name]=&columns[2][searchable]=true&columns[2][orderable]=true&columns[2][search][value]=&columns[2][search][regex]=false&columns[3][data]=&columns[3][name]=&columns[3][searchable]=false&columns[3][orderable]=true&columns[3][search][value]=&columns[3][search][regex]=false&columns[4][data]=&columns[4][name]=&columns[4][searchable]=false&columns[4][orderable]=true&columns[4][search][value]=&columns[4][search][regex]=false&columns[5][data]=&columns[5][name]=&columns[5][searchable]=false&columns[5][orderable]=true&columns[5][search][value]=&columns[5][search][regex]=false&columns[6][data]=&columns[6][name]=&columns[6][searchable]=false&columns[6][orderable]=true&columns[6][search][value]=&columns[6][search][regex]=false&columns[7][data]=&columns[7][name]=&columns[7][searchable]=false&columns[7][orderable]=true&columns[7][search][value]=&columns[7][search][regex]=false&order[0][column]=0&order[0][dir]=asc&start=0&length=100&search[value]=$player&search[regex]=false&_=1655526809872"

    $player = $player.ToString()
    
    $player_object = New-Object PSObject
    $player_object | Add-Member -MemberType NoteProperty -Name "Name" -Value $player -Force

    $count = $response.data.count

    Foreach ($object in $response.data) {
        if ($object.profile_id -eq $profileId) {
            $response = $object
        }
    }

    if($response.data.count -eq 1) {
        $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Elo" -Value $response.data.rating -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value $response.data[0].rank -Force}
    elseif($profile -ne $null) {
        $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Elo" -Value $response.rating -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value $response.rank -Force}
    else {
        $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Elo" -Value "There was $count matches for the string $player" -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value "There was $count matches"  -Force}

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/json")

    $body = "{`"region`": `"7`",`"versus`": `"players`",`"matchType`": `"ranked`",`"teamSize`": `"1v1`",`"searchPlayer`": `"$player`",`"page`": 1,`"count`": 100}"

    $response2 = Invoke-RestMethod 'https://api.ageofempires.com/api/ageiv/Leaderboard' -Method 'POST' -Headers $headers -Body $body

    $player = $player.ToString()

    $count2 = $response2.items.Count

    Foreach ($object in $response2.items) {
        if ($object.rlUserId -eq $profileId) {
            $response2 = $object
        }
    }

    if ($count2 -eq 1 -and $profileId -eq $null) {
        $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value $response2.items[0].elo -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value $response2.items[0].rank -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value ($response2.items[0].wins + $response2.items[0].losses) -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Registered For" -Value $event_name -Force
    } elseif ($profileId -ne $null) {
        $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value $response2.elo -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value $response2.rank -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value ($response2.wins + $response2.losses) -Force
        $player_object | Add-Member -MemberType NoteProperty -Name "Registered For" -Value $event_name -Force
    } else {
    $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Elo" -Value "There was $count2 matches for the string $player" -Force
    $player_object | Add-Member -MemberType NoteProperty -Name "Hidden Rank" -Value "There was $count2 matches" -Force
    $player_object | Add-Member -MemberType NoteProperty -Name "Games Played" -Value "There was $count2 matches" -Force
    $player_object | Add-Member -MemberType NoteProperty -Name "Registered For" -Value $event_name -Force
    }

    $team_data += $player_object
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
<p>Last updated at: $time UTC. There were $total_players players found. <a href="https://aoeranks.cammcauliffe.com">Shit Menu</a></p>
"@

$team_data | Sort-Object -Property "Hidden Rank" | ConvertTo-Html -Head $head | Out-File "D:\AOERanks\web\$tourney.html"
