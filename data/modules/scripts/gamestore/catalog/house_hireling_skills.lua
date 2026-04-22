-- Hireling Skills - Store Category
-- Additional skills for hirelings including Super Trader

return {
    icons = { "Category_HirelingSkills.png" },
    name = "Hireling Skills",
    parent = "Houses",
    rookgaard = true,
    state = GameStore.States.STATE_NONE,
    offers = {
        {
            icons = { "Hireling_SuperTrader.png" },
            name = "Hireling Super Trader",
            price = 2180,
            id = 1005,  -- HIRELING_SKILLS.SUPERTRADER[1]
            count = 1,
            description = "{info} Unlock the Super Trader skill for your hireling!\n" ..
                          "{info} REQUIREMENT: Your hireling MUST have the Banker skill!\n" ..
                          "{info} Sell monster loot to your hireling (5% fee)\n" ..
                          "{info} Buy items with 3% convenience fee\n" ..
                          "{info} You collect all fees!\n" ..
                          "{warning} Say 'supertrade' to access the trading window",
            type = GameStore.OfferTypes.OFFER_TYPE_HIRELING_SKILL,
        },
    }
}
