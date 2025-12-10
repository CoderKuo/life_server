-- Drop old functions
DROP FUNCTION IF EXISTS selectmax();
DROP FUNCTION IF EXISTS insertstatm(character varying, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, numeric, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer, integer);

-- selectMax as PROCEDURE with OUT parameters
CREATE OR REPLACE PROCEDURE selectMax(
    OUT result_data REFCURSOR
)
LANGUAGE plpgsql AS $$
BEGIN
    OPEN result_data FOR
    SELECT category, playerid, extra FROM (
        SELECT 'max_warpts'::text as category, p.playerid, NULL::text as extra
        FROM players p
        WHERE p.warpts = (SELECT MAX(warpts) FROM players) LIMIT 1
    ) t1
    UNION ALL
    SELECT * FROM (
        SELECT 'max_bankacc'::text, p.playerid, NULL::text
        FROM players p
        WHERE p.bankacc = (SELECT MAX(bankacc) FROM players) LIMIT 1
    ) t2
    UNION ALL
    SELECT * FROM (
        SELECT 'max_cop_kills'::text, s.playerid, NULL::text
        FROM stats s
        WHERE s.cop_kills = (SELECT MAX(cop_kills) FROM stats) LIMIT 1
    ) t3
    UNION ALL
    SELECT * FROM (
        SELECT 'max_vigiarrests'::text, s.playerid, NULL::text
        FROM stats s
        WHERE s.vigiarrests = (SELECT MAX(vigiarrests) FROM stats) LIMIT 1
    ) t4
    UNION ALL
    SELECT * FROM (
        SELECT 'min_gokart_time_player'::text, s.playerid, NULL::text
        FROM stats s
        WHERE s.gokart_time = (SELECT MIN(gokart_time) FROM stats WHERE gokart_time > 0)
        LIMIT 1
    ) t5
    UNION ALL
    SELECT * FROM (
        SELECT 'min_gokart_time_value'::text, NULL::varchar, CAST(MIN(gokart_time) AS text)
        FROM stats WHERE gokart_time > 0
    ) t6
    UNION ALL
    SELECT * FROM (
        SELECT 'max_warkills'::text, p.playerid, NULL::text
        FROM players p
        WHERE p.warkills = (SELECT MAX(warkills) FROM players) LIMIT 1
    ) t7
    UNION ALL
    SELECT * FROM (
        SELECT 'max_cop_lethals'::text, s.playerid, NULL::text
        FROM stats s
        WHERE s.cop_lethals = (SELECT MAX(cop_lethals) FROM stats) LIMIT 1
    ) t8
    UNION ALL
    SELECT * FROM (
        SELECT 'max_casino_winnings'::text, s.playerid, NULL::text
        FROM stats s
        WHERE s.casino_winnings = (SELECT MAX(casino_winnings) FROM stats) LIMIT 1
    ) t9;
END;
$$;

