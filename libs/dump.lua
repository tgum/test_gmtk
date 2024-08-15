function dump(o,level)
  level = level or 1
  if type(o) == 'table' then
    local s = {}
    s[1] = '{ '
    for k,v in pairs(o) do
      if type(k) ~= 'number' then
        k = '"'..k..'"'
      end
      s[#s+1] = string.rep('\t',level).. '['..k..'] = ' .. dump(v, level+1) .. ','
    end
    s[#s+1] = string.rep('\t',level) .. '} '
    return table.concat(s , "\n")
  else
    return tostring(o or 'nil')
  end
end
return dump
