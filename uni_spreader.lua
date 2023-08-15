stopped = false
connect = false
function OnStop()
    stopped = true
    return 5000
end

function ABS(num)
    if num < 0 then 
        return (-1)*num
    else 
        return num
    end
end

function def_mid(id)
    x = getNumberOf('trades')
    sum_1 = 0
    sum_2 = 0

    i       = 1
    counter = 0

    sec_1_counter = 0
    sec_2_counter = 0

    while counter < m*(num_1 + num_2) do
        str = getItem('trades', x - i)
        i = i + 1
        if str.trans_id == tonumber(id) then
            counter = counter + 1
            if str.sec_code == sec_code_1 then
                sum_1         = sum_1 + (str.price)
                sec_1_counter = sec_1_counter + 1
            else 
                sum_2         = sum_2 + str.price
                sec_2_counter = sec_2_counter + 1
            end
        end
    end 

    mid = (sum_1/sec_1_counter)/(sum_2/sec_2_counter)
    return mid
end

account_real = 'A720z6d'
account_test = 'SPBFUT000mz'
class_code   = 'SPBFUT'
sec_code_1   = 'BRU3'
sec_code_2   = 'NGQ3'
account      = account_real
num_1        = 1
num_2        = 2
m            = 1
id_b         = '500'
id_s         = '600'
percent_sell = 0.006
percent_buy  = 0.006

account_real = 'A720z6d'
account_test = 'SPBFUT000mz'
class_code   = 'SPBFUT'
sec_code_1   = 'BRU3'
sec_code_2   = 'NGQ3'
account      = account_real
num_1        = 1
num_2        = 2
m            = 1
id_b         = '500'
id_s         = '600'
percent_sell = 0.006
percent_buy  = 0.006

function sell_spread(num_1, num_2)
    
    sell =  {
        ACTION = 'NEW_ORDER',
        ACCOUNT = account,
        OPERATION = 'S',
        CLASSCODE = class_code ,
        SECCODE = sec_code_1,
        PRICE = tostring(0),
        QUANTITY = tostring(1),
        TRANS_ID = id_s,
        TYPE = 'M'
    } 

    for i = 0, num_1 - 1, 1 do
        Err_sell = sendTransaction(sell)
    end

    buy =  {
        ACTION = 'NEW_ORDER',
        ACCOUNT = account,
        OPERATION = 'B',
        CLASSCODE = class_code ,
        SECCODE = sec_code_2,
        PRICE = tostring(0),
        QUANTITY = tostring(1),
        TRANS_ID = id_s,
        TYPE = 'M'
    } 

    for i = 0, num_2 - 1, 1 do 
        Err_buy = sendTransaction(buy) 
    end     
end 

function buy_spread(num_1, num_2)

    sell =  {
        ACTION = 'NEW_ORDER',
        ACCOUNT = account,
        OPERATION = 'S',
        CLASSCODE = class_code ,
        SECCODE = sec_code_2,
        PRICE = tostring(0),
        QUANTITY = tostring(1),
        TRANS_ID = id_b,
        TYPE = 'M'
    }  

    buy =  {
        ACTION = 'NEW_ORDER',
        ACCOUNT = account,
        OPERATION = 'B',
        CLASSCODE = class_code ,
        SECCODE = sec_code_1,
        PRICE = tostring(0),
        QUANTITY = tostring(1),
        TRANS_ID = id_b,
        TYPE = 'M'      
    } 
    Err_buy = sendTransaction(buy) 

    for i = 0, num_1 - 2, 1 do 
        Err_buy = sendTransaction(buy) 
    end     

    Err_sell = sendTransaction(sell)   
    
    for i = 0, num_2 - 2, 1 do
        Err_sell = sendTransaction(sell)
    end
end


function main()
    file = io.open("testings.txt", "w")

    price_1 = tonumber(getParamEx(class_code, sec_code_1, 'LAST').param_value)
    price_2 = tonumber(getParamEx(class_code, sec_code_2, 'LAST').param_value)

    spread_beg = price_1 / price_2 

    gap_sell   = spread_beg*percent_sell
    gap_buy    = spread_beg*percent_buy

    high       = spread_beg + gap_sell
    low        = spread_beg - gap_buy

    message('spread_begin = ' .. spread_beg .. ' high = ' .. high .. ' low = '.. low)
    sleep(5000)

    file:write('начало, начальный спред, высокий уровень, нижний уровень\n')
    file:write('begin, ' .. spread_beg .. ", " .. high .. ", " .. low ..'\n')

    while isConnected() == 1 do
        price_1_bid = tonumber(getParamEx(class_code, sec_code_1, 'BID').param_value)
        price_1_off = tonumber(getParamEx(class_code, sec_code_1, 'OFFER').param_value)
        price_2_bid = tonumber(getParamEx(class_code, sec_code_2, 'BID').param_value)
        price_2_off = tonumber(getParamEx(class_code, sec_code_2, 'OFFER').param_value)

        spread_sell = price_2_bid - price_1_off/1000 
        spread_buy  = price_2_off - price_1_bid/1000 
        currentTime = os.date("%Y-%m-%d %H:%M:%S")

        s = 0
        b = 0

        while s < m and b < m do
            price_1_bid = tonumber(getParamEx(class_code, sec_code_1, 'BID').param_value)
            price_1_off = tonumber(getParamEx(class_code, sec_code_1, 'OFFER').param_value)
            price_2_bid = tonumber(getParamEx(class_code, sec_code_2, 'BID').param_value)
            price_2_off = tonumber(getParamEx(class_code, sec_code_2, 'OFFER').param_value)

            spread_sell = price_1_bid / price_2_off  
            spread_buy  = price_1_off / price_2_bid 
            currentTime = os.date("%Y-%m-%d %H:%M:%S")

            if spread_sell >= high then
                file:write('серия продаж, ' .. currentTime .. ', \n')
                sell_spread(num_1, num_2)
                s = s + 1
                file:write('sell, ' .. spread_sell..'\n')
    
                sleep(1000)
      

            elseif spread_buy <= low then
                file:write('серия покупок, ' .. currentTime .. ', \n')
                buy_spread(num_1, num_2)
                
                b = b + 1
                file:write('buy, ' .. spread_buy ..'\n')
    
                sleep(1000)  
            end
        end 
        
        if b == m then
            mid = def_mid(id_b)
            high = mid + gap_sell
            low  = mid - gap_buy
            sleep(5200)
            message('buy, mid = ' .. mid .. ', low = ' .. low .. ', high = ' .. high)
        elseif s == m then 
            mid = def_mid(id_s)
            high = mid + gap_sell
            low  = mid - gap_buy
            sleep(5200)
            message('sell, mid = ' .. mid .. ', low = ' .. low .. ', high = ' .. high)
        end

        file:write('mid = ' .. mid .. ', low = ' .. low .. ', high = ' .. high .. '\n')
    end
end
