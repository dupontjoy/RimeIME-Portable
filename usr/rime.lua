--- date/time translator
function date_translator(input, seg)
if (input == "date" or input == "riqi") then
--- Candidate(type, start, end, text, comment)
yield(Candidate("date", seg.start, seg._end, os.date("%Y-%m-%d"), ""))
yield(Candidate("date", seg.start, seg._end, os.date("%Y年%m月%d日"), ""))
yield(Candidate("time", seg.start, seg._end, os.date("%Y/%m/%d %H:%M:%S"), ""))
yield(Candidate("time", seg.start, seg._end, os.date("%Y%m%d_%H%M%S"), ""))
end
if (input == "time" or input == "uijm") then
--- Candidate(type, start, end, text, comment)
yield(Candidate("time", seg.start, seg._end, os.date("%H:%M:%S"), ""))
yield(Candidate("time", seg.start, seg._end, os.date("%H:%M"), ""))
yield(Candidate("time", seg.start, seg._end, os.date("%Y/%m/%d %H:%M:%S"), ""))
yield(Candidate("time", seg.start, seg._end, os.date("%Y%m%d%H%M%S"), ""))
end
end