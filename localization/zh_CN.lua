return {
    descriptions = {
        Joker={
            j_bj_hacker={
                name = '黑客',
                text = {
                    "",
                },
            },
            j_bj_planetary_recurrence={
                name = '行星再临',
                text = {
                    "{C:attention}牌型等级{}为质数时重新触发",
                    "{C:planet}星球牌{}和所有{C:attention}游戏牌{}",
                },
            },
            j_bj_stabilizer={
                name = '稳定器',
                text = {
                    "重新触发所有{C:attention}游戏牌{}",
                    "{C:chips}筹码{}不超过牌型基础筹码",
                },
            },
            j_bj_24_puzzle={
                name = '24点',
                text = {
                    "如果打出的牌正好",
                    "包含{C:attention}4{}张有点数的牌",
                    "且无法计算出{C:attention}24{}点",
                    "这张小丑获得{X:mult,C:white}X#2#{}倍率",
                    "{C:inactive}（当前为{X:mult,C:white}X#1#{C:inactive}倍率）",
                },
            },
            j_bj_energy_saver={
                name = '节能器',
                text = {
                    "{C:blue}出牌{}次数与{C:red}弃牌{}",
                    "次数的消耗和",
                    "{C:attention}选定牌{}的数量挂钩",
                },
            },
        },
    },
}