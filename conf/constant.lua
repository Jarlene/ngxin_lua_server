local constant = {
    --缓存key设置
}
-- Millisecond
constant.ONE_MILLISECOND = 1
constant.ONE_SECOND = 1000 * constant.ONE_MILLISECOND
constant.ONE_MINUTE = 60 * constant.ONE_SECOND
constant.ONE_HOUR = 60 * constant.ONE_MINUTE
constant.ONE_DAY = 24 * constant.ONE_HOUR
constant.ONE_WEAK = 7 * constant.ONE_DAY
constant.ONE_MONTH = 30 * constant.ONE_DAY
constant.ONE_YEAR = 356 * constant.ONE_DAY
return constant
