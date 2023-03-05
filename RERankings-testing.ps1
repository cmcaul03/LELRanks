Function Get-TournamentDetails ($tournament_name) {
    $StartGG_URI = "https://api.start.gg/gql/alpha"
    $cred = gc "C:\StartGG_cred.txt"
    #$tournament_name = "low-elo-legends"
    $headers = @{Authorization="Bearer $cred"}

    $query = '
    query tournament($slug: String) {
        tournament(slug: $slug) {
            id 
            events {
                name
                id
                entrants {
                    nodes {
                        name
                        initialSeedNum
                        id
                        participants {
                            id
                            gamerTag
                        }
                    }
                }
            }
        }
    }'

    $variables = @"
    {
        "slug": "$tournament_name"
    }
"@

    $tournament_details = Invoke-GraphQLQuery -Query $query -Variables $variables -Headers $headers -Uri $StartGG_URI

    Return $tournament_details
}

Function Get-ProfileId ($player_name) {
    write-host $player_name
    if ($profileid_csv -match $player_name) {
        $profileid = ($profileid_csv | Where-Object {$_.player -Match $player_name}).profile_id
        return $profileid
    }
    $response = Invoke-RestMethod "https://aoe4world.com/api/v0/players/search?query=$player_name"
    if ($response.total_count -eq 1) {
        $profile_id = $response.players[0].profile_id
    } else {
        $profile_id = "ERROR: There was " + $response.total_count + " responses for this player name $player_name"
    }
    return $profile_id
}


Function Get-Stats ($player_name) {
    $elo = $null
    $game_modes = @("rm_1v1_elo", "rm_solo" )
    $elo_object = New-Object PSObject
    if ($player_name -ne $null) {
        $profile_id = (Get-ProfileID ($player_name))
        if ($profile_id -notmatch "ERROR") {
            $response = Invoke-RestMethod "https://aoe4world.com/api/v0/players/$profile_id"
            write-host "https://aoe4world.com/api/v0/players/$profile_id"
            Foreach ($game_mode in $game_modes) {
                    $elo_object | Add-Member -MemberType NoteProperty -Name $game_mode -Value $response.modes.$game_mode.rating -Force
                    $elo_object | Add-Member -MemberType NoteProperty -Name $game_mode+"_win_rate" -Value $response.modes.$game_mode.win_rate -Force
                }
            }
        else {
            $elo_object | Add-Member -MemberType NoteProperty -Name "rm_1v1_elo" -Value $profile_id -Force
        }
        $elo_object | Add-Member -MemberType NoteProperty -Name "ProfileID" -Value $profile_id -Force
    }
    return $elo_object
}

Function Export-Data ($tournament_entrants, $event) {
    $tournament_entrants | Sort-Object -Property "Team Name" | Export-CSV  "D:\GIT\LELRanks\web\$event-testing-tourney.csv" -NoTypeInformation
}

Function Get-EntrantData ($tournament_name) {
    $profileid_csv = import-csv "D:\AOERanks\profile-ids.csv"
    $tournament = Get-TournamentDetails ($tournament_name)
    $tournament_entrants = @()
    Foreach ($event in $tournament.data.tournament.events) {
        Foreach ($entrant in $event.entrants.nodes) {
            $entrant_object = New-Object PSObject
            $stats = Get-Stats $entrant.participants[0].gamerTag
            $entrant_object | Add-Member -MemberType NoteProperty -Name "Name" -Value ("<a href=`"https://aoe4world.com/players/"+$stats.rm_solo+"/>`""+$entrant.participants[0].gamerTag+"</a>")  -Force
            $entrant_object | Add-Member -MemberType NoteProperty -Name "Ladder Rating" -Value $stats.rm_solo -Force
            $entrant_object | Add-Member -MemberType NoteProperty -Name "Ladder Rank" -Value $stats.rm_1v1_elo -Force
            $entrant_object | Add-Member -MemberType NoteProperty -Name "Elo" -Value $stats.rm_1v1_elo -Force
            $entrant_object | Add-Member -MemberType NoteProperty -Name "Win Rate" -Value $stats.rm_1v1_elo_win_rate -Force
            $tournament_entrants += $entrant_object
        }
        Export-Data $tournament_entrants $event.name
    }
}

Get-EntrantData "rising-empires-weeklies-22"