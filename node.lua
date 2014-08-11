hosted_init()

gl.setup(960, 720)

local json = require "json"

util.resource_loader{
    "font.ttf";
    "background.frag";
}

function wrap(str, limit, indent, indent1)
    limit = limit or 72
    local here = 1
    local wrapped = str:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)
        if fi-here > limit then
            here = st
            return "\n"..word
        end
    end)
    local splitted = {}
    for token in string.gmatch(wrapped, "[^\n]+") do
        splitted[#splitted + 1] = token
    end
    return splitted
end

local tweets = N.tweets or {}

N.tweets = tweets

util.data_mapper{
    ["add"] = function(data)
        print(data)
        local tweet = json.decode(data)
        tweet.screen_name = "@" .. tweet.screen_name
        tweet.profile_image = resource.load_image_async(tweet.profile_image)
        if tweet.background_image then
            tweet.background_image = resource.load_image_async(tweet.background_image)
        end
        tweet.text = wrap(tweet.text, 27)
        tweet.created_at = sys.now() - tweet.age
        table.insert(tweets, tweet)
        if #tweets > 10 then
            table.remove(tweets, 1)
        end
    end
}

tweet_source = util.generator(function()
    return tweets
end)

function load_next()
    next_tweet = sys.now() + CONFIG.switch_time
    current_tweet = tweet_source:next()
end

next_tweet = sys.now()

function node.render()
    CONFIG.background.clear()

    if sys.now() > next_tweet then
        load_next()
    end

    pcall(function()
        background:use()
        if current_tweet.background_image then
            current_tweet.background_image:draw(0, 0, WIDTH, HEIGHT)
        else
            current_tweet.profile_image:draw(0, 0, WIDTH, HEIGHT)
        end
    end)
    background:deactivate()

    -- font:write(130, 20, "/" .. current_tweet.time .. "/#29c3" , 110, 1,1,1,1)
    age = sys.now() - current_tweet.created_at
    if age < 100 then
        age = string.format("%ds", age)
    elseif age < 3600 then
        age = string.format("%dm", age/60)
    else
        age = string.format("%dh", age/3600)
    end
    font:write(135, 35, "/" .. age.. " ago" , 70, CONFIG.foreground.rgba())
    font:write(20, 180, current_tweet.screen_name, 90, CONFIG.foreground.rgba())
    for idx, line in ipairs(current_tweet.text) do
        font:write(20, 220 + idx * 60, line, 60, CONFIG.foreground.rgba())
    end
    util.draw_correct(current_tweet.profile_image, 20, 20, 130, 130)
end
