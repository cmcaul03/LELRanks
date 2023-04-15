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
                entrants (query: { page: 1, perPage: 300 }) {
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
    # $player_name = "01"
    write-host $player_name
    if ($profileid_csv -match $player_name) {
        $profileid = ($profileid_csv | Where-Object {$_.player -match $player_name}).profile_id | select-object -Last 1
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


Function Get-Elos ($player_name) {
    $elo = $null
    $game_modes = @("rm_1v1_elo", "rm_2v2_elo", "rm_3v3_elo", "rm_4v4_elo")
    $elo_object = New-Object PSObject
    if ($player_name -ne $null) {
        $profile_id = (Get-ProfileID ($player_name))
        if ($profile_id -notmatch "ERROR") {
            $response = Invoke-RestMethod "https://aoe4world.com/api/v0/players/$profile_id"
            write-host "https://aoe4world.com/api/v0/players/$profile_id"
            Foreach ($game_mode in $game_modes) {
                    $elo_object | Add-Member -MemberType NoteProperty -Name $game_mode -Value $response.modes.$game_mode.rating -Force
                }
            }
        else {
            $elo_object | Add-Member -MemberType NoteProperty -Name $game_mode -Value $profile_id -Force
        }
    }
    return $elo_object
}

Function Export-Data ($tournament_entrants) {
    $tournament_entrants | Sort-Object -Property "Team Name" | Export-CSV  "D:\GIT\LELRanks\web\RE-2v2-tourney.csv" -NoTypeInformation
}

Function Get-EntrantData ($tournament_name) {
    $profileid_csv = import-csv "D:\GIT\LELRanks\profile-ids.csv"
    $tournament_name = "rising-empires-2v2-showdown"
    $tournament = Get-TournamentDetails ($tournament_name)
    $tournament_entrants = @()
    Foreach ($entrant in $tournament.data.tournament.events[0].entrants.nodes) {
        $entrant_object = New-Object PSObject
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Team Name" -Value $entrant.name -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 1 - Name" -Value $entrant.participants[0].gamerTag -Force
        $elos = Get-Elos $entrant.participants[0].gamerTag
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 1 - 1v1 Elo" -Value $elos.rm_1v1_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 1 - 2v2 Elo" -Value $elos.rm_2v2_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 1 - 3v3 Elo" -Value $elos.rm_3v3_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 1 - 4v4 Elo" -Value $elos.rm_4v4_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 2 - Name" -Value $entrant.participants[1].gamerTag -Force
        $elos = Get-Elos $entrant.participants[1].gamerTag
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 2 - 1v1 Elo" -Value $elos.rm_1v1_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 2 - 2v2 Elo" -Value $elos.rm_2v2_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 2 - 3v3 Elo" -Value $elos.rm_3v3_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 2 - 4v4 Elo" -Value $elos.rm_4v4_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 3 - Name" -Value $entrant.participants[2].gamerTag -Force
        $elos = Get-Elos $entrant.participants[2].gamerTag
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 3 - 1v1 Elo" -Value $elos.rm_1v1_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 3 - 2v2 Elo" -Value $elos.rm_2v2_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 3 - 3v3 Elo" -Value $elos.rm_3v3_elo -Force
        $entrant_object | Add-Member -MemberType NoteProperty -Name "Participant 3 - 4v4 Elo" -Value $elos.rm_4v4_elo -Force
        $tournament_entrants += $entrant_object
    }
    Export-Data $tournament_entrants
    Return $tournament_entrants
}

Get-EntrantData rising-empires-2v2-showdown