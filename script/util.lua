function get_orientation_entity(e1, e2)
    return get_orientation_pos(e1.position, e2.position)
end
function get_orientation_pos(p1, p2)
    x = p2.x - p1.x
    y = p2.y - p1.y
    res = (math.atan2(y, x)+(math.pi/2)) / (math.pi*2)
    if res > 2*math.pi then
        res = res - 2*math.pi
    end
    return res
end