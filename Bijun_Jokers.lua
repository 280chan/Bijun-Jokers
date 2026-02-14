local mod_chips_ref = mod_chips
function mod_chips(_chips)
    local ret = mod_chips_ref(_chips)
    if G.GAME.stabilizer_caps then
        ret = math.min(ret, G.GAME.stabilizer_caps)
    end
    return ret
end

local set_hand_usage_ref = set_hand_usage
function set_hand_usage(hand)
    set_hand_usage_ref(hand)
    if next(SMODS.find_card('j_bj_stabilizer')) then
        G.GAME.stabilizer_caps = G.GAME.hands[hand].chips
    end
end

local ease_discard_ref = ease_discard
function ease_discard(mod, instant, silent)
    if G.GAME.energy_saver then
        mod = -(G.GAME.energy_saver/5)
        G.GAME.energy_saver = nil
    end
    ease_discard_ref(mod, instant, silent)

end

local ease_hands_played_ref = ease_hands_played
function ease_hands_played(mod, instant)
    if G.GAME.energy_saver then
        mod = -(G.GAME.energy_saver/5)
        G.GAME.energy_saver = nil
    end
    ease_hands_played_ref(mod, instant)
end

local G_FUNCS_can_discard_ref = G.FUNCS.can_discard
G.FUNCS.can_discard = function(e)
    if G.GAME.current_round.discards_left < 1 and #G.hand.highlighted/5 > G.GAME.current_round.discards_left + 0.000001 then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        G_FUNCS_can_discard_ref(e)
    end
end

local G_FUNCS_can_play_ref = G.FUNCS.can_play
G.FUNCS.can_play = function(e)
    if G.GAME.current_round.hands_left < 1 and #G.hand.highlighted/5 > G.GAME.current_round.hands_left + 0.000001 then
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    else
        G_FUNCS_can_play_ref(e)
    end
end

local G_FUNCS_discard_cards_from_highlighted_ref = G.FUNCS.discard_cards_from_highlighted
G.FUNCS.discard_cards_from_highlighted = function(e, hook)
    if next(SMODS.find_card('j_bj_energy_saver')) and not hook then
        G.GAME.energy_saver = #G.hand.highlighted
        G.GAME.current_round.hands_left = math.ceil(G.GAME.current_round.hands_left*10)/10
    end
    G_FUNCS_discard_cards_from_highlighted_ref(e, hook)
end

local G_FUNCS_play_cards_from_highlighted_ref = G.FUNCS.play_cards_from_highlighted
G.FUNCS.play_cards_from_highlighted = function(e)
    if next(SMODS.find_card('j_bj_energy_saver')) then
        G.GAME.energy_saver = #G.hand.highlighted
        G.GAME.current_round.hands_left = math.ceil(G.GAME.current_round.hands_left*10)/10
    end
    G_FUNCS_play_cards_from_highlighted_ref(e)
end

local Sprite_init_ref = Sprite.init
function Sprite:init(X, Y, W, H, new_sprite_atlas, sprite_pos)
    if new_sprite_atlas == G.ASSET_ATLAS["bj_jokers"] and sprite_pos.x == 2 and sprite_pos.y == 0 then
        Moveable.init(self,X, Y, W, H)
        self.CT = self.VT
        self.atlas = new_sprite_atlas
        self.scale = {x=self.atlas.px*0.7, y=self.atlas.py*0.7}
        self.scale_mag = math.min(self.scale.x/W,self.scale.y/H)
        self.zoom = true

        self:set_sprite_pos(sprite_pos)

        if getmetatable(self) == Sprite then 
            table.insert(G.I.SPRITE, self)
        end
    else
        Sprite_init_ref(self, X, Y, W, H, new_sprite_atlas, sprite_pos)
    end
end