-- insertStatM as PROCEDURE
CREATE OR REPLACE PROCEDURE insertStatM(
    p_playerid VARCHAR,
    p_marijuana INTEGER,
    p_heroinp INTEGER,
    p_cocainep INTEGER,
    p_crystalmeth INTEGER,
    p_mmushroom INTEGER,
    p_frogp INTEGER,
    p_oilp INTEGER,
    p_ironr INTEGER,
    p_diamondc INTEGER,
    p_glass INTEGER,
    p_cement INTEGER,
    p_platinumr INTEGER,
    p_moonshine INTEGER,
    p_fishnum INTEGER,
    p_saltr INTEGER,
    p_silverr INTEGER,
    p_copperr INTEGER,
    p_goldbar INTEGER,
    p_turtle INTEGER,
    p_redgull INTEGER,
    p_coffee INTEGER,
    p_lockpickfail INTEGER,
    p_lockpicksuc INTEGER,
    p_blastfed INTEGER,
    p_epipen INTEGER,
    p_speedbomb INTEGER,
    p_salvagenum INTEGER,
    p_salvagemon INTEGER,
    p_revive INTEGER,
    p_contraband INTEGER,
    p_copmoney INTEGER,
    p_bloodbag INTEGER,
    p_ticketpaid INTEGER,
    p_ticketval INTEGER,
    p_defuses INTEGER,
    p_kidney INTEGER,
    p_fishmon INTEGER,
    p_blastbw INTEGER,
    p_blastjail INTEGER,
    p_vigiarrest INTEGER,
    p_civ_kills INTEGER,
    p_cop_kills INTEGER,
    p_robberies INTEGER,
    p_prison_time INTEGER,
    p_sui_vest INTEGER,
    p_plane_kills INTEGER,
    p_aa_hacked INTEGER,
    p_cop_lethals INTEGER,
    p_pardons INTEGER,
    p_cop_arrests INTEGER,
    p_tickets_issued_paid INTEGER,
    p_donuts INTEGER,
    p_drugs_seized_currency INTEGER,
    p_gokart_time NUMERIC,
    p_med_toolkits INTEGER,
    p_aa_repaired INTEGER,
    p_med_impounds INTEGER,
    p_titan_hits INTEGER,
    p_hits_placed INTEGER,
    p_hits_claimed INTEGER,
    p_bets_won INTEGER,
    p_bets_lost INTEGER,
    p_bets_won_value INTEGER,
    p_bets_lost_value INTEGER,
    p_vehicles_chopped INTEGER,
    p_cops_robbed INTEGER,
    p_jail_escapes INTEGER,
    p_money_spent INTEGER,
    p_events_won INTEGER,
    p_blast_bank INTEGER,
    p_kills_1km INTEGER,
    p_conq_kills INTEGER,
    p_conq_deaths INTEGER,
    p_conq_captures INTEGER,
    p_casino_winnings INTEGER,
    p_casino_losses INTEGER,
    p_casino_uses INTEGER,
    p_lethal_injections INTEGER,
    p_pharmas_sold INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO stats (playerid)
    VALUES (p_playerid)
    ON CONFLICT (playerid) DO NOTHING;

    UPDATE stats SET
        marijuana               = marijuana + p_marijuana,
        heroinp                 = heroinp + p_heroinp,
        cocainep                = cocainep + p_cocainep,
        crystalmeth             = crystalmeth + p_crystalmeth,
        mmushroom               = mmushroom + p_mmushroom,
        frogp                   = frogp + p_frogp,
        oilp                    = oilp + p_oilp,
        ironr                   = ironr + p_ironr,
        diamondc                = diamondc + p_diamondc,
        glass                   = glass + p_glass,
        cement                  = cement + p_cement,
        platinumr               = platinumr + p_platinumr,
        moonshine               = moonshine + p_moonshine,
        saltr                   = saltr + p_saltr,
        silverr                 = silverr + p_silverr,
        copperr                 = copperr + p_copperr,
        goldbar                 = goldbar + p_goldbar,
        turtle                  = turtle + p_turtle,
        redgull                 = redgull + p_redgull,
        coffee                  = coffee + p_coffee,
        lockpick_fail           = lockpick_fail + p_lockpickfail,
        lockpick_suc            = lockpick_suc + p_lockpicksuc,
        blastfed                = blastfed + p_blastfed,
        epipen                  = epipen + p_epipen,
        speedbomb               = speedbomb + p_speedbomb,
        salvage                 = salvage + p_salvagenum,
        salvagem                = salvagem + p_salvagemon,
        revives                 = revives + p_revive,
        contraband              = contraband + p_contraband,
        cop_money               = cop_money + p_copmoney,
        bloodbag                = bloodbag + p_bloodbag,
        ticketspaid             = ticketspaid + p_ticketpaid,
        ticketvals              = ticketvals + p_ticketval,
        defuses                 = defuses + p_defuses,
        kidneys                 = kidneys + p_kidney,
        fishmon                 = fishmon + p_fishmon,
        blastbw                 = blastbw + p_blastbw,
        blastjail               = blastjail + p_blastjail,
        vigiarrests             = vigiarrests + p_vigiarrest,
        civ_kills               = civ_kills + p_civ_kills,
        cop_kills               = cop_kills + p_cop_kills,
        robberies               = robberies + p_robberies,
        prison_time             = prison_time + p_prison_time,
        sui_vest                = sui_vest + p_sui_vest,
        plane_kills             = plane_kills + p_plane_kills,
        aa_hacked               = aa_hacked + p_aa_hacked,
        cop_lethals             = cop_lethals + p_cop_lethals,
        pardons                 = pardons + p_pardons,
        cop_arrests             = cop_arrests + p_cop_arrests,
        tickets_issued_paid     = tickets_issued_paid + p_tickets_issued_paid,
        donuts                  = donuts + p_donuts,
        drugs_seized_currency   = drugs_seized_currency + p_drugs_seized_currency,
        gokart_time             = p_gokart_time,
        med_toolkits            = med_toolkits + p_med_toolkits,
        aa_repaired             = aa_repaired + p_aa_repaired,
        med_impounds            = med_impounds + p_med_impounds,
        titan_hits              = titan_hits + p_titan_hits,
        hits_placed             = hits_placed + p_hits_placed,
        hits_claimed            = hits_claimed + p_hits_claimed,
        bets_won                = bets_won + p_bets_won,
        bets_lost               = bets_lost + p_bets_lost,
        bets_won_value          = bets_won_value + p_bets_won_value,
        bets_lost_value         = bets_lost_value + p_bets_lost_value,
        vehicles_chopped        = vehicles_chopped + p_vehicles_chopped,
        cops_robbed             = cops_robbed + p_cops_robbed,
        jail_escapes            = jail_escapes + p_jail_escapes,
        money_spent             = money_spent + p_money_spent,
        events_won              = events_won + p_events_won,
        blastbank               = blastbank + p_blast_bank,
        kills_1km               = kills_1km + p_kills_1km,
        conq_kills              = conq_kills + p_conq_kills,
        conq_deaths             = conq_deaths + p_conq_deaths,
        conq_captures           = conq_captures + p_conq_captures,
        casino_winnings         = casino_winnings + p_casino_winnings,
        casino_losses           = casino_losses + p_casino_losses,
        casino_uses             = casino_uses + p_casino_uses,
        lethal_injections       = lethal_injections + p_lethal_injections,
        pharmas_sold            = pharmas_sold + p_pharmas_sold
    WHERE playerid = p_playerid;
END;
$$;
