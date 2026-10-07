-- ============================================================
-- CONFIG
-- ============================================================

local enableCustomRating = getModSetting("betterRank")
if enableCustomRating == nil then
	enableCustomRating = true
end


-- ============================================================
-- Unsent Custom Final Rating
-- NFE 1.2.2
--
-- 自定义评级：
-- >= 99.5%   -> P
-- >= 98%     -> E
-- >= 96%     -> SSS
-- >= 94%     -> SS
-- >= 92%     -> S+
-- >= 90%     -> S
-- > 85%      -> A+
-- > 80%      -> A
-- >= 75%     -> Great
-- >= 70%     -> Good
-- >= 60%     -> B
-- >= 50%     -> C
-- >= 40%     -> D
-- >= 30%     -> F
-- >= 20%     -> F-
-- >= 10%     -> You SUCK!
-- > 0%       -> You Not Playing!
--
-- FC 标签：
-- AP / SFC / GFC / BFC / FC 保留
-- PFC -> AP
--
-- NPS / Score / Misses / Accuracy
-- 继续使用 NFE 原版数据
-- ============================================================

local customRating = 'N/A'


-- ============================================================
-- 自定义评级
-- ============================================================

local function getCustomRating()
	local ratingPercent = getProperty('ratingPercent')
	local misses = getProperty('songMisses')

	if ratingPercent == nil then
		return 'N/A'
	end

	if misses == nil then
		misses = 0
	end

	local percent = math.floor(ratingPercent * 10000) / 100


	if percent >= 99.5 then
		return 'P'
	elseif percent >= 98 then
		return 'E'
	elseif percent >= 96 then
		return 'SSS'
	elseif percent >= 94 then
		return 'SS'
	elseif percent >= 92 then
		return 'S+'
	elseif percent >= 90 then
		return 'S'
	elseif percent > 85 then
		return 'A+'
	elseif percent > 80 then
		return 'A'
	elseif percent >= 75 then
		return 'Great'
	elseif percent >= 70 then
		return 'Good'
	elseif percent >= 60 then
		return 'B'
	elseif percent >= 50 then
		return 'C'
	elseif percent >= 40 then
		return 'D'
	elseif percent >= 30 then
		return 'F'
	elseif percent >= 20 then
		return 'F-'
	elseif percent >= 10 then
		return 'You SUCK!'
	elseif percent > 0 then
		return 'You Not Playing!'
	end

	return 'N/A'
end


-- ============================================================
-- 判断 FC 标签是否保留
-- ============================================================

local function shouldKeepFC(fc)
	if fc == 'AP' or fc == 'FC' then
		return fc
	elseif fc == 'SFC' or fc == 'GFC' or fc == 'BFC' then
		return 'FC'
	else
		return nil
	end
end


-- ============================================================
-- 修改 NFE 原本的 scoreTxt
-- ============================================================

local function updateCustomRating()
	-- 总开关关闭时，不碰 NFE 原版文本
	if not enableCustomRating then
		return
	end

	if not getProperty('scoreTxt.visible') then
		return
	end

	local text = getProperty('scoreTxt.text')

	if text == nil or text == '' then
		return
	end

	customRating = getCustomRating()

	-- 找到最后一个 | 后面的内容
	local before, finalPart = text:match('^(.*|)%s*(.*)$')

	if before == nil or finalPart == nil then
		return
	end

	-- 读取 NFE 原本的 FC 标签
	local fc = finalPart:match('^%((.-)%)%s*')

	local ratingPercent = getProperty('ratingPercent')
	local misses = getProperty('songMisses')

	if ratingPercent == nil then
		ratingPercent = 0
	end

	if misses == nil then
		misses = 0
	end

	-- PFC -> AP（100% 且无 miss）
	if (ratingPercent >= 1 and misses <= 0) or fc == 'PFC' then
		fc = 'AP'
	end

	-- 原版没 FC 标签但全连 → 自动补
	if fc == nil and misses <= 0 then
		if ratingPercent >= 1 then
			fc = 'AP'
		else
			fc = 'FC'
		end
	end

	fc = shouldKeepFC(fc)

	local newText
	
	if customRating == 'N/A' then
		-- 没有有效评级时保留 N/A
		newText = before .. ' Rank: N/A'
	elseif fc ~= nil then
		-- 保留 FC 标签
		newText = before .. ' Rank: ' .. customRating .. ' (' .. fc .. ')'
	else
		-- 隐藏其他 FC 标签
		newText = before .. ' Rank: ' .. customRating
	end

	if newText ~= text then
		setProperty('scoreTxt.text', newText)
	end
end


-- ============================================================
-- 每帧更新
-- ============================================================

function onUpdatePost()
	updateCustomRating()
end