local Sprite_set_sprites_pos_ref = Sprite.set_sprite_pos
function Sprite:set_sprite_pos(sprite_pos)
    if self.atlas == G.ASSET_ATLAS["bj_jokers"] and sprite_pos.x == 2 and sprite_pos.y == 0 then
        if sprite_pos and sprite_pos.v then 
            self.sprite_pos = {x = (math.random(sprite_pos.v)-1), y = sprite_pos.y}
        else
            self.sprite_pos = sprite_pos or {x=0,y=0}
        end
        self.sprite_pos_copy = {x = self.sprite_pos.x, y = self.sprite_pos.y}

        self.sprite = love.graphics.newQuad( 
            self.sprite_pos.x*self.atlas.px+self.atlas.px*0.15,
            self.sprite_pos.y*self.atlas.py+self.atlas.py*0.15,
            self.scale.x,
            self.scale.y, self.atlas.image:getDimensions())

        self.image_dims = {}
        self.image_dims[1], self.image_dims[2] = self.atlas.image:getDimensions()
    else
        Sprite_set_sprites_pos_ref(self, sprite_pos)
    end
end

local Game_update_new_round_ref = Game.update_new_round
function Game:update_new_round(dt)
    if G.GAME.chips - G.GAME.blind.chips < 0 and G.GAME.current_round.hands_left < 1 and G.GAME.current_round.hands_left > 0.000001 then
        if not G.STATE_COMPLETE then
            G.STATE = G.STATES.DRAW_TO_HAND
        end
    else
        Game_update_new_round_ref(self, dt)
    end
end

local Card_set_sprites_ref = Card.set_sprites
function Card:set_sprites(_center, _front)
    Card_set_sprites_ref(self, _center, _front)
    if _center and _center.name == 'Stabilizer' and (_center.discovered or self.bypass_discovery_center) then
        self.T.h = G.CARD_H*0.7
        self.T.w = G.CARD_W*0.7
    end
end

function is_prime(num)
    if num < 2 then
        return false
    end
    if num == 2 then
        return true
    end
    if num % 2 == 0 then
        return false
    end
    for i = 3, math.sqrt(num), 2 do
        if num % i == 0 then
            return false
        end
    end
    return true
end

