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


account_real = 'A720z6d'
account_test = 'SPBFUT000mz'
class_code   = 'SPBFUT'
sec_code_1   = 'SiU3'
sec_code_2   = 'USDRUBF'
account      = account_test
gap_sell     = 0.02
gap_buy      = 0.01
n            = 1
m            = 3
id           = '10'

function sell_spread(n)
    
        sell =  {
            ACTION = 'NEW_ORDER',
            ACCOUNT = account,
            OPERATION = 'S',
            CLASSCODE = class_code ,
            SECCODE = sec_code_2,
            PRICE = tostring(0),
            QUANTITY = tostring(n),
            TRANS_ID = id,
            TYPE = 'M'
        }  
        Err_sell = sendTransaction(sell)

        buy =  {
            ACTION = 'NEW_ORDER',
            ACCOUNT = account,
            OPERATION = 'B',
            CLASSCODE = class_code ,
            SECCODE = sec_code_1,
            PRICE = tostring(0),
            QUANTITY = tostring(n),
            TRANS_ID = id,
            TYPE = 'M'
        } 
        Err_buy = sendTransaction(buy)      
end 

function buy_spread(n)
    
        sell =  {
            ACTION = 'NEW_ORDER',
            ACCOUNT = account,
            OPERATION = 'S',
            CLASSCODE = class_code ,
            SECCODE = sec_code_1,
            PRICE = tostring(0),
            QUANTITY = tostring(n),
            TRANS_ID = id,
            TYPE = 'M'
        }  
        Err_sell = sendTransaction(sell)

        buy =  {
            ACTION = 'NEW_ORDER',
            ACCOUNT = account,
            OPERATION = 'B',
            CLASSCODE = class_code ,
            SECCODE = sec_code_2,
            PRICE = tostring(0),
            QUANTITY = tostring(n),
            TRANS_ID = id,
            TYPE = 'M'      
        } 
        Err_buy = sendTransaction(buy)         
end

function main()
    file = io.open("testings.txt", "w")

    price_1 = tonumber(getParamEx(class_code, sec_code_1, 'LAST').param_value)
    price_2 = tonumber(getParamEx(class_code, sec_code_2, 'LAST').param_value)

    spread_beg = price_2 - price_1/1000 
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

        if spread_sell >= high then
            file:write('серия продаж, ' .. currentTime .. ', \n')
            sell_spread(n)
            k = 1
            sum = 0
            sum = spread_sell
            file:write('sell, ' .. spread_sell..'\n')

            for i = 0, m - 2, 1 do
                price_1_off = tonumber(getParamEx(class_code, sec_code_1, 'OFFER').param_value)
                price_2_bid = tonumber(getParamEx(class_code, sec_code_2, 'BID').param_value)
        
                spread_sell = price_2_bid - price_1_off/1000  

                if spread_sell >= high then 
                    sell_spread(n)
                    k = k +1
                    sum = sum + spread_sell
                    file:write('sell, ' .. spread_sell ..'\n')
                end
            end

            mid  = sum/k
            low  = mid - gap_buy
            high = mid + gap_sell
            
            file:write('mid = ' .. mid .. ', low = ' .. low .. ', high = ' .. high .. '\n')
            sleep(5200)
            message('sell, ' .. spread_sell .. ' mid = ' .. mid .. ', low = ' .. low .. ', high = ' .. high)  
            

        elseif spread_buy <= low then
            file:write('серия покупок, ' .. currentTime .. ', \n')
            buy_spread(n)
            k = 1
            sum = spread_buy
            file:write('buy, ' .. spread_buy ..'\n')

            for i = 0, m - 2, 1 do
                price_1_bid = tonumber(getParamEx(class_code, sec_code_1, 'BID').param_value)
                price_2_off = tonumber(getParamEx(class_code, sec_code_2, 'OFFER').param_value)
        
                spread_buy  = price_2_off - price_1_bid/1000 

                if spread_buy <= low then 
                    buy_spread(n)
                    k = k + 1
                    sum = sum + spread_buy
                    file:write('buy, ' .. spread_buy ..'\n')
                end
                
            end

            mid  = sum/k
            low  = mid - gap_buy
            high = mid + gap_sell

            file:write('mid = ' .. mid .. ', low = ' .. low .. ', high = ' .. high .. '\n')
            sleep(5200)
            message('buy, ' .. spread_buy .. ' mid = ' .. mid .. ', low = ' .. low .. ', high = ' .. high)  
        end
    end
end