function can_make_24(nums)
    if #nums == 1 then
        return math.abs(nums[1] - 24) < 0.000001
    end
    for i = 1, #nums do
        for j = i + 1, #nums do
            local a, b = nums[i], nums[j]
            local rest = {}
            for k = 1, #nums do
                if k ~= i and k ~= j then
                    rest[#rest + 1] = nums[k]
                end
            end
            local _pairs = {
                a + b,
                a - b,
                b - a,
                a * b,
            }
            if math.abs(b) > 0.000001 then table.insert(_pairs, a / b) end
            if math.abs(a) > 0.000001 then table.insert(_pairs, b / a) end
            for _, pair in ipairs(_pairs) do
                table.insert(rest, 1, pair)
                if can_make_24(rest) then
                    return true
                end
                table.remove(rest, 1)
            end
        end
    end
    return false
end

SMODS.Atlas{
    key = 'jokers',
    px = 71,
    py = 95,
    path = 'Jokers.png'
}

SMODS.Joker{
    key = 'hacker',
    name = 'Hacker',
    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 0, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        local r_xmults = {}
        for i = 1, 99 do
            if i%10 ~= 0 then
                r_xmults[#r_xmults+1] = '÷'..tostring(i/100)
            end
        end
        local loc_mult = ' '..(localize('k_mult'))..' '
        main_start = {
            {n=G.UIT.T, config={text = '  ',colour = G.C.MULT, scale = 0.32}},
            {n=G.UIT.C, config={align = "m", colour = G.C.MULT, r = 0.05, padding = 0.03, res = 0.15}, nodes={
                {n=G.UIT.O, config={object = DynaText({string = r_xmults, colours = {G.C.WHITE}, pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.5, scale = 0.32, min_cycle_time = 0})}},
            }},
            {n=G.UIT.O, config={object = DynaText({string = {{string = 'rand()', colour = G.C.JOKER_GREY}, {string = "#@"..(G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.id or 11)..(G.deck and G.deck.cards[1] and G.deck.cards[#G.deck.cards].base.suit:sub(1,1) or 'D'), colour = G.C.RED},
                loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult, loc_mult},
            colours = {G.C.UI.TEXT_DARK},pop_in_rate = 9999999, silent = true, random_element = true, pop_delay = 0.2011, scale = 0.32, min_cycle_time = 0})}},
        }
        return { vars = {}, main_start = main_start }
    end,
    calculate = function(self, card, context)
        if context.joker_main then
            local r_xmult = (math.floor((1/pseudorandom('hacker'))*100))/100
            return {
                message = localize{type='variable',key='a_xmult',vars={r_xmult}},
                Xmult_mod = r_xmult
            }
        end
    end
}

SMODS.Joker{
    key = 'planetary_recurrence',
    name = 'Planetary Recurrence',
    rarity = 2,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 1, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = { repetition = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.repetition and context.scoring_name and is_prime(G.GAME.hands[context.scoring_name].level) then
            if (context.cardarea == G.hand and (next(context.card_effects[1]) or #context.card_effects > 1)) or context.cardarea == G.play then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    card = card
                }
            end
        end
        if context.using_consumeable and context.consumeable.ability.set == 'Planet' and not context.consumeable.debuff then
            if context.consumeable.ability.consumeable.hand_type and is_prime(G.GAME.hands[context.consumeable.ability.consumeable.hand_type].level-1) then
                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_again_ex')})
                context.consumeable:use_consumeable(context.consumeable.area)
            end
        end
        if context.retrigger_joker_check and context.other_card and context.other_card.ability.set == 'Planet' then
            if context.other_card.ability.consumeable.hand_type and is_prime(G.GAME.hands[context.other_card.ability.consumeable.hand_type].level) then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    message_card = context.blueprint_card or card,
                }
            end
        end
        if context.other_consumeable and context.other_consumeable.ability.set == 'Planet' and G.GAME.used_vouchers.v_observatory then
            if context.other_consumeable.ability.consumeable.hand_type and is_prime(G.GAME.hands[context.other_consumeable.ability.consumeable.hand_type].level) then
                return {
                    x_mult = G.P_CENTERS['v_observatory'].config.extra,
                    message_card = context.other_consumeable,
                }
            end
        end
    end
}

SMODS.Joker{
    key = 'stabilizer',
    name = 'Stabilizer',
    rarity = 2,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 2, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = { repetition = 1 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
        if context.repetition then
            if (context.cardarea == G.hand and (next(context.card_effects[1]) or #context.card_effects > 1)) or context.cardarea == G.play then
                return {
                    message = localize('k_again_ex'),
                    repetitions = card.ability.extra.repetition,
                    card = card
                }
            end
        end
        if context.after and not context.blueprint_card then
            G.GAME.stabilizer_caps = nil
        end
    end
}

SMODS.Joker{
    key = '24_puzzle',
    name = '24 Puzzle',
    rarity = 3,
    cost = 6,
    unlocked = true,
    discovered = true,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    pos = { x = 3, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = { x_mult = 1, x_mult_mod = 0.24 } },
    loc_vars = function(self, info_queue, card)
        return { vars = {card.ability.extra.x_mult, card.ability.extra.x_mult_mod} }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint then
            local nums = {}
            for k, v in ipairs(context.full_hand) do
                local rank = v:get_id()
                if rank > 1 and rank <= 10 then
                    nums[#nums+1] = rank
                elseif rank > 10 and rank <= 13 then
                    nums[#nums+1] = 10
                elseif rank == 14 then
                    nums[#nums+1] = 1
                end
            end
            if #nums == 4 and not can_make_24(nums) then
                card.ability.extra.x_mult = card.ability.extra.x_mult + card.ability.extra.x_mult_mod
                return {
                    message = localize('k_upgrade_ex'),
                    colour = G.C.RED,
                    card = card
                }
            end
        end
        if context.joker_main and card.ability.extra.x_mult > 1 then
            return {
                message = localize { type = 'variable', key = 'a_xmult', vars = { card.ability.extra.x_mult } },
                Xmult_mod = card.ability.extra.x_mult
            }
        end
    end
}

SMODS.Joker{
    key = 'energy_saver',
    name = 'Energy Saver',
    rarity = 3,
    cost = 8,
    unlocked = true,
    discovered = true,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    pos = { x = 3, y = 0 },
    loc_txt ={},
    atlas = 'jokers',
    config = { extra = {} },
    loc_vars = function(self, info_queue, card)
        return { vars = {} }
    end,
    calculate = function(self, card, context)
    end
